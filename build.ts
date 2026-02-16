#!/usr/bin/env -S deno run --allow-read --allow-write --allow-run
// vi: ft=typescript

//** * This script zips the 2D and 3D starter files by copying their contents to a temporary directory
// * and then creating a zip file using the external zip command.
import { join } from "jsr:@std/path";
import { ensureDir } from "jsr:@std/fs";
import { walk } from "jsr:@std/fs/walk";

const dirs = {
  project2dStart:
    new URL("./starter-files/2d-project-start", import.meta.url).pathname,
  project3dStart:
    new URL("./starter-files/3d-project-assets", import.meta.url).pathname,
  project2DCompleted:
    new URL("./2d-project-completed", import.meta.url).pathname,
  project3DCompleted:
    new URL("./3d-project-completed", import.meta.url).pathname,
  out: new URL("./dist", import.meta.url).pathname,
};

//** * This function copies a directory's contents to a temporary location and creates a zip file, using the unix `zip` command.
// * @param dir - The directory to zip.
// * @param outputZipPath - The path where the zip file will be saved.
// * @param skip - An array of regexes to skip files that match.
// * @returns The path to the zip file.
const createProjectZip = async (
  dir: string,
  outputZipPath: string,
  skip: RegExp[] = [],
) => {
  console.log(`Processing directory: ${dir}`);
  const tempDir = await Deno.makeTempDir({ prefix: "project-zip-" });

  // Copy and count files to zip to temporary directory
  let fileCount = 0;
  for await (
    const dirEntry of walk(dir, {
      skip: skip,
    })
  ) {
    if (dirEntry.isFile) {
      const relativePath = dirEntry.path.replace(dir, "");
      const destPath = join(tempDir, relativePath);
      await ensureDir(join(destPath, ".."));
      await Deno.copyFile(dirEntry.path, destPath);
      fileCount += 1;
    }
  }

  console.log(`Copied ${fileCount} files to temporary directory`);

  const zipCommand = new Deno.Command("zip", {
    args: ["-r", outputZipPath, "."],
    cwd: tempDir,
  });
  const output = await zipCommand.output();
  if (!output.success) {
    throw new Error(
      `Failed to create zip file ${outputZipPath}: ${output.stderr}`,
    );
  }

  await Deno.remove(tempDir, { recursive: true });
  console.log(`Created zip file at: ${outputZipPath}`);
  return outputZipPath;
};

const outDirExists = await Deno.stat(dirs.out).then(() => true).catch(() =>
  false
);
if (outDirExists) {
  await Deno.remove(dirs.out, { recursive: true });
}
await ensureDir(dirs.out);

// Zip the starter files, excluding .import and project.godot files
const output2DPath = join(dirs.out, "2d-project-assets.zip");
const output3DPath = join(dirs.out, "3d-project-assets.zip");
await createProjectZip(
  dirs.project2dStart,
  output2DPath,
  [/\.(import)/],
);
console.log(`2D project zip created at: ${output2DPath}`);
await createProjectZip(
  dirs.project3dStart,
  output3DPath,
  [/\.(import)/, /project\.godot/],
);
console.log(`3D project zip created at: ${output3DPath}`);

// Now create completed project zips, only exclude .godot/ cache folders
const output2DCompletedPath = join(dirs.out, "2d-project-completed.zip");
const output3DCompletedPath = join(dirs.out, "3d-project-completed.zip");
await createProjectZip(
  dirs.project2DCompleted,
  output2DCompletedPath,
  [/\.godot\//],
);
console.log(`2D completed project zip created at: ${output2DCompletedPath}`);

await createProjectZip(
  dirs.project3DCompleted,
  output3DCompletedPath,
  [/\.godot\//],
);
console.log(`3D completed project zip created at: ${output3DCompletedPath}`);

console.log("Build completed successfully!");
