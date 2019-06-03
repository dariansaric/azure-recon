# Import-Module Az
# autentikacija
# $args

function checkSession {
    $Error.Clear()
    $context = Get-AzContext -ErrorAction Continue
    if($Null -eq $context) {
        Write-Output('[X]You are not logged in on any Azure service, login with a username and password...')
        Write-Output('[*]Logging in to Azure with custom credentials...')
        $connection = Connect-AzAccount
        if($Null -eq $connection) {
            Write-Output('[-]Login failed, check your credentials and try again!')
            Return $Null
        }
        Write-Output('[+]Logged in as  ' + $acc.Id)
        $context = Get-AzContext -ErrorAction Continue
    }

    return $context
}

function dumpResourceGroups {
    param( [Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext]$context)
    if($Null -eq $context) {
        Return $Null
    }
    Write-Output('[*]Listing all available resource groups...')
    $groups = Get-AzResourceGroup
    $groups
    Return $groups
}


$context = checkSession
# ispis osnovnih podataka autentikacije
$acc = $context.Account
Write-Output('[+]Logged in as  ' + $acc.Id)
Write-Output('[*]Logged user data: ')
$acc
# todo:
Write-Output('[+]Found ' + $acc.ExtendedProperties.Count + ' active/available subscriptions/tenants')
$acc.ExtendedProperties

write-output('[*]Subscription data for active subscription: ' + $context.Subscription.Id)
$context.Subscription
$subName = $context.Subscription.Name
$subId = $context.Subscription.Id
# todo: ispis resursa za subscription
# todo: ispis grupa resursa

dumpResourceGroups -context $context
# Disconnect-AzAccount
