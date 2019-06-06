# Import-Module Az
# autentikacija


function checkSession {
    # [cmdletbinding()]
    $Error.Clear()
    $context = Get-AzContext
    if ($Null -eq $context) {
        # todo: ne radi ispis čuda u funkciji
        "[X]You are not logged in on any Azure service, login with a username and password..."
        '[*]Logging in to Azure with custom credentials...'
        $connection = Connect-AzAccount
        if ($Null -eq $connection) {
            '[-]Login failed, check your credentials and try again!'
            Return $Null
        }
        $context = Get-AzContext -ErrorAction Continue
    }
    '[+]Logged in as  ' + $context.Account.Id
    return $context
}

function dumpResourceGroups {
    # [cmdletbinding()]
    # param( [Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext]$context)
    if ($Null -eq $context) {
        Return $Null
    }
    '[*]Listing all available resource groups...'
    $groups = Get-AzResourceGroup
    $groups
    Return $groups
}

function dumpActiveDirectory {
    # [cmdletB]
    param([System.Array]$ActiveDirectoryGroups)
    $activeDirectoryGroupNames = New-Object System.Collections.Generic.List[String]
    $ActiveDirectoryGroups | ForEach-Object -Process {
        $group = $_
        $activeDirectoryGroupNames.Add($group.DisplayName)
    }

    $activeDirectoryNames.Count
    # todo: ispis na ekran i/ili u file
    $name = Read-Host '[?]Would you like to write Active Directory group names to a file?[Y/n]'
    if ($name -eq 'Y') {
        $current_dir = Get-Location
        '[*]Writing Active Directory group names to file "' + $current_dir + '\ad-group-names.txt"...'
        Add-Content $current_dir + '\ad-group-names.txt' $activeDirectoryGroupNames
        '[+]Active Directory group names successfully written...'
    }
}


$context = checkSession

$acc = $context.Account
'[*]Logged user data: '
$acc
'[+]Found ' + $acc.ExtendedProperties.Count + ' active/available subscriptions/tenants'
$acc.ExtendedProperties

'[*]Subscription data for active subscription: ' + $context.Subscription.Id
$context.Subscription
$subName = $context.Subscription.Name
$subId = $context.Subscription.Id
# todo: ispis resursa za subscription

dumpResourceGroups 
#-context $context
'[*]Listing all Active Directory Groups for domain ' + $context.Account.Id.Split('@')[1]
# todo: upotreba naredbe Get-AzADGroup za dohvat cijelog AD-a (Active Directory) -> dumpa mi se cijeli AD
$activeDirectoryGroups = Get-AzADGroup
if ($activeDirectoryGroups.Count -gt 0) {
    '[+]Found ' + $activeDirectoryGroups.Count + ' active directory groups'
    # todo: ispis naziva svih grupa AD-a
    dumpActiveDirectory -ActiveDirectoryGroups $activeDirectoryGroups
}

# todo: dohvat AD korisnika

# Disconnect-AzAccount
