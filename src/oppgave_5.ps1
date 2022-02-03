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

#Gi kortene poeng
function sumPoengKortstokk {
    [OutputType([int])]
    param (
        [object[]]
        $kortstokk
    )
    #Sett startsum=0
    $poengKortstokk = 0

    #Gå igjennom kortstokken, billedkort=10, Ess=11, ellers kortets verdi.
    foreach ($kort in $kortstokk) {
        $poengKortstokk += switch ($kort.value) {
            { $_ -cin @('J', 'Q', 'K') } { 10 }
            'A' { 11 }
            default { $kort.value }
        }
    }
    return $poengKortstokk
}

#Skriv ut kortstokkens totale poengsum
Write-Output "Poengsum: $(sumPoengKortstokk -kortstokk $kortstokk)"