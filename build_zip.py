import os
import zipfile

root = os.path.dirname(os.path.abspath(__file__))
out = os.path.join(root, "TFabric-Generator-1.20.1.zip")

excluded_files = {"build_zip.py", ".gitignore"}
excluded_dirs = {".git", "__pycache__", ".github", "tools"}

if os.path.exists(out):
    os.remove(out)

with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as archive:
    for base, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if d not in excluded_dirs]
        for name in files:
            if name in excluded_files or name.endswith(".zip") or name.endswith(".pyc"):
                continue
            full = os.path.join(base, name)
            rel = os.path.relpath(full, root).replace(os.sep, "/")
            archive.write(full, rel)

print(out)
