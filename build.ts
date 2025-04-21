#!/usr/bin/env -S deno run --allow-read --allow-write
// vi: ft=typescript

import { zip } from "jsr:@deno-library/compress";
import { join } from "jsr:@std/path";
import { ensureDir } from "jsr:@std/fs";
import { walk } from "jsr:@std/fs/walk";

const dirs = {
    project2d: new URL("./starter-files/2d-project-start", import.meta.url).pathname,
    project3d: new URL("./starter-files/3d-project-assets", import.meta.url).pathname,
    temp2D: await Deno.makeTempDir({ prefix: '2d' }),
    temp3D: await Deno.makeTempDir({ prefix: '3d' }),
    out: new URL("./dist", import.meta.url).pathname,
}


await Deno.remove(dirs.out, { recursive: true });
await ensureDir(dirs.out);


const zipDirectory = async (dir: string, outDir: string, skip?: RegExp) => {
    for await (const dirEntry of walk(dir)) {
        if (dirEntry.isFile) {
            const relativePath = dirEntry.path.replace(dir, "");
            if (skip && skip.test(relativePath)) {
                continue;
            }
            const destPath = join(outDir, relativePath);
            await ensureDir(new URL("..", destPath));
            await Deno.copyFile(dirEntry.path, destPath);
        }
    }
    const tmpFileName = await Deno.makeTempFile({ prefix: 'zip' });
    await zip.compress(outDir, tmpFileName, { excludeSrc: true })
    return tmpFileName;
}

const zip2D = await zipDirectory(dirs.project2d, dirs.temp2D);
await Deno.copyFile(zip2D, join(dirs.out, "2d-project.zip"));
const zip3D = await zipDirectory(dirs.project3d, dirs.temp3D, /(\.import)|project\.godot/);
await Deno.copyFile(zip3D, join(dirs.out, "3d-project.zip"));