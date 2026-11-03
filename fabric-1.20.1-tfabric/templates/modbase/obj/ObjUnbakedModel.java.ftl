package ${package}.client.obj;

import net.minecraft.client.renderer.block.model.BakedQuad;
import net.minecraft.client.renderer.block.model.ItemOverrides;
import net.minecraft.client.renderer.block.model.ItemTransform;
import net.minecraft.client.renderer.block.model.ItemTransforms;
import net.minecraft.client.renderer.texture.TextureAtlas;
import net.minecraft.client.renderer.texture.TextureAtlasSprite;
import net.minecraft.client.resources.model.BakedModel;
import net.minecraft.client.resources.model.BlockModelRotation;
import net.minecraft.client.resources.model.Material;
import net.minecraft.client.resources.model.ModelBaker;
import net.minecraft.client.resources.model.ModelState;
import net.minecraft.client.resources.model.SimpleBakedModel;
import net.minecraft.client.resources.model.UnbakedModel;
import net.minecraft.core.Direction;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.util.Mth;
import org.joml.Matrix3f;
import org.joml.Matrix4f;
import org.joml.Vector3f;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;

public final class ObjUnbakedModel implements UnbakedModel {
	private static final ItemTransforms BLOCK_TRANSFORMS = new ItemTransforms(
			transform(75, 45, 0, 0, 2.5f, 0, 0.375f),
			transform(75, 45, 0, 0, 2.5f, 0, 0.375f),
			transform(0, 225, 0, 0, 0, 0, 0.4f),
			transform(0, 45, 0, 0, 0, 0, 0.4f),
			ItemTransform.NO_TRANSFORM,
			transform(30, 225, 0, 0, 0, 0, 0.625f),
			transform(0, 0, 0, 0, 3, 0, 0.25f),
			transform(0, 0, 0, 0, 0, 0, 0.5f));

	private static final ItemTransforms TOOL_TRANSFORMS = new ItemTransforms(
			transform(0, 90, -55, 0, 4, 0.5f, 0.85f),
			transform(0, -90, 55, 0, 4, 0.5f, 0.85f),
			transform(0, 90, -25, 1.13f, 3.2f, 1.13f, 0.68f),
			transform(0, -90, 25, 1.13f, 3.2f, 1.13f, 0.68f),
			transform(0, 180, 0, 0, 13, 7, 1),
			transform(0, 0, 0, 0, 0, 0, 1),
			transform(0, 0, 0, 0, 2, 0, 0.5f),
			transform(0, 0, 0, 0, 0, 0, 1));

	private static final ItemTransforms ITEM_TRANSFORMS = new ItemTransforms(
			transform(0, 0, 0, 0, 3, 1, 0.55f),
			transform(0, 0, 0, 0, 3, 1, 0.55f),
			transform(0, 45, -25, 0, 4, 2, 1.7f),
			transform(0, -135, 25, 0, 4, 2, 1.7f),
			transform(0, 180, 0, 0, 13, 7, 1),
			transform(0, 0, 0, 0, 0, 0, 1),
			transform(0, 0, 0, 0, 2, 0, 0.5f),
			transform(0, 0, 0, 0, 0, 0, 1));

	private final ObjModelDefinition definition;
	private final int rotationX;
	private final int rotationY;

	public ObjUnbakedModel(ObjModelDefinition definition) {
		this(definition, 0, 0);
	}

	public ObjUnbakedModel(ObjModelDefinition definition, int rotationX, int rotationY) {
		this.definition = definition;
		this.rotationX = rotationX;
		this.rotationY = rotationY;
	}

	@Override
	public Collection<ResourceLocation> getDependencies() {
		return Collections.emptyList();
	}

	@Override
	public void resolveParents(Function<ResourceLocation, UnbakedModel> resolver) {
		// no parents
	}

	@Override
	public BakedModel bake(ModelBaker baker, Function<Material, TextureAtlasSprite> textureGetter, ModelState state, ResourceLocation modelId) {
		TextureAtlasSprite particle = textureGetter.apply(new Material(TextureAtlas.LOCATION_BLOCKS, definition.texture));
		Map<String, TextureAtlasSprite> sprites = new HashMap<>();

		Matrix4f matrix = null;
		Matrix3f normalMatrix = null;
		if (rotationX % 360 != 0 || rotationY % 360 != 0) {
			matrix = BlockModelRotation.by(rotationX, rotationY).getRotation().getMatrix();
			normalMatrix = new Matrix3f(matrix);
		}

		List<BakedQuad> quads = new ArrayList<>();
		for (ObjGeometry.Face face : definition.geometry.faces) {
			ResourceLocation texture = definition.textures.getOrDefault(face.material, definition.texture);
			TextureAtlasSprite sprite = sprites.computeIfAbsent(face.material,
					key -> textureGetter.apply(new Material(TextureAtlas.LOCATION_BLOCKS, texture)));

			int count = face.vertices.length;
			if (count == 4) {
				addQuad(quads, face.vertices, face.texCoords, face.normals, 0, 1, 2, 3, sprite, matrix, normalMatrix, false);
				if (definition.doubleSided) {
					addQuad(quads, face.vertices, face.texCoords, face.normals, 3, 2, 1, 0, sprite, matrix, normalMatrix, true);
				}
			} else if (count == 3) {
				addQuad(quads, face.vertices, face.texCoords, face.normals, 0, 1, 2, 2, sprite, matrix, normalMatrix, false);
				if (definition.doubleSided) {
					addQuad(quads, face.vertices, face.texCoords, face.normals, 2, 1, 0, 0, sprite, matrix, normalMatrix, true);
				}
			} else {
				for (int i = 1; i < count - 1; i++) {
					addQuad(quads, face.vertices, face.texCoords, face.normals, 0, i, i + 1, i + 1, sprite, matrix, normalMatrix, false);
					if (definition.doubleSided) {
						addQuad(quads, face.vertices, face.texCoords, face.normals, i + 1, i, 0, 0, sprite, matrix, normalMatrix, true);
					}
				}
			}
		}

		boolean itemModel = modelId.getPath().startsWith("item/");
		List<BakedQuad> unculled = new ArrayList<>();
		Map<Direction, List<BakedQuad>> culled = new EnumMap<>(Direction.class);
		for (Direction direction : Direction.values()) {
			culled.put(direction, new ArrayList<>());
		}

		if (itemModel || !definition.culling) {
			unculled.addAll(quads);
		} else {
			for (BakedQuad quad : quads) {
				Direction direction = quad.getDirection();
				if (direction == null) {
					unculled.add(quad);
				} else {
					culled.get(direction).add(quad);
				}
			}
		}

		ItemTransforms transforms = "tool".equals(definition.display) ? TOOL_TRANSFORMS
				: "item".equals(definition.display) ? ITEM_TRANSFORMS : BLOCK_TRANSFORMS;
		boolean blockModel = "block".equals(definition.display);

		return new SimpleBakedModel(unculled, culled, definition.ambientOcclusion && blockModel,
				definition.blockLight && blockModel, definition.gui3d, particle, transforms, ItemOverrides.EMPTY);
	}

	private static ItemTransform transform(float rx, float ry, float rz, float tx, float ty, float tz, float scale) {
		return new ItemTransform(new Vector3f(rx, ry, rz), new Vector3f(tx, ty, tz), new Vector3f(scale, scale, scale));
	}

	private void addQuad(List<BakedQuad> output, int[] faceVertices, int[] faceTexCoords, int[] faceNormals, int a, int b, int c, int d,
			TextureAtlasSprite sprite, Matrix4f matrix, Matrix3f normalMatrix, boolean reverseSide) {
		int[] vertices = {faceVertices[a], faceVertices[b], faceVertices[c], faceVertices[d]};
		int[] texCoords = {faceTexCoords[a], faceTexCoords[b], faceTexCoords[c], faceTexCoords[d]};
		int[] normals = {faceNormals[a], faceNormals[b], faceNormals[c], faceNormals[d]};

		float[] positions = new float[12];
		for (int i = 0; i < 4; i++) {
			int vertex = vertices[i];
			positions[i * 3] = definition.geometry.positions[vertex * 3];
			positions[i * 3 + 1] = definition.geometry.positions[vertex * 3 + 1];
			positions[i * 3 + 2] = definition.geometry.positions[vertex * 3 + 2];
		}

		float[] normal = faceNormal(positions);
		if (normal == null) {
			return;
		}

		float[] vertexNormal = vertexNormal(normals);
		if (!reverseSide && vertexNormal != null && dot(normal, vertexNormal) < 0.0f) {
			reverse(vertices, texCoords, normals);
			normal = new float[]{-normal[0], -normal[1], -normal[2]};
		}

		if (normalMatrix != null) {
			Vector3f rotated = normalMatrix.transform(new Vector3f(normal[0], normal[1], normal[2]));
			if (rotated.lengthSquared() > 1.0E-12f) {
				rotated.normalize();
				normal = new float[]{rotated.x, rotated.y, rotated.z};
			}
		}

		Direction direction = Direction.getNearest(normal[0], normal[1], normal[2]);
		if (direction == null) {
			return;
		}

		int[] data = new int[32];
		float scale = definition.scale / 16.0f;

		for (int i = 0; i < 4; i++) {
			int base = i * 8;
			int vertex = vertices[i];

			float px = definition.geometry.positions[vertex * 3] * scale + definition.offsetX;
			float py = definition.geometry.positions[vertex * 3 + 1] * scale + definition.offsetY;
			float pz = definition.geometry.positions[vertex * 3 + 2] * scale + definition.offsetZ;
			if (matrix != null) {
				Vector3f rotated = new Vector3f(px, py, pz).sub(0.5f, 0.5f, 0.5f);
				matrix.transformPosition(rotated);
				rotated.add(0.5f, 0.5f, 0.5f);
				px = rotated.x;
				py = rotated.y;
				pz = rotated.z;
			}

			data[base] = Float.floatToRawIntBits(px);
			data[base + 1] = Float.floatToRawIntBits(py);
			data[base + 2] = Float.floatToRawIntBits(pz);
			data[base + 3] = 0xFFFFFFFF;

			int textureIndex = texCoords[i];
			float u = 0.0f;
			float v = 0.0f;
			if (textureIndex >= 0) {
				u = definition.geometry.uvs[textureIndex * 2];
				v = definition.geometry.uvs[textureIndex * 2 + 1];
			}

			if (definition.flipU) {
				u = 1.0f - u;
			}
			if (definition.flipV) {
				v = 1.0f - v;
			}

			data[base + 4] = Float.floatToRawIntBits(sprite.getU(Mth.clamp(u, 0.0f, 1.0f) * 16.0f));
			data[base + 5] = Float.floatToRawIntBits(sprite.getV(Mth.clamp(v, 0.0f, 1.0f) * 16.0f));
			data[base + 6] = definition.tintIndex;
			data[base + 7] = 0;
		}

		output.add(new BakedQuad(data, 0, direction, sprite, definition.shade));
	}

	private static float[] faceNormal(float[] positions) {
		float ax = positions[3] - positions[0];
		float ay = positions[4] - positions[1];
		float az = positions[5] - positions[2];
		float bx = positions[6] - positions[0];
		float by = positions[7] - positions[1];
		float bz = positions[8] - positions[2];

		float nx = ay * bz - az * by;
		float ny = az * bx - ax * bz;
		float nz = ax * by - ay * bx;

		if (nx * nx + ny * ny + nz * nz < 1.0E-12f) {
			bx = positions[6] - positions[0];
			by = positions[7] - positions[1];
			bz = positions[8] - positions[2];
			float cx = positions[9] - positions[0];
			float cy = positions[10] - positions[1];
			float cz = positions[11] - positions[2];
			nx = by * cz - bz * cy;
			ny = bz * cx - bx * cz;
			nz = bx * cy - by * cx;
		}

		float length = (float) Math.sqrt(nx * nx + ny * ny + nz * nz);
		if (length < 1.0E-6f) {
			return null;
		}
		return new float[]{nx / length, ny / length, nz / length};
	}

	private float[] vertexNormal(int[] normalIndices) {
		if (normalIndices.length == 0) {
			return null;
		}

		float x = 0.0f;
		float y = 0.0f;
		float z = 0.0f;
		for (int index : normalIndices) {
			if (index < 0) {
				return null;
			}
			x += definition.geometry.normals[index * 3];
			y += definition.geometry.normals[index * 3 + 1];
			z += definition.geometry.normals[index * 3 + 2];
		}

		float length = (float) Math.sqrt(x * x + y * y + z * z);
		if (length < 1.0E-6f) {
			return null;
		}
		return new float[]{x / length, y / length, z / length};
	}

	private static float dot(float[] a, float[] b) {
		return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
	}

	private static void reverse(int[] vertices, int[] texCoords, int[] normals) {
		swap(vertices, 1, 3);
		swap(texCoords, 1, 3);
		swap(normals, 1, 3);
	}

	private static void swap(int[] values, int a, int b) {
		int value = values[a];
		values[a] = values[b];
		values[b] = value;
	}
}
