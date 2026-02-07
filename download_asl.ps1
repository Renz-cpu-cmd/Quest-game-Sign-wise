$baseUrl = "https://www.lifeprint.com/asl101/fingerspelling/abc-gifs/"
$outputDir = "assets/images/asl"

if (!(Test-Path -Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$start = 97
$end = 122

for ($i = $start; $i -le $end; $i++) {
    $char = [char]$i
    $filename = $char + ".gif"
    $url = $baseUrl + $filename
    $outfile = $outputDir + "\" + $filename
    
    Write-Output ("Downloading " + $char + " to " + $outfile + "...")
    try {
        Invoke-WebRequest -Uri $url -OutFile $outfile
    } catch {
        Write-Output ("Failed to download " + $char)
    }
}

Write-Output "Download complete."
