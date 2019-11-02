$BaseFolder = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

$VerbNoun = '*-*'

Get-ChildItem "$($BaseFolder)/internals/*.ps1" | Resolve-Path | ForEach-Object { . $_ }

$Functions = Get-ChildItem -Path (Join-Path $BaseFolder "/externals") -Filter '*-*' -File
foreach ($f in $Functions) {
    Write-Verbose -Message ("Importing function {0}." -f $f.FullName)
    . $f.FullName
}

Export-ModuleMember -Function $VerbNoun