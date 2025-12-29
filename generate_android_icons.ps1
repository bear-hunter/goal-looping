Add-Type -AssemblyName System.Drawing

# Source image
$sourceImage = "assets\icon\app_icon.png"

# Android adaptive icon sizes (foreground and background)
$androidSizes = @{
    "mdpi" = 108
    "hdpi" = 162
    "xhdpi" = 216
    "xxhdpi" = 324
    "xxxhdpi" = 432
}

# Load source image
$img = [System.Drawing.Image]::FromFile((Resolve-Path $sourceImage).Path)

# Generate Android adaptive icon backgrounds (full gradient fills entire space)
foreach ($density in $androidSizes.Keys) {
    $size = $androidSizes[$density]
    $outputPath = "android\app\src\main\res\mipmap-$density\ic_launcher_background.png"
    
    # Create resized image
    $resized = New-Object System.Drawing.Bitmap $size, $size
    $graphics = [System.Drawing.Graphics]::FromImage($resized)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.DrawImage($img, 0, 0, $size, $size)
    
    # Save resized image (create full path, don't use Resolve-Path on non-existent file)
    $fullPath = Join-Path (Get-Location) $outputPath
    $resized.Save($fullPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $graphics.Dispose()
    $resized.Dispose()
    
    Write-Host "Created $outputPath ($size x $size)"
}

# Generate Android adaptive icon foregrounds (same as background for our design)
foreach ($density in $androidSizes.Keys) {
    $size = $androidSizes[$density]
    $outputPath = "android\app\src\main\res\mipmap-$density\ic_launcher_foreground.png"
    
    # Create resized image
    $resized = New-Object System.Drawing.Bitmap $size, $size
    $graphics = [System.Drawing.Graphics]::FromImage($resized)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.DrawImage($img, 0, 0, $size, $size)
    
    # Save resized image
    $fullPath = Join-Path (Get-Location) $outputPath
    $resized.Save($fullPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $graphics.Dispose()
    $resized.Dispose()
    
    Write-Host "Created $outputPath ($size x $size)"
}

# Also keep the regular ic_launcher.png for older Android versions
$legacySizes = @{
    "mdpi" = 48
    "hdpi" = 72
    "xhdpi" = 96
    "xxhdpi" = 144
    "xxxhdpi" = 192
}

foreach ($density in $legacySizes.Keys) {
    $size = $legacySizes[$density]
    $outputPath = "android\app\src\main\res\mipmap-$density\ic_launcher.png"
    
    # Create resized image
    $resized = New-Object System.Drawing.Bitmap $size, $size
    $graphics = [System.Drawing.Graphics]::FromImage($resized)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.DrawImage($img, 0, 0, $size, $size)
    
    # Save resized image
    $fullPath = Join-Path (Get-Location) $outputPath
    $resized.Save($fullPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $graphics.Dispose()
    $resized.Dispose()
    
    Write-Host "Created $outputPath ($size x $size)"
}

$img.Dispose()
Write-Host "`nAll Android adaptive icons generated successfully!"
Write-Host "Foreground and background layers created for adaptive icon support (Android 8.0+)"
