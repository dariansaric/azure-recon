# Import-Module Az
# autentikacija
# $args
Write-Output('[*]Connecting to Azure with custom credentials...')
$connection = Connect-AzAccount
if($Null -eq $connection) {
    Write-Output('[-]Login failed, check your credentials and try again!')
    Return
}
# ispis osnovnih podataka autentikacije
$acc = $connection.Context.Account
Write-Output('[+]Logged in as  ' + $acc.Id)
Write-Output('[*]Logged user data: ')
$acc
# todo:
Write-Output('[+]Found ' + $acc.ExtendedProperties.Count + ' active/available subscriptions/tenants')
$acc.ExtendedProperties


$context = Get-AzContext
write-output('[*]Subscription data for active subscription: ' + $context.Subscription.Id)
$context.Subscription
$subName = $context.Subscription.Name
$subId = $context.Subscription.Id
# todo: ispis resursa za subscription

Disconnect-AzAccount
