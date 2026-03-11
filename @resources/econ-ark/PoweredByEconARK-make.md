# PoweredByEconARK Badge Generation via Shields.io

This document describes the process used to generate the "Powered by Econ-ARK" badges using [Shields.io](https://shields.io), a free service for generating consistent, high-quality badges.

## Overview

Shields.io provides dynamic badge generation with consistent styling, making it ideal for README files and documentation. We use shields.io to generate badges that match the visual style of other badges in the project (DOI, Docker, License, etc.).

## Badge Specifications

- **Text**: "Powered by" (left) / "Econ-ARK" (right)
- **Left Background Color**: `#4D4D4D` (dark grey)
- **Right Background Color**: `#3296BE` (teal-blue)
- **Style**: Flat (no rounded corners or shadows)
- **Dimensions**: Auto-sized by shields.io (typically ~140x20px for PNG)

## Shields.io URL Format

### Base URL Structure

Shields.io uses a specific URL format for badges:

```
https://img.shields.io/badge/{label}-{message}-{color}?{parameters}
```

### Our Badge URLs

#### SVG Format (Vector, Default)
```
https://img.shields.io/badge/Powered_by-Econ--ARK-3296BE?style=flat&labelColor=4D4D4D.svg
```

#### PNG Format (Raster)
```
https://raster.shields.io/badge/Powered_by-Econ--ARK-3296BE?style=flat&labelColor=4D4D4D.png
```

**Note**: PNG badges use the `raster.shields.io` subdomain instead of `img.shields.io`.

### URL Components Explained

1. **Label**: `Powered_by` (underscores become spaces)
2. **Message**: `Econ--ARK` (double hyphens become a single hyphen in the badge)
3. **Color**: `3296BE` (hex color without `#` symbol)
4. **Parameters**:
   - `style=flat` - Removes rounded corners and shadows
   - `labelColor=4D4D4D` - Sets the left section background color

## Generation Process

### Step 1: Download SVG Badge

The SVG format is the default and provides the best quality for web use:

```bash
curl -o PoweredByEconARK-shields.svg \
  "https://img.shields.io/badge/Powered_by-Econ--ARK-3296BE?style=flat&labelColor=4D4D4D.svg"
```

### Step 2: Download PNG Badge

For raster formats, use the `raster.shields.io` endpoint:

```bash
curl -o PoweredByEconARK-shields.png \
  "https://raster.shields.io/badge/Powered_by-Econ--ARK-3296BE?style=flat&labelColor=4D4D4D.png"
```

### Step 3: Convert to Additional Formats

Shields.io provides SVG and PNG natively. Other formats can be generated from the PNG:

#### JPG Conversion (using Python PIL/Pillow)

```python
from PIL import Image

img = Image.open('PoweredByEconARK-shields.png')
# Convert RGBA to RGB if needed
if img.mode == 'RGBA':
    rgb_img = Image.new('RGB', img.size, (255, 255, 255))
    rgb_img.paste(img, mask=img.split()[3])
    img = rgb_img
img.save('PoweredByEconARK-shields.jpg', 'JPEG', quality=95)
```

#### PDF Conversion (using Python PIL/Pillow)

```python
from PIL import Image

img = Image.open('PoweredByEconARK-shields.png')
# Convert RGBA to RGB if needed
if img.mode == 'RGBA':
    rgb_img = Image.new('RGB', img.size, (255, 255, 255))
    rgb_img.paste(img, mask=img.split()[3])
    img = rgb_img
img.save('PoweredByEconARK-shields.pdf', 'PDF')
```

#### XBB File Generation (for LaTeX)

The XBB (bounding box) file is used by LaTeX to properly size images:

```python
from PIL import Image

img = Image.open('PoweredByEconARK-shields.png')
w, h = img.size

xbb_content = f"""%%Title: PoweredByEconARK-shields.png
%%Creator: shields.io + extractbb
%%BoundingBox: 0 0 {w} {h}
%%HiResBoundingBox: 0.000000 0.000000 {w}.000000 {h}.000000
"""

with open('PoweredByEconARK-shields.xbb', 'w') as f:
    f.write(xbb_content)
```

## Color Format Notes

### Important: Hex Color Format

Shields.io expects hex colors **without** the `#` symbol in the URL:
- ✅ Correct: `3296BE`
- ❌ Incorrect: `#3296BE` or `%233296BE`

### Color Discovery Process

During initial badge generation, we discovered that shields.io interprets colors in the badge message position (`-3296BE`) as the right-side background color. The left-side color is controlled by the `labelColor` parameter.

**Working URL Format**:
```
Powered_by-Econ--ARK-3296BE?style=flat&labelColor=4D4D4D
```

This format:
- Sets the right side to `#3296BE` (via `-3296BE` in the message)
- Sets the left side to `#4D4D4D` (via `labelColor=4D4D4D`)

## Complete Generation Script

Here's a complete Python script that downloads and converts badges to all formats:

```python
import urllib.request
from PIL import Image
import os

# Base badge parameters
badge_params = "Powered_by-Econ--ARK-3296BE?style=flat&labelColor=4D4D4D"

# 1. Download SVG
svg_url = f"https://img.shields.io/badge/{badge_params}.svg"
urllib.request.urlretrieve(svg_url, "PoweredByEconARK-shields.svg")
print("✅ SVG downloaded")

# 2. Download PNG
png_url = f"https://raster.shields.io/badge/{badge_params}.png"
urllib.request.urlretrieve(png_url, "PoweredByEconARK-shields.png")
print("✅ PNG downloaded")

# 3. Convert PNG to JPG
img = Image.open("PoweredByEconARK-shields.png")
if img.mode == 'RGBA':
    rgb_img = Image.new('RGB', img.size, (255, 255, 255))
    rgb_img.paste(img, mask=img.split()[3])
    img = rgb_img
img.save("PoweredByEconARK-shields.jpg", "JPEG", quality=95)
print("✅ JPG created")

# 4. Convert PNG to PDF
img.save("PoweredByEconARK-shields.pdf", "PDF")
print("✅ PDF created")

# 5. Generate XBB file
w, h = img.size
with open("PoweredByEconARK-shields.xbb", 'w') as f:
    f.write(f"""%%Title: PoweredByEconARK-shields.png
%%Creator: shields.io + extractbb
%%BoundingBox: 0 0 {w} {h}
%%HiResBoundingBox: 0.000000 0.000000 {w}.000000 {h}.000000
""")
print("✅ XBB created")
```

## File Outputs

After running the generation process, the following files are created:

- `PoweredByEconARK-shields.svg` - Vector format (best for web/README)
- `PoweredByEconARK-shields.png` - Raster PNG (~140x20px)
- `PoweredByEconARK-shields.jpg` - JPEG conversion
- `PoweredByEconARK-shields.pdf` - PDF conversion
- `PoweredByEconARK-shields.xbb` - LaTeX bounding box file

## Usage in README.md

The SVG badge is used in `README.md`:

```markdown
[![Powered by Econ-ARK](https://img.shields.io/badge/Powered_by-Econ--ARK-3296BE?style=flat&labelColor=4D4D4D&color=3296BE)](https://econ-ark.org)
```

This provides:
- Dynamic badge generation (always up-to-date)
- Consistent styling with other badges
- Scalable vector format
- No local file maintenance

## Advantages of Shields.io

1. **Consistency**: Matches the style of other badges (DOI, Docker, License)
2. **No Maintenance**: Badges are generated dynamically
3. **Free**: No cost or API key required
4. **Reliable**: Shields.io is a well-established service
5. **Flexible**: Easy to update colors or text via URL parameters

## References

- [Shields.io Homepage](https://shields.io)
- [Shields.io Badge Builder](https://shields.io/badges)
- [Shields.io Documentation](https://github.com/badges/shields)
- [Shields.io Static Badge Format](https://shields.io/badges/static-badge)

## Notes on Color Rendering

Shields.io applies a subtle gradient overlay to badges, which may cause rendered colors to appear slightly different from the specified hex values. This is a design feature of shields.io badges and ensures visual consistency across the platform.

The badge dimensions are automatically calculated by shields.io based on text length and font size, typically resulting in approximately 140x20px for the PNG version.
