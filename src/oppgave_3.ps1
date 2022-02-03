#Stopp skriptet ved feil
$ErrorActionPreference = 'Stop'

#Hent ned kortstokk fra Web API
$webRequest = Invoke-WebRequest -Uri http://nav-deckofcards.herokuapp.com/shuffle
$kortstokkJson = $webRequest.Content
$kortstokk = ConvertFrom-Json -InputObject $kortstokkJson

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

#Skriv Kortstokk på skjerm
Write-Output "Kortstokk: $(kortStokkTilStreng -kortstokk $kortstokk)"
