# Keep the existing strict VIS schema and D2 checksum validation. A missing
# diagnostic newline must not hide an otherwise complete VIS packet.
function Get-MergedTelemetryLine([string]$Line) {
    $at=$Line.LastIndexOf('VIS=6 ',[StringComparison]::Ordinal)
    if($at -gt 0) {
        $candidate=$Line.Substring($at)
        if(Convert-Record $candidate) { return $candidate }
    }
    return $Line
}
