$ErrorActionPreference='Stop'
$panel=Get-Content (Join-Path $PSScriptRoot 'brake_precise6_panel_cn.ps1') -Raw -Encoding UTF8
$start=$panel.IndexOf('$schema=');$end=$panel.IndexOf('function New-ParameterPacket')
Invoke-Expression $panel.Substring($start,$end-$start)
. (Join-Path $PSScriptRoot 'merged_uart_receive.ps1')
. (Join-Path $PSScriptRoot 'asym_protocol.ps1')
$root=Split-Path $PSScriptRoot -Parent
$results=@{}
foreach($name in @('20261029_214130_897.txt','20261029_214014_383.txt')) {
    $raw=[IO.File]::ReadAllText((Join-Path $root ('evidence/uart_fix_20261029/'+$name)),[Text.Encoding]::ASCII)
    $expected=([regex]::Matches($raw,'VIS=6 [^\r\n]*')).Count
    if($expected -eq 0){throw 'No actual VIS records in fixture'}
    foreach($chunk in @(1,7,31,256,4096)) {
        $buffer='';$accepted=0;$oldAccepted=0
        for($offset=0;$offset -lt $raw.Length;$offset+=$chunk) {
            $buffer+=$raw.Substring($offset,[Math]::Min($chunk,$raw.Length-$offset))
            while($buffer.Contains("`n")) {
                $at=$buffer.IndexOf("`n");$line=$buffer.Substring(0,$at).Trim();$buffer=$buffer.Substring($at+1)
                if(Convert-Record $line){$oldAccepted++}
                $candidate=Get-MergedTelemetryLine $line
                if(Convert-Record $candidate){$accepted++}
            }
        }
        if($accepted -ne $expected -or $oldAccepted -ne 0){throw "Unexpected replay: $name chunk=$chunk accepted=$accepted expected=$expected old=$oldAccepted"}
    }
    $results[$name]=$expected
    $sample=[regex]::Match($raw,'VIS=6 [^\r\n]*').Value
}
foreach($bad in @($sample.Substring(0,$sample.Length-4),($sample+'BAD'),$sample.Replace(' BX=',' BX=X'),$sample.Replace('VIS=6','VIS=5'))) {
    if(Convert-Record (Get-MergedTelemetryLine ([string][char]0+$bad))){throw 'Corrupt/truncated/old VIS accepted'}
}
$fixture=(Get-Content (Join-Path $PSScriptRoot 'asym_diag_fixture.txt') -Raw).Trim()
if(!(Convert-CascadeDiagnostic (Get-MergedTelemetryLine $fixture))){throw 'Valid D2 rejected'}
if(Convert-CascadeDiagnostic (Get-MergedTelemetryLine ($fixture.Substring(0,144)+'FF'))){throw 'Bad D2 XOR accepted'}
Write-Output ('MERGED_UART_REPLAY_PASS '+($results|ConvertTo-Json -Compress)+' chunk1/7/31/256/4096; corrupt/old/truncated rejected; D2 XOR unchanged')
