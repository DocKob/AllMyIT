$BaseFolder = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

$VerbNoun = '*-*'

Get-ChildItem "$($BaseFolder)/private/*.ps1" | Resolve-Path | ForEach-Object { . $_ }

$Functions = Get-ChildItem -Path (Join-Path $BaseFolder "/public") -Filter '*-*' -File
foreach ($f in $Functions) {
    Write-Verbose -Message ("Importing function {0}." -f $f.FullName)
    . $f.FullName
}

Export-ModuleMember -Function $VerbNoun