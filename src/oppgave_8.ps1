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

# Tilordne 2 kort index 0 og index 1, til $meg. Dvs meg bestrakes som en kortstokk :-)
$meg = $kortstokk[0..1]
Write-Output "meg: $(kortStokkTilStreng -kortstokk $meg)"

# Fjern 2 kort fra kortstokken som er gitt til $meg
$kortstokk = $kortstokk[2..$kortstokk.Count]

# Tilordne 2 kort index 0 og index 1, til $magnus. Dvs magnus bestrakes som en kortstokk :-)
$magnus = $kortstokk[0..1]
Write-Output "magnus: $(kortStokkTilStreng -kortstokk $magnus)"

# Fjern 2 kort fra kortstokken som er gitt til $magnus
$kortstokk = $kortstokk[2..$kortstokk.Count]
Write-Output "Kortstokk: $(kortStokkTilStreng -kortstokk $kortstokk)"

# ...

function skrivUtResultat {
    param (
        [string]
        $vinner,        
        [object[]]
        $kortStokkMagnus,
        [object[]]
        $kortStokkMeg        
    )
    Write-Output "Vinner: $vinner"
    Write-Output "magnus | $(sumPoengKortstokk -kortstokk $kortStokkMagnus) | $(kortstokkTilStreng -kortstokk $kortStokkMagnus)"    
    Write-Output "meg    | $(sumPoengKortstokk -kortstokk $kortStokkMeg) | $(kortstokkTilStreng -kortstokk $kortStokkMeg)"
}

# bruker 'blackjack' som et begrep - er 21
$blackjack = 21

if (((sumPoengKortstokk -kortstokk $meg) -eq $blackjack) -and ((sumPoengKortstokk -kortstokk $magnus) -eq $blackjack)) {
    skrivUtResultat -vinner "draw" -kortStokkMagnus $magnus -kortStokkMeg $meg
}
elseif ((sumPoengKortstokk -kortstokk $meg) -eq $blackjack) {
    skrivUtResultat -vinner "meg" -kortStokkMagnus $magnus -kortStokkMeg $meg
    exit
}
elseif ((sumPoengKortstokk -kortstokk $magnus) -eq $blackjack) {
    skrivUtResultat -vinner "magnus" -kortStokkMagnus $magnus -kortStokkMeg $meg
    exit
}

# ...

while ((sumPoengKortstokk -kortstokk $meg) -lt 17) {
    $meg += $kortstokk[0]
    $kortstokk = $kortstokk[1..$kortstokk.Count]
}

if ((sumPoengKortstokk -kortstokk $meg) -gt $blackjack) {
    skrivUtResultat -vinner "Magnus" -kortStokkMagnus $magnus -kortStokkMeg $meg
    exit
}