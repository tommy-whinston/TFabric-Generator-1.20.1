package ${package}.client.obj;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.server.packs.resources.Resource;
import net.minecraft.server.packs.resources.ResourceManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.Map;
import java.util.Optional;

/**
 * One OBJ model binding. A binding is either read from obj_models.json or
 * created automatically for assets/&lt;modid&gt;/models/item/&lt;block&gt;.obj.
 */
public final class ObjModelDefinition {
	private static final Logger LOGGER = LoggerFactory.getLogger("obj-models");

	public final ResourceLocation blockId;
	public final ResourceLocation modelId;
	public final ResourceLocation objLocation;
	public final ResourceLocation texture;
	public final java.util.Map<String, ResourceLocation> textures;
	public final String display;
	public final int tintIndex;
	public final boolean culling;
	public final boolean doubleSided;
	public final float scale;
	public final float offsetX;
	public final float offsetY;
	public final float offsetZ;
	public final boolean flipU;
	public final boolean flipV;
	public final boolean ambientOcclusion;
	public final boolean gui3d;
	public final boolean shade;
	public final boolean blockLight;
	public final ObjGeometry geometry;

	private ObjModelDefinition(ResourceLocation blockId, ResourceLocation modelId, ResourceLocation objLocation, ResourceLocation texture,
			java.util.Map<String, ResourceLocation> textures, String display, int tintIndex, boolean culling, boolean doubleSided, float scale,
			float offsetX, float offsetY, float offsetZ, boolean flipU, boolean flipV, boolean ambientOcclusion, boolean gui3d,
			boolean shade, boolean blockLight, ObjGeometry geometry) {
		this.blockId = blockId;
		this.modelId = modelId;
		this.objLocation = objLocation;
		this.texture = texture;
		this.textures = textures;
		this.display = display;
		this.tintIndex = tintIndex;
		this.culling = culling;
		this.doubleSided = doubleSided;
		this.scale = scale;
		this.offsetX = offsetX;
		this.offsetY = offsetY;
		this.offsetZ = offsetZ;
		this.flipU = flipU;
		this.flipV = flipV;
		this.ambientOcclusion = ambientOcclusion;
		this.gui3d = gui3d;
		this.shade = shade;
		this.blockLight = blockLight;
		this.geometry = geometry;
	}

	/**
	 * Reads one entry of obj_models.json.
	 */
	public static ObjModelDefinition load(ResourceLocation blockId, JsonObject json, ResourceManager manager) {
		String objValue = getString(json, "obj", null);
		ResourceLocation objLocation = resolveObjLocation(blockId, objValue != null ? objValue : "models/item/" + blockId.getPath() + ".obj");

		String modelValue = getString(json, "model", null);
		ResourceLocation modelId = resolveModelLocation(blockId, modelValue != null ? modelValue : "block/" + blockId.getPath());
		String display = getString(json, "display", modelId.getPath().startsWith("item/") ? "item" : "block");

		String textureValue = getString(json, "texture", null);
		ResourceLocation texture = textureValue != null ? resolveTextureLocation(blockId, textureValue)
				: resolveTexture(blockId, objLocation, manager);

		return create(blockId, modelId, objLocation, texture, display, json, manager);
	}

	/**
	 * Creates a definition using vanilla Minecraft defaults. Used by automatic
	 * discovery, where the OBJ file is named after the block (or after the block
	 * with a suffix, for example birch_average.obj for the birch block).
	 */
	public static ObjModelDefinition auto(ResourceLocation blockId, ResourceLocation objLocation, ResourceManager manager) {
		ResourceLocation modelId = new ResourceLocation(blockId.getNamespace(), "block/" + blockId.getPath());
		ResourceLocation texture = resolveTexture(blockId, objLocation, manager);
		return create(blockId, modelId, objLocation, texture, "block", new JsonObject(), manager);
	}

	/**
	 * MCreator writes a small &lt;model&gt;.obj.textures file next to every imported
	 * OBJ. It stores the texture names chosen in the model import dialog, so the
	 * texture does not have to match the block name.
	 */
	private static ResourceLocation resolveTexture(ResourceLocation blockId, ResourceLocation objLocation, ResourceManager manager) {
		ResourceLocation fromModel = readModelTexture(blockId, objLocation, manager);
		if (fromModel != null) {
			if (textureExists(fromModel, manager)) {
				LOGGER.info("Using texture '{}' from model metadata for '{}'", fromModel, blockId);
				return fromModel;
			}
			ResourceLocation item = new ResourceLocation(fromModel.getNamespace(), "item/" + leafName(fromModel.getPath()));
			if (textureExists(item, manager)) {
				LOGGER.info("Using texture '{}' from model metadata for '{}'", item, blockId);
				return item;
			}
		}

		// Fall back to the OBJ file name (birch_average.obj -> block/birch_average)
		// before falling back to the block name.
		ResourceLocation modelTexture = findTexture(blockId.getNamespace(), objName(objLocation), manager);
		if (textureExists(modelTexture, manager)) {
			LOGGER.info("Using texture '{}' for '{}'", modelTexture, blockId);
			return modelTexture;
		}
		return findTexture(blockId.getNamespace(), blockId.getPath(), manager);
	}

	private static String objName(ResourceLocation objLocation) {
		String name = leafName(objLocation.getPath());
		if (name.endsWith(".obj")) {
			name = name.substring(0, name.length() - 4);
		}
		return name;
	}

	private static ResourceLocation readModelTexture(ResourceLocation blockId, ResourceLocation objLocation, ResourceManager manager) {
		ResourceLocation sidecar = new ResourceLocation(objLocation.getNamespace(), objLocation.getPath() + ".textures");
		Optional<Resource> resource = manager.getResource(sidecar);
		if (resource.isEmpty()) {
			return null;
		}

		try (BufferedReader reader = resource.get().openAsReader()) {
			JsonElement root = JsonParser.parseReader(reader);
			if (!root.isJsonObject()) {
				return null;
			}
			JsonObject mappings = root.getAsJsonObject().getAsJsonObject("mappings");
			if (mappings == null) {
				return null;
			}

			JsonObject mapping = mappings.has("default") && mappings.get("default").isJsonObject()
					? mappings.getAsJsonObject("default") : null;
			if (mapping == null) {
				for (Map.Entry<String, JsonElement> entry : mappings.entrySet()) {
					if (entry.getValue().isJsonObject()) {
						mapping = entry.getValue().getAsJsonObject();
						break;
					}
				}
			}
			if (mapping == null || !mapping.has("map") || !mapping.get("map").isJsonObject()) {
				return null;
			}

			for (Map.Entry<String, JsonElement> entry : mapping.getAsJsonObject("map").entrySet()) {
				if (entry.getValue().isJsonPrimitive() && entry.getValue().getAsJsonPrimitive().isString()) {
					String value = entry.getValue().getAsString().trim();
					if (!value.isEmpty()) {
						return resolveTextureLocation(blockId, value);
					}
				}
			}
		} catch (Exception e) {
			LOGGER.warn("Failed to read model texture metadata '{}' for '{}'", sidecar, blockId, e);
		}
		return null;
	}

	private static String leafName(String path) {
		int slash = path.lastIndexOf('/');
		return slash >= 0 ? path.substring(slash + 1) : path;
	}

	/**
	 * Reads all material -&gt; texture mappings from MCreator's .obj.textures
	 * sidecar. Used for multi-texture OBJ models.
	 */
	private static Map<String, ResourceLocation> readModelTextures(ResourceLocation blockId, ResourceLocation objLocation,
			ResourceManager manager) {
		Map<String, ResourceLocation> result = new java.util.HashMap<>();
		ResourceLocation sidecar = new ResourceLocation(objLocation.getNamespace(), objLocation.getPath() + ".textures");
		Optional<Resource> resource = manager.getResource(sidecar);
		if (resource.isEmpty()) {
			return result;
		}

		try (BufferedReader reader = resource.get().openAsReader()) {
			JsonObject root = JsonParser.parseReader(reader).getAsJsonObject();
			JsonObject mappings = root.getAsJsonObject("mappings");
			if (mappings == null) {
				return result;
			}

			for (Map.Entry<String, JsonElement> mappingEntry : mappings.entrySet()) {
				if (!mappingEntry.getValue().isJsonObject()) {
					continue;
				}
				JsonObject mapping = mappingEntry.getValue().getAsJsonObject();
				if (!mapping.has("map") || !mapping.get("map").isJsonObject()) {
					continue;
				}

				for (Map.Entry<String, JsonElement> textureEntry : mapping.getAsJsonObject("map").entrySet()) {
					if (textureEntry.getValue().isJsonPrimitive() && textureEntry.getValue().getAsJsonPrimitive().isString()) {
						String value = textureEntry.getValue().getAsString().trim();
						if (!value.isEmpty()) {
							ResourceLocation tex = resolveTextureLocation(blockId, value);
							if (!textureExists(tex, manager)) {
								ResourceLocation item = new ResourceLocation(tex.getNamespace(), "item/" + leafName(tex.getPath()));
								if (textureExists(item, manager)) {
									tex = item;
								}
							}
							result.put(textureEntry.getKey(), tex);
						}
					}
				}
			}
		} catch (Exception e) {
			LOGGER.warn("Failed to read model texture metadata '{}' for '{}'", sidecar, blockId, e);
		}
		return result;
	}

	private static ObjModelDefinition create(ResourceLocation blockId, ResourceLocation modelId, ResourceLocation objLocation,
			ResourceLocation texture, String display, JsonObject json, ResourceManager manager) {
		Optional<Resource> resource = manager.getResource(objLocation);
		if (resource.isEmpty()) {
			LOGGER.warn("OBJ model file '{}' for '{}' was not found", objLocation, blockId);
			return null;
		}

		java.util.Map<String, ResourceLocation> textures = readModelTextures(blockId, objLocation, manager);

		ObjGeometry geometry;
		try (BufferedReader reader = resource.get().openAsReader()) {
			geometry = ObjGeometry.parse(reader);
		} catch (IOException | RuntimeException e) {
			LOGGER.error("Failed to load OBJ model '{}' for '{}'", objLocation, blockId, e);
			return null;
		}

		float scale = getFloat(json, "scale", 16.0f);
		boolean center = getBoolean(json, "center", false);
		// Blockbench uses a block-centered origin on X/Z, Minecraft uses the
		// block corner. +0.5 maps the OBJ origin to the center of the block.
		float offsetX = getFloat(json, "offset_x", 0.5f);
		float offsetY = getFloat(json, "offset_y", 0.0f);
		float offsetZ = getFloat(json, "offset_z", 0.5f);

		// Optional: center the whole bounding box instead of the origin.
		if (center && geometry.positions.length >= 3) {
			offsetX = getFloat(json, "offset_x", 0.0f);
			offsetZ = getFloat(json, "offset_z", 0.0f);
			float factor = scale / 16.0f;
			float minX = Float.MAX_VALUE;
			float maxX = -Float.MAX_VALUE;
			float minY = Float.MAX_VALUE;
			float maxY = -Float.MAX_VALUE;
			float minZ = Float.MAX_VALUE;
			float maxZ = -Float.MAX_VALUE;

			for (int i = 0; i < geometry.positions.length; i += 3) {
				float x = geometry.positions[i] * factor;
				float y = geometry.positions[i + 1] * factor;
				float z = geometry.positions[i + 2] * factor;
				minX = Math.min(minX, x);
				maxX = Math.max(maxX, x);
				minY = Math.min(minY, y);
				maxY = Math.max(maxY, y);
				minZ = Math.min(minZ, z);
				maxZ = Math.max(maxZ, z);
			}

			offsetX += 0.5f - (minX + maxX) / 2.0f;
			offsetY += -minY;
			offsetZ += 0.5f - (minZ + maxZ) / 2.0f;

			LOGGER.info("Centered OBJ model '{}' for '{}' (offset {}, {}, {})", objLocation, blockId, offsetX, offsetY, offsetZ);
		}

		boolean flipU = getBoolean(json, "flip_u", false);
		boolean flipV = getBoolean(json, "flip_v", true);
		boolean ambientOcclusion = getBoolean(json, "ambient_occlusion", false);
		boolean gui3d = getBoolean(json, "gui_3d", true);
		boolean shade = getBoolean(json, "shade", true);
		boolean blockLight = getBoolean(json, "block_light", true);
		int tintIndex = getInt(json, "tint_index", 0);
		boolean culling = getBoolean(json, "culling", false);
		boolean doubleSided = getBoolean(json, "double_sided", true);

		LOGGER.info("Loaded OBJ model '{}' ({} faces, {} vertices) for '{}'", objLocation, geometry.faces.size(),
				geometry.positions.length / 3, blockId);

		return new ObjModelDefinition(blockId, modelId, objLocation, texture, textures, display, tintIndex, culling, doubleSided, scale,
				offsetX, offsetY, offsetZ, flipU, flipV, ambientOcclusion, gui3d, shade, blockLight, geometry);
	}

	/**
	 * Turns a manifest value into a resource path under assets/&lt;namespace&gt;.
	 * Accepted forms: "birch", "item/birch.obj", "models/item/birch.obj",
	 * "whiteout:item/birch.obj" and the full "whiteout:models/item/birch.obj".
	 */
	public static ResourceLocation resolveObjLocation(ResourceLocation blockId, String value) {
		String raw = value == null ? "" : value.trim().replace('\\', '/');
		if (raw.isEmpty()) {
			raw = "models/item/" + blockId.getPath() + ".obj";
		}

		String namespace = blockId.getNamespace();
		String path = raw;
		int colon = raw.indexOf(':');
		if (colon >= 0) {
			namespace = raw.substring(0, colon);
			path = raw.substring(colon + 1);
		}

		while (path.startsWith("/")) {
			path = path.substring(1);
		}
		if (!path.endsWith(".obj")) {
			path += ".obj";
		}
		if (!path.startsWith("models/")) {
			if (path.contains("/")) {
				path = "models/" + path;
			} else {
				path = "models/item/" + path;
			}
		}
		return new ResourceLocation(namespace, path);
	}

	/**
	 * Turns a manifest value into a model id. Accepted forms: "birch",
	 * "block/birch", "whiteout:block/birch".
	 */
	public static ResourceLocation resolveModelLocation(ResourceLocation blockId, String value) {
		String raw = value == null ? "" : value.trim().replace('\\', '/');
		if (raw.isEmpty()) {
			raw = "block/" + blockId.getPath();
		}

		String namespace = blockId.getNamespace();
		String path = raw;
		int colon = raw.indexOf(':');
		if (colon >= 0) {
			namespace = raw.substring(0, colon);
			path = raw.substring(colon + 1);
		}

		while (path.startsWith("/")) {
			path = path.substring(1);
		}
		if (path.startsWith("models/")) {
			path = path.substring("models/".length());
		}
		if (!path.contains("/")) {
			path = "block/" + path;
		}
		return new ResourceLocation(namespace, path);
	}

	/**
	 * Normalizes a texture reference to the form used by Material, e.g.
	 * "block/birch" (without textures/ prefix and without .png).
	 */
	public static ResourceLocation resolveTextureLocation(ResourceLocation blockId, String value) {
		String raw = value == null ? "" : value.trim().replace('\\', '/');
		if (raw.isEmpty()) {
			raw = "block/" + blockId.getPath();
		}

		String namespace = blockId.getNamespace();
		String path = raw;
		int colon = raw.indexOf(':');
		if (colon >= 0) {
			namespace = raw.substring(0, colon);
			path = raw.substring(colon + 1);
		}

		while (path.startsWith("/")) {
			path = path.substring(1);
		}
		if (path.startsWith("textures/")) {
			path = path.substring("textures/".length());
		}
		if (path.endsWith(".png")) {
			path = path.substring(0, path.length() - 4);
		}
		if (!path.contains("/")) {
			path = "block/" + path;
		}
		return new ResourceLocation(namespace, path);
	}

	/**
	 * Resource path used to test whether a texture exists in the current
	 * resource pack set.
	 */
	public static ResourceLocation textureResource(ResourceLocation texture) {
		String path = texture.getPath();
		if (path.startsWith("textures/")) {
			path = path.substring("textures/".length());
		}
		if (!path.endsWith(".png")) {
			path += ".png";
		}
		return new ResourceLocation(texture.getNamespace(), "textures/" + path);
	}

	public static boolean textureExists(ResourceLocation texture, ResourceManager manager) {
		return manager.getResource(textureResource(texture)).isPresent();
	}

	/**
	 * Chooses a reasonable default texture for a block. Direct name matches win;
	 * otherwise a single &lt;name&gt;_*.png in textures/block is used (this makes
	 * names like birch_average.obj work without a manifest).
	 */
	public static ResourceLocation findTexture(String namespace, String name, ResourceManager manager) {
		ResourceLocation blockTexture = new ResourceLocation(namespace, "block/" + name);
		if (textureExists(blockTexture, manager)) {
			return blockTexture;
		}

		ResourceLocation itemTexture = new ResourceLocation(namespace, "item/" + name);
		if (textureExists(itemTexture, manager)) {
			return itemTexture;
		}

		Map<ResourceLocation, Resource> textures = manager.listResources("textures/block",
				location -> location.getNamespace().equals(namespace) && location.getPath().endsWith(".png"));
		ResourceLocation match = null;
		for (ResourceLocation location : textures.keySet()) {
			String path = location.getPath();
			int slash = path.lastIndexOf('/');
			String file = slash >= 0 ? path.substring(slash + 1) : path;
			if (file.startsWith(name + "_") || file.startsWith(name + ".")) {
				if (match != null) {
					match = null;
					break;
				}
				match = location;
			}
		}
		if (match != null) {
			return textureFromResource(match);
		}

		return blockTexture;
	}

	private static ResourceLocation textureFromResource(ResourceLocation resource) {
		String path = resource.getPath();
		if (path.startsWith("textures/")) {
			path = path.substring("textures/".length());
		}
		if (path.endsWith(".png")) {
			path = path.substring(0, path.length() - 4);
		}
		return new ResourceLocation(resource.getNamespace(), path);
	}

	private static String getString(JsonObject json, String name, String fallback) {
		return json.has(name) && !json.get(name).isJsonNull() ? json.get(name).getAsString() : fallback;
	}

	private static float getFloat(JsonObject json, String name, float fallback) {
		return json.has(name) ? json.get(name).getAsFloat() : fallback;
	}

	private static boolean getBoolean(JsonObject json, String name, boolean fallback) {
		return json.has(name) ? json.get(name).getAsBoolean() : fallback;
	}

	private static int getInt(JsonObject json, String name, int fallback) {
		return json.has(name) ? json.get(name).getAsInt() : fallback;
	}
}
