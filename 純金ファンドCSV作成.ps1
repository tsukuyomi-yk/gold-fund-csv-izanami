$ErrorActionPreference = "Stop"

$rawFile = "junkin_raw.csv"
$outFile = "junkin_izanami.csv"

$url = "https://fs.bk.mufg.jp/webasp/mufg/fund/detail/chart/csv/m00340220.csv"

$response = Invoke-WebRequest `
    -Uri $url `
    -Headers @{
        "User-Agent" = "Mozilla/5.0"
        "Referer" = "https://fs.bk.mufg.jp/webasp/mufg/fund/detail/chart/m00340220.html"
    }

$encoding = [System.Text.Encoding]::GetEncoding(932)
$csvText = $encoding.GetString($response.Content)
$rows = $csvText | ConvertFrom-Csv | Sort-Object "年月日"

$raw = @()
$raw += "Date,Price"

$out = @()
$out += "Date,Open,High,Low,Close,Volume"

$count = 0

foreach ($row in $rows) {
    $date = $row."年月日".Trim()
    $price = $row."基準価額（円）".Trim()

    if ($date -notmatch "^\d{4}-\d{2}-\d{2}$") {
        continue
    }

    if ($price -notmatch "^\d+$") {
        continue
    }

    $date = $date.Replace("-", "/")

    $raw += ("{0},{1}" -f $date, $price)
    $out += ("{0},{1},{1},{1},{1},0" -f $date, $price)

    $count++
}

$raw | Set-Content $rawFile -Encoding Default
$out | Set-Content $outFile -Encoding Default

Write-Host "Done."
Write-Host ("Count: {0}" -f $count)
Write-Host $rawFile
Write-Host $outFile
