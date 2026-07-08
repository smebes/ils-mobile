// PNG/JPG -> WebP + AVIF (2 boyut) dönüştürücü
// Kullanım: node tools/img_to_webp.mjs masters/ public/img/
// Her görselden: <ad>.webp (768px) + <ad>@2x.webp (1280px) + <ad>.avif (768px)
import sharp from "sharp";
import { readdir, mkdir } from "node:fs/promises";
import path from "node:path";

const [, , inDir = "masters", outDir = "public/img"] = process.argv;
await mkdir(outDir, { recursive: true });

const files = (await readdir(inDir)).filter((f) => /\.(png|jpe?g)$/i.test(f));
if (files.length === 0) {
  console.log(`(${inDir} içinde png/jpg bulunamadı)`);
  process.exit(0);
}

for (const f of files) {
  const name = path.parse(f).name;
  const src = path.join(inDir, f);
  await sharp(src).resize({ width: 768 }).webp({ quality: 80 })
    .toFile(path.join(outDir, `${name}.webp`));
  await sharp(src).resize({ width: 1280 }).webp({ quality: 80 })
    .toFile(path.join(outDir, `${name}@2x.webp`));
  await sharp(src).resize({ width: 768 }).avif({ quality: 55 })
    .toFile(path.join(outDir, `${name}.avif`));
  console.log("✓", name);
}
console.log(`\nBitti → ${outDir} (${files.length} görsel × 3 çıktı)`);
