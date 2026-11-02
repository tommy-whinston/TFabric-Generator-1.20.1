package ${package}.client.obj;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import net.fabricmc.api.ClientModInitializer;
import net.fabricmc.api.EnvType;
import net.fabricmc.api.Environment;
import net.fabricmc.fabric.api.blockrenderlayer.v1.BlockRenderLayerMap;
import net.fabricmc.fabric.api.client.model.loading.v1.BlockStateResolver;
import net.fabricmc.fabric.api.client.model.loading.v1.ModelLoadingPlugin;
import net.fabricmc.fabric.api.client.model.loading.v1.PreparableModelLoadingPlugin;
import net.minecraft.client.renderer.ItemBlockRenderTypes;
import net.minecraft.client.renderer.RenderType;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.server.packs.resources.Resource;
import net.minecraft.server.packs.resources.ResourceManager;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.block.state.properties.Property;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import java.util.regex.Pattern;

/**
 * Fabric-side OBJ block model support for MCreator workspaces.
 *
 * <p>Discovery is automatic: every OBJ file in
 * {@code assets/<modid>/models/item/<block>.obj} is bound to the block with the
 * same registry name and to {@code assets/<modid>/textures/block/<block>.png}.
 * A matching texture with a suffix (for example {@code birch_average.png} for
 * the {@code birch} block) is also accepted when it is the only candidate.
 *
 * <p>Advanced or differently named models can be listed in
 * {@code assets/<modid>/obj_models.json}:
 *
 * <pre>
 * {
 *   "models": {
 *     "mymod:willow": {
 *       "obj": "mymod:models/item/willow_tree.obj",
 *       "texture": "mymod:block/willow_tree",
 *       "model": "mymod:block/willow",
 *       "scale": 16.0,
 *       "flip_v": true
 *     }
 *   }
 * }
 * </pre>
 */
@Environment(EnvType.CLIENT)
public final class ObjModelLoader implements ClientModInitializer {
	public static final String MODID = "${modid}";

	private static final Logger LOGGER = LoggerFactory.getLogger(MODID + "-obj");
	private static final ResourceLocation MANIFEST = new ResourceLocation(MODID, "obj_models.json");
	private static final ResourceLocation GENERATED_MANIFEST = new ResourceLocation(MODID, "obj_models_generated.json");
	private static final Pattern VALID_NAME = Pattern.compile("[a-z0-9_.-]+");

	private static volatile ResourceManager resources;
	private static boolean registered;

	@Override
	public void onInitializeClient() {
		register();
	}

	/**
	 * Registers the model loading plugin. Safe to call more than once; this also
	 * lets older workspaces call it from an existing client initializer.
	 */
	public static void register() {
		if (registered) {
			return;
		}
		registered = true;

		PreparableModelLoadingPlugin.register(ObjModelLoader::loadDefinitions, ObjModelLoader::onInitializeModelLoader);
		LOGGER.info("Registered OBJ model loader for '{}'", MODID);
	}

	private static CompletableFuture<Map<ResourceLocation, ObjModelDefinition>> loadDefinitions(ResourceManager resourceManager,
			Executor executor) {
		resources = resourceManager;
		return CompletableFuture.supplyAsync(() -> {
			Map<ResourceLocation, ObjModelDefinition> definitions = new HashMap<>();
			Set<ResourceLocation> usedObjects = new HashSet<>();

			loadManifest(resourceManager, GENERATED_MANIFEST, definitions, usedObjects);
			loadManifest(resourceManager, MANIFEST, definitions, usedObjects);
			discoverModels(resourceManager, definitions, usedObjects);

			return definitions;
		}, executor);
	}

	private static void loadManifest(ResourceManager resourceManager, ResourceLocation manifest,
			Map<ResourceLocation, ObjModelDefinition> definitions, Set<ResourceLocation> usedObjects) {
		Optional<Resource> resource = resourceManager.getResource(manifest);
		if (resource.isEmpty()) {
			return;
		}

		try (BufferedReader reader = resource.get().openAsReader()) {
			JsonObject root = JsonParser.parseReader(reader).getAsJsonObject();
			JsonObject models = root.has("models") && root.get("models").isJsonObject() ? root.getAsJsonObject("models") : root;

			for (Map.Entry<String, JsonElement> entry : models.entrySet()) {
				ResourceLocation blockId = parseId(entry.getKey());
				if (blockId == null) {
					LOGGER.warn("Skipping invalid OBJ model id '{}'", entry.getKey());
					continue;
				}

				JsonObject json;
				JsonElement value = entry.getValue();
				if (value.isJsonPrimitive() && value.getAsJsonPrimitive().isString()) {
					json = new JsonObject();
					json.addProperty("obj", value.getAsString());
				} else if (value.isJsonObject()) {
					json = value.getAsJsonObject();
				} else {
					LOGGER.warn("Skipping OBJ model '{}': expected an object or a string", entry.getKey());
					continue;
				}

				ObjModelDefinition definition = ObjModelDefinition.load(blockId, json, resourceManager);
				if (definition != null) {
					definitions.put(blockId, definition);
					usedObjects.add(definition.objLocation);
					LOGGER.info("Loaded manifest OBJ model '{}' for '{}'", definition.objLocation, blockId);
				}
			}
		} catch (Exception e) {
			LOGGER.error("Failed to read OBJ model manifest '{}'; continuing with automatic discovery", manifest, e);
		}
	}

	private static void discoverModels(ResourceManager resourceManager, Map<ResourceLocation, ObjModelDefinition> definitions,
			Set<ResourceLocation> usedObjects) {
		Map<ResourceLocation, Resource> objects = resourceManager.listResources("models/item",
				location -> location.getNamespace().equals(MODID) && location.getPath().endsWith(".obj"));

		List<ResourceLocation> pending = new ArrayList<>();

		// First pass: a model named exactly like a registered block always wins.
		for (ResourceLocation objLocation : objects.keySet()) {
			if (usedObjects.contains(objLocation)) {
				continue;
			}

			String name = blockName(objLocation);
			if (name == null) {
				continue;
			}

			ResourceLocation blockId = new ResourceLocation(MODID, name);
			if (!BuiltInRegistries.BLOCK.containsKey(blockId) || definitions.containsKey(blockId)) {
				pending.add(objLocation);
				continue;
			}

			addAuto(objLocation, blockId, resourceManager, definitions, usedObjects);
		}

		// Second pass: birch_average.obj is accepted for the birch block. The
		// longest matching block name wins, so birch_planks beats birch.
		for (ResourceLocation objLocation : pending) {
			if (usedObjects.contains(objLocation)) {
				continue;
			}
			String name = blockName(objLocation);
			if (name == null) {
				continue;
			}

			ResourceLocation blockId = findPrefixedBlock(name);
			if (blockId == null || definitions.containsKey(blockId)) {
				continue;
			}

			addAuto(objLocation, blockId, resourceManager, definitions, usedObjects);
		}
	}

	private static void addAuto(ResourceLocation objLocation, ResourceLocation blockId, ResourceManager resourceManager,
			Map<ResourceLocation, ObjModelDefinition> definitions, Set<ResourceLocation> usedObjects) {
		ObjModelDefinition definition = ObjModelDefinition.auto(blockId, objLocation, resourceManager);
		if (definition != null) {
			definitions.put(blockId, definition);
			usedObjects.add(objLocation);
			LOGGER.info("Auto-detected OBJ model '{}' for block '{}' (texture '{}')", objLocation, blockId, definition.texture);
		}
	}

	private static String blockName(ResourceLocation objLocation) {
		String fileName = fileName(objLocation);
		if (fileName.isEmpty()) {
			return null;
		}
		String name = fileName.toLowerCase(Locale.ROOT);
		if (!VALID_NAME.matcher(name).matches()) {
			LOGGER.warn("Skipping OBJ model '{}': '{}' is not a valid block name", objLocation, name);
			return null;
		}
		return name;
	}

	/**
	 * Finds the longest registered block whose name is a prefix of the model
	 * name (for example birch for birch_average.obj).
	 */
	private static ResourceLocation findPrefixedBlock(String modelName) {
		ResourceLocation best = null;
		int bestLength = 0;
		for (ResourceLocation id : BuiltInRegistries.BLOCK.keySet()) {
			if (!id.getNamespace().equals(MODID)) {
				continue;
			}
			String path = id.getPath();
			if (path.length() <= bestLength) {
				continue;
			}
			if (modelName.equals(path) || modelName.startsWith(path + "_") || modelName.startsWith(path + ".")) {
				best = id;
				bestLength = path.length();
			}
		}
		return best;
	}

	/**
	 * Reads the generated blockstate JSON and extracts the x/y rotation of every
	 * state variant, so facing/axis blocks rotate their OBJ model correctly.
	 */
	private static Map<BlockState, int[]> loadRotations(ResourceManager manager, ResourceLocation blockId) {
		Map<BlockState, int[]> rotations = new HashMap<>();
		if (manager == null) {
			return rotations;
		}

		ResourceLocation location = new ResourceLocation(blockId.getNamespace(), "blockstates/" + blockId.getPath() + ".json");
		Optional<Resource> resource = manager.getResource(location);
		if (resource.isEmpty()) {
			return rotations;
		}

		try (BufferedReader reader = resource.get().openAsReader()) {
			JsonObject root = JsonParser.parseReader(reader).getAsJsonObject();
			if (!root.has("variants") || !root.get("variants").isJsonObject()) {
				return rotations;
			}

			JsonObject variants = root.getAsJsonObject("variants");
			Map<String, int[]> byKey = new HashMap<>();
			for (Map.Entry<String, JsonElement> entry : variants.entrySet()) {
				JsonElement value = entry.getValue();
				if (value.isJsonArray()) {
					if (value.getAsJsonArray().size() == 0) {
						continue;
					}
					value = value.getAsJsonArray().get(0);
				}
				if (!value.isJsonObject()) {
					continue;
				}

				JsonObject variant = value.getAsJsonObject();
				int x = variant.has("x") ? variant.get("x").getAsInt() : 0;
				int y = variant.has("y") ? variant.get("y").getAsInt() : 0;
				byKey.put(entry.getKey().replace(" ", ""), new int[]{x, y});
			}

			Block block = BuiltInRegistries.BLOCK.get(blockId);
			if (block == Blocks.AIR) {
				return rotations;
			}

			for (BlockState state : block.getStateDefinition().getPossibleStates()) {
				int[] rotation = null;
				for (Map.Entry<String, int[]> entry : byKey.entrySet()) {
					if (matches(entry.getKey(), state)) {
						rotation = entry.getValue();
						break;
					}
				}
				if (rotation == null) {
					rotation = byKey.get("");
				}
				if (rotation != null) {
					rotations.put(state, rotation);
				}
			}
		} catch (Exception e) {
			LOGGER.warn("Failed to read blockstate rotations '{}' for '{}'", location, blockId, e);
		}
		return rotations;
	}

	private static boolean matches(String key, BlockState state) {
		if (key.isEmpty()) {
			return state.getProperties().isEmpty();
		}
		String[] parts = key.split(",");
		if (parts.length != state.getProperties().size()) {
			return false;
		}
		for (String part : parts) {
			int equals = part.indexOf('=');
			if (equals < 0) {
				return false;
			}
			String name = part.substring(0, equals);
			String value = part.substring(equals + 1);
			Property<?> property = state.getBlock().getStateDefinition().getProperty(name);
			if (property == null || !valueName(state, property).equals(value)) {
				return false;
			}
		}
		return true;
	}

	private static String valueName(BlockState state, Property<?> property) {
		return valueNameTyped(state, property);
	}

	private static <T extends Comparable<T>> String valueNameTyped(BlockState state, Property<T> property) {
		return property.getName(state.getValue(property));
	}

	private static ResourceLocation parseId(String value) {
		if (value == null) {
			return null;
		}
		String trimmed = value.trim();
		if (trimmed.isEmpty()) {
			return null;
		}
		try {
			return new ResourceLocation(trimmed.indexOf(':') >= 0 ? trimmed : MODID + ":" + trimmed);
		} catch (RuntimeException e) {
			return null;
		}
	}

	private static String fileName(ResourceLocation location) {
		String path = location.getPath();
		int slash = path.lastIndexOf('/');
		String name = slash >= 0 ? path.substring(slash + 1) : path;
		if (name.endsWith(".obj")) {
			name = name.substring(0, name.length() - 4);
		}
		return name;
	}

	private static void onInitializeModelLoader(Map<ResourceLocation, ObjModelDefinition> definitions, ModelLoadingPlugin.Context context) {
		if (definitions.isEmpty()) {
			LOGGER.info("No OBJ models found for '{}'", MODID);
			return;
		}

		// Replace the item model directly. Do not replace the block model id:
		// vanilla JSON models (the block item model, for example) may use it as
		// a parent, and a parent always has to be a BlockModel.
		Map<ResourceLocation, ObjModelDefinition> byItemModelId = new HashMap<>();
		for (ObjModelDefinition definition : definitions.values()) {
			ResourceLocation itemModelId = new ResourceLocation(definition.blockId.getNamespace(),
					"item/" + definition.blockId.getPath());
			ObjModelDefinition previous = byItemModelId.put(itemModelId, definition);
			if (previous != null && previous != definition) {
				LOGGER.warn("Item model id '{}' is used by both '{}' and '{}'; the last one wins", itemModelId,
						previous.blockId, definition.blockId);
			}
		}

		context.resolveModel().register(resolverContext -> {
			ObjModelDefinition definition = byItemModelId.get(resolverContext.id());
			return definition == null ? null : new ObjUnbakedModel(definition);
		});

		int blocks = 0;
		for (ObjModelDefinition definition : definitions.values()) {
			if (!BuiltInRegistries.BLOCK.containsKey(definition.blockId)) {
				LOGGER.warn("OBJ model '{}' is configured for unknown block '{}'", definition.objLocation, definition.blockId);
				continue;
			}

			Block block = BuiltInRegistries.BLOCK.get(definition.blockId);
			if (block == Blocks.AIR) {
				continue;
			}

			// OBJ models often contain cut-out pixels. Keep an explicit render
			// layer chosen in MCreator, but default to cutout for OBJ blocks.
			if (ItemBlockRenderTypes.getChunkRenderType(block.defaultBlockState()) == RenderType.solid()) {
				BlockRenderLayerMap.INSTANCE.putBlock(block, RenderType.cutout());
				LOGGER.info("Using cutout render layer for OBJ block '{}'", definition.blockId);
			}

			Map<BlockState, int[]> rotations = loadRotations(resources, definition.blockId);

			BlockStateResolver resolver = new BlockStateResolver() {
				@Override
				public void resolveBlockStates(BlockStateResolver.Context blockContext) {
					for (BlockState state : block.getStateDefinition().getPossibleStates()) {
						int[] rotation = rotations.get(state);
						int rotationX = rotation == null ? 0 : rotation[0];
						int rotationY = rotation == null ? 0 : rotation[1];
						blockContext.setModel(state, new ObjUnbakedModel(definition, rotationX, rotationY));
					}
				}
			};

			context.registerBlockStateResolver(block, resolver);
			blocks++;
			LOGGER.info("Registered OBJ block state model for '{}'", definition.blockId);
		}

		LOGGER.info("OBJ model loader ready: {} model(s), {} block(s)", definitions.size(), blocks);
	}
}
