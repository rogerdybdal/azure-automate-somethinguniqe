#Ta kortstokk URL som parameter, evt bruk default
[CmdletBinding()]
param (
    # parameter er ikke obligatorisk siden vi har default verdi
    [Parameter(HelpMessage = "URL til kortstokk", Mandatory = $false)]
    [string]
    # når paramater ikke er gitt brukes default verdi
    $UrlKortstokk = 'http://nav-deckofcards.herokuapp.com/shuffle'
)

#Stopp skriptet ved feil
$ErrorActionPreference = 'Stop'

#Forsøk å hente kortstokk fra Url, gi feilmelding dersom dette ikke går
try {
    $webRequest = Invoke-WebRequest -Uri $UrlKortstokk
    $kortstokkJson = $webRequest.Content
    $kortstokk = ConvertFrom-Json -InputObject $kortstokkJson 
}catch{
    Write-Host "Fant ingen kortstokk på $UrlKortstokk"
    Break
}

#Formater kortstokk til enklere format
function kortstokkTilStreng {
    [OutputType([string])]
    param (
        [object[]]
        $kortstokk
    )
    $streng = ''
    foreach ($kort in $kortstokk) {
        $streng = $streng + "$($kort.suit[0])" + "$($kort.value)"
        if ( $kort -ne $kortstokk[-1] ) { 
            $streng += "," 
        }
    }
    return $streng
}

#Skriv kortstokk på skjerm
Write-Output "Kortstokk: $(kortStokkTilStreng -kortstokk $kortstokk)"
