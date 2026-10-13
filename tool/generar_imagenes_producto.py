"""Genera imágenes PNG locales de ejemplo para el catálogo (sin dependencias)."""
import math
import struct
import zlib
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "assets" / "images"
SIZE = 320


def png(pixels):
    raw = b"".join(b"\x00" + bytes(row) for row in pixels)

    def chunk(tag, data):
        crc = zlib.crc32(tag + data) & 0xFFFFFFFF
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", crc)

    ihdr = struct.pack(">IIBBBBB", SIZE, SIZE, 8, 2, 0, 0, 0)
    return b"".join(
        [
            b"\x89PNG\r\n\x1a\n",
            chunk(b"IHDR", ihdr),
            chunk(b"IDAT", zlib.compress(raw, 9)),
            chunk(b"IEND", b""),
        ]
    )


def lerp(a, b, t):
    return int(a + (b - a) * t)


def blend(c1, c2, t):
    return [lerp(c1[i], c2[i], t) for i in range(3)]


def dist(x, y, cx, cy):
    return math.hypot(x - cx, y - cy)


def pizza(toppings):
    cx = cy = SIZE / 2
    r = SIZE * 0.42
    pixels = []
    for y in range(SIZE):
        row = []
        for x in range(SIZE):
            d = dist(x, y, cx, cy)
            if d > r + 10:
                row += [248, 246, 242]
            elif d > r:
                row += [210, 90, 30]
            else:
                t = d / r
                color = blend((255, 204, 80), (232, 140, 40), t * 0.5)
                for tx, ty, rad, col in toppings:
                    if dist(x, y, tx, ty) < rad:
                        color = col
                        break
                row += color
        pixels.append(row)
    return pixels


def bebida(base, highlight):
    pixels = []
    for y in range(SIZE):
        row = []
        for x in range(SIZE):
            if 110 < x < 210 and 40 < y < 280:
                t = (x - 110) / 100
                color = blend(base, highlight, t * 0.4)
            elif 90 < x < 230 and 280 <= y < 300:
                color = [90, 90, 90]
            else:
                color = [248, 246, 242]
            row += color
        pixels.append(row)
    return pixels


def postre(fondo, manchas):
    pixels = []
    for y in range(SIZE):
        row = []
        for x in range(SIZE):
            color = fondo
            for mx, my, rad, col in manchas:
                if dist(x, y, mx, my) < rad:
                    color = col
                    break
            if y < 40 or y > 280 or x < 40 or x > 280:
                color = [248, 246, 242]
            row += color
        pixels.append(row)
    return pixels


def placeholder():
    pixels = []
    cx = cy = SIZE / 2
    for y in range(SIZE):
        row = []
        for x in range(SIZE):
            d = dist(x, y, cx, cy)
            if d < 90:
                row += [211, 47, 47]
            elif d < 110:
                row += [245, 124, 0]
            else:
                row += [238, 238, 238]
        pixels.append(row)
    return pixels


def save(name, pixels):
    path = OUT / name
    path.write_bytes(png(pixels))
    print(path.name, path.stat().st_size)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    pepperoni = [
        (140, 120, 22, [198, 40, 40]),
        (200, 160, 20, [198, 40, 40]),
        (150, 200, 18, [198, 40, 40]),
        (190, 110, 16, [198, 40, 40]),
    ]
    hawaiana = [
        (150, 130, 24, [255, 214, 80]),
        (200, 180, 20, [255, 214, 80]),
        (130, 190, 18, [180, 70, 70]),
        (190, 120, 16, [180, 70, 70]),
    ]
    quesos = [
        (160, 140, 28, [255, 224, 130]),
        (190, 190, 22, [240, 180, 70]),
        (130, 180, 18, [220, 200, 140]),
    ]
    save("pizza_margarita.png", pizza([(170, 150, 14, [46, 125, 50]), (140, 190, 12, [46, 125, 50])]))
    save("pizza_pepperoni.png", pizza(pepperoni))
    save("pizza_hawaiana.png", pizza(hawaiana))
    save("pizza_cuatro_quesos.png", pizza(quesos))
    save("gaseosa.png", bebida((180, 20, 30), (255, 80, 80)))
    save("agua.png", bebida((120, 190, 220), (200, 230, 245)))
    save("brownie.png", postre([92, 48, 30], [(160, 150, 40, [40, 20, 12]), (200, 180, 24, [255, 248, 230])]))
    save("tiramisu.png", postre([210, 170, 120], [(180, 140, 50, [120, 70, 40]), (150, 200, 30, [250, 240, 220])]))
    save("placeholder.png", placeholder())


if __name__ == "__main__":
    main()
