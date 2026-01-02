#!/bin/bash
# Convert PNG images to WebP format for APK size reduction
# WebP provides 30-50% smaller files with similar quality
# Run this script from the project root

set -e

ASSETS_DIR="assets/images/trees"
OUTPUT_DIR="assets/images/trees_webp"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Converting tree images to WebP format..."
echo "This requires 'cwebp' from libwebp-tools"
echo ""

# Check if cwebp is installed
if ! command -v cwebp &> /dev/null; then
    echo "Error: cwebp not found. Install with:"
    echo "  Fedora/RHEL: sudo dnf install libwebp-tools"
    echo "  Ubuntu/Debian: sudo apt-get install webp"
    echo "  macOS: brew install webp"
    exit 1
fi

# Convert each PNG to WebP
for png in "$ASSETS_DIR"/*.png; do
    filename=$(basename "$png" .png)
    output="$OUTPUT_DIR/${filename}.webp"
    
    echo "Converting: $filename.png -> $filename.webp"
    
    # Quality 85 provides good balance of size vs quality
    # Use lossless for images with transparency
    cwebp -q 85 -alpha_q 90 "$png" -o "$output"
done

echo ""
echo "Conversion complete!"
echo ""

# Show size comparison
echo "Size comparison:"
echo "================"

total_png=0
total_webp=0

for png in "$ASSETS_DIR"/*.png; do
    filename=$(basename "$png" .png)
    webp="$OUTPUT_DIR/${filename}.webp"
    
    png_size=$(stat -c%s "$png" 2>/dev/null || stat -f%z "$png")
    webp_size=$(stat -c%s "$webp" 2>/dev/null || stat -f%z "$webp")
    
    savings=$((100 - (webp_size * 100 / png_size)))
    
    echo "$filename: $(numfmt --to=iec-i --suffix=B $png_size) -> $(numfmt --to=iec-i --suffix=B $webp_size) ($savings% smaller)"
    
    total_png=$((total_png + png_size))
    total_webp=$((total_webp + webp_size))
done

echo ""
echo "Total PNG: $(numfmt --to=iec-i --suffix=B $total_png)"
echo "Total WebP: $(numfmt --to=iec-i --suffix=B $total_webp)"
total_savings=$((100 - (total_webp * 100 / total_png)))
echo "Total savings: $total_savings%"
echo ""
echo "To use WebP images:"
echo "1. Move files from $OUTPUT_DIR to $ASSETS_DIR"
echo "2. Update image references in code from .png to .webp"
echo "3. Or use the AssetOptimizer utility class"
