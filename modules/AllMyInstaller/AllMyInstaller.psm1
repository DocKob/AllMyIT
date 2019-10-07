$BaseFolder = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent

$VerbNoun = '*-*'
$Functions = Get-ChildItem -Path $PSScriptRoot -Filter $VerbNoun
foreach ($f in $Functions) {
    Write-Verbose -Message ("Importing function {0}." -f $f.FullName)
    . $f.FullName
}
Export-ModuleMember -Function $VerbNoun