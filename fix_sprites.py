#!/usr/bin/env python3
"""
fix_sprites.py — Remove white backgrounds and normalize canvas for all animation PNGs.

Usage: python3 fix_sprites.py [--dry-run]
"""

import glob
import os
import sys
from collections import deque
from PIL import Image

WHITE_THRESHOLD = 235
CANVAS_SIZE = 1024
CONTENT_SCALE = 0.80  # character occupies 80% of canvas height at most


def remove_white_bg(img: Image.Image) -> Image.Image:
    """Flood-fill from all 4 corners to remove white/near-white background pixels."""
    img = img.convert("RGBA")
    data = img.load()
    w, h = img.size

    def is_white(x, y):
        r, g, b, a = data[x, y]
        return a > 10 and r > WHITE_THRESHOLD and g > WHITE_THRESHOLD and b > WHITE_THRESHOLD

    visited = [[False] * h for _ in range(w)]
    queue = deque()

    # Seed from all 4 corners
    for sx, sy in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]:
        if is_white(sx, sy) and not visited[sx][sy]:
            queue.append((sx, sy))
            visited[sx][sy] = True

    # Also seed from entire border to catch background that doesn't reach corners
    for x in range(w):
        for y in [0, h - 1]:
            if is_white(x, y) and not visited[x][y]:
                queue.append((x, y))
                visited[x][y] = True
    for y in range(h):
        for x in [0, w - 1]:
            if is_white(x, y) and not visited[x][y]:
                queue.append((x, y))
                visited[x][y] = True

    # BFS
    while queue:
        x, y = queue.popleft()
        r, g, b, a = data[x, y]
        data[x, y] = (r, g, b, 0)  # make transparent
        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            nx, ny = x + dx, y + dy
            if 0 <= nx < w and 0 <= ny < h and not visited[nx][ny] and is_white(nx, ny):
                visited[nx][ny] = True
                queue.append((nx, ny))

    return img


def normalize_canvas(img: Image.Image, canvas: int = CANVAS_SIZE) -> Image.Image:
    """Crop to non-transparent bounding box, scale uniformly, bottom-center align."""
    bbox = img.getbbox()
    if bbox is None:
        return img  # fully transparent — skip

    cropped = img.crop(bbox)
    cw, ch = cropped.size

    max_dim = canvas * CONTENT_SCALE
    scale = min(max_dim / cw, max_dim / ch)
    nw, nh = int(cw * scale), int(ch * scale)

    # Use NEAREST to preserve pixel art crispness
    resized = cropped.resize((nw, nh), Image.NEAREST)

    out = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    x = (canvas - nw) // 2   # horizontally centered
    y = canvas - nh           # bottom-aligned
    out.paste(resized, (x, y), resized)
    return out


def process(path: str, dry_run: bool = False) -> str:
    try:
        img = Image.open(path)
        original_mode = img.mode

        img = remove_white_bg(img)
        img = normalize_canvas(img)

        if not dry_run:
            img.save(path, "PNG")
        return f"  OK  {path}"
    except Exception as e:
        return f"  ERR {path}: {e}"


def main():
    dry_run = "--dry-run" in sys.argv
    base = os.path.dirname(os.path.abspath(__file__))
    pattern = os.path.join(base, "assets", "images", "animations", "**", "*.png")
    paths = sorted(glob.glob(pattern, recursive=True))

    if not paths:
        print("No PNGs found under assets/images/animations/")
        sys.exit(1)

    print(f"{'[DRY RUN] ' if dry_run else ''}Processing {len(paths)} PNGs...")
    for path in paths:
        print(process(path, dry_run))

    print(f"\nDone. {len(paths)} files {'checked' if dry_run else 'updated'}.")


if __name__ == "__main__":
    main()
