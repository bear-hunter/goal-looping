Add-Type -AssemblyName System.Drawing

# Source image
$sourceImage = "assets\icon\app_icon.png"

# Icon sizes for Android
$androidSizes = @{
    "mdpi" = 48
    "hdpi" = 72
    "xhdpi" = 96
    "xxhdpi" = 144
    "xxxhdpi" = 192
}

# Load source image
$img = [System.Drawing.Image]::FromFile((Resolve-Path $sourceImage).Path)

# Generate Android icons
foreach ($density in $androidSizes.Keys) {
    $size = $androidSizes[$density]
    $outputPath = "android\app\src\main\res\mipmap-$density\ic_launcher.png"
    
    # Create resized image
    $resized = New-Object System.Drawing.Bitmap $size, $size
    $graphics = [System.Drawing.Graphics]::FromImage($resized)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.DrawImage($img, 0, 0, $size, $size)
    
    # Save resized image
    $resized.Save((Resolve-Path $outputPath).Path, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $graphics.Dispose()
    $resized.Dispose()
    
    Write-Host "Created $outputPath ($size x $size)"
}

# iOS icons need specific sizes based on Contents.json
# We'll need to update the Contents.json file separately
$iosSizes = @(
    @{size=20; scale=1; name="Icon-App-20x20@1x.png"},
    @{size=40; scale=2; name="Icon-App-20x20@2x.png"},
    @{size=60; scale=3; name="Icon-App-20x20@3x.png"},
    @{size=29; scale=1; name="Icon-App-29x29@1x.png"},
    @{size=58; scale=2; name="Icon-App-29x29@2x.png"},
    @{size=87; scale=3; name="Icon-App-29x29@3x.png"},
    @{size=40; scale=1; name="Icon-App-40x40@1x.png"},
    @{size=80; scale=2; name="Icon-App-40x40@2x.png"},
    @{size=120; scale=3; name="Icon-App-40x40@3x.png"},
    @{size=60; scale=1; name="Icon-App-60x60@1x.png"},
    @{size=120; scale=2; name="Icon-App-60x60@2x.png"},
    @{size=180; scale=3; name="Icon-App-60x60@3x.png"},
    @{size=76; scale=1; name="Icon-App-76x76@1x.png"},
    @{size=152; scale=2; name="Icon-App-76x76@2x.png"},
    @{size=167; scale=2; name="Icon-App-83.5x83.5@2x.png"},
    @{size=1024; scale=1; name="Icon-App-1024x1024@1x.png"}
)

# Generate iOS icons
$iosIconPath = "ios\Runner\Assets.xcassets\AppIcon.appiconset"
foreach ($iconSpec in $iosSizes) {
    $size = $iconSpec.size
    $name = $iconSpec.name
    $outputPath = Join-Path $iosIconPath $name
    
    # Create resized image
    $resized = New-Object System.Drawing.Bitmap $size, $size
    $graphics = [System.Drawing.Graphics]::FromImage($resized)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.DrawImage($img, 0, 0, $size, $size)
    
    # Save resized image
    $resized.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $graphics.Dispose()
    $resized.Dispose()
    
    Write-Host "Created $outputPath ($size x $size)"
}

$img.Dispose()

Write-Host "`nAll app icons generated successfully!"
