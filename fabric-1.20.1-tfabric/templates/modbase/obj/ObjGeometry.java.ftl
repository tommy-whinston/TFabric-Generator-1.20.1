package ${package}.client.obj;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Minimal OBJ parser. Supports v/vt/vn, polygonal faces, negative indices and
 * the common face index forms (v, v/vt, v//vn, v/vt/vn).
 */
public final class ObjGeometry {
	public final float[] positions;
	public final float[] uvs;
	public final float[] normals;
	public final List<Face> faces;

	private ObjGeometry(float[] positions, float[] uvs, float[] normals, List<Face> faces) {
		this.positions = positions;
		this.uvs = uvs;
		this.normals = normals;
		this.faces = faces;
	}

	public static final class Face {
		public final int[] vertices;
		public final int[] texCoords;
		public final int[] normals;
		public final String material;

		Face(int[] vertices, int[] texCoords, int[] normals, String material) {
			this.vertices = vertices;
			this.texCoords = texCoords;
			this.normals = normals;
			this.material = material;
		}
	}

	public static ObjGeometry parse(BufferedReader reader) throws IOException {
		List<float[]> positions = new ArrayList<>();
		List<float[]> uvs = new ArrayList<>();
		List<float[]> normals = new ArrayList<>();
		List<Face> faces = new ArrayList<>();
		String currentMaterial = "";

		String line;
		while ((line = reader.readLine()) != null) {
			line = line.trim();
			if (line.isEmpty() || line.charAt(0) == '#') {
				continue;
			}

			String[] parts = line.split("\\s+");
			switch (parts[0]) {
				case "v" -> {
					require(parts, 4, line);
					positions.add(new float[]{Float.parseFloat(parts[1]), Float.parseFloat(parts[2]), Float.parseFloat(parts[3])});
				}
				case "vt" -> {
					require(parts, 2, line);
					float u = Float.parseFloat(parts[1]);
					float v = parts.length > 2 ? Float.parseFloat(parts[2]) : 0.0f;
					uvs.add(new float[]{u, v});
				}
				case "vn" -> {
					require(parts, 4, line);
					normals.add(new float[]{Float.parseFloat(parts[1]), Float.parseFloat(parts[2]), Float.parseFloat(parts[3])});
				}
				case "f" -> parseFace(parts, positions.size(), uvs.size(), normals.size(), faces, currentMaterial, line);
				case "usemtl" -> {
					if (parts.length > 1) {
						currentMaterial = parts[1];
					}
				}
				default -> {
					// mtllib, o, g, s, l, p ... are not needed here
				}
			}
		}

		return new ObjGeometry(flatten3(positions), flatten2(uvs), flatten3(normals), faces);
	}

	private static void parseFace(String[] parts, int positionCount, int uvCount, int normalCount, List<Face> faces, String material,
			String line) throws IOException {
		int count = parts.length - 1;
		if (count < 3) {
			throw new IOException("Face with less than 3 vertices: " + line);
		}

		int[] vertices = new int[count];
		int[] texCoords = new int[count];
		int[] normals = new int[count];

		for (int i = 0; i < count; i++) {
			String[] index = parts[i + 1].split("/", -1);
			vertices[i] = resolveIndex(index[0], positionCount, line);
			texCoords[i] = index.length > 1 && !index[1].isEmpty() ? resolveIndex(index[1], uvCount, line) : -1;
			normals[i] = index.length > 2 && !index[2].isEmpty() ? resolveIndex(index[2], normalCount, line) : -1;
		}

		faces.add(new Face(vertices, texCoords, normals, material));
	}

	private static int resolveIndex(String raw, int count, String line) throws IOException {
		int index;
		try {
			index = Integer.parseInt(raw);
		} catch (NumberFormatException e) {
			throw new IOException("Invalid index '" + raw + "' in: " + line);
		}

		if (index < 0) {
			index = count + index;
		} else {
			index -= 1;
		}

		if (index < 0 || index >= count) {
			throw new IOException("Index out of range '" + raw + "' in: " + line);
		}
		return index;
	}

	private static void require(String[] parts, int count, String line) throws IOException {
		if (parts.length < count) {
			throw new IOException("Malformed line: " + line);
		}
	}

	private static float[] flatten3(List<float[]> values) {
		float[] result = new float[values.size() * 3];
		for (int i = 0; i < values.size(); i++) {
			float[] value = values.get(i);
			result[i * 3] = value[0];
			result[i * 3 + 1] = value[1];
			result[i * 3 + 2] = value[2];
		}
		return result;
	}

	private static float[] flatten2(List<float[]> values) {
		float[] result = new float[values.size() * 2];
		for (int i = 0; i < values.size(); i++) {
			float[] value = values.get(i);
			result[i * 2] = value[0];
			result[i * 2 + 1] = value[1];
		}
		return result;
	}
}
