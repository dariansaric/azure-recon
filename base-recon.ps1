# Import-Module Az
function checkSession {
    # todo: autentifikacija pomoću Get-Credential!!!
    # [cmdletbinding()]
    $Error.Clear()
    $context = Get-AzContext
    if ($Null -eq $context) {
        # todo: ne radi ispis čuda u funkciji
        "[X]You are not logged in on any Azure service, login with a username and password..."
        '[*]Logging in to Azure with custom credentials...'
        $connection = Connect-AzAccount -Credential $(Get-Credential)
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
    
    $groups = Get-AzResourceGroup
    '[+]Found ' + $groups.Count + ' resource groups...'
    if ($groups.Count -gt 0) {
        $ans = Read-Host '[?]Would you like to dump resource groups to a file?[Y/n]'
        if ($ans -eq 'Y') {
            # todo: zapiši u file
            $current_dir = Get-Location
            '[*]Writing resource group dump to file "' + $current_dir + '\resource-groups.txt"...'
            $ResourceGroupFilePath = '.\resource-groups.txt'
            # Set-Content $ADGroupNamesFilePath $activeDirectoryGroupNames
            # $groups.ToArray() > $ResourceGroupFilePath
            $groups > $ResourceGroupFilePath
            '[+]Active resource groups successfully written...'
        }
        '[*] Dumping resource groups...'
        $groups
        Return $groups
    }

    Return $Null
}

function dumpActiveDirectoryGroupNames {
    # [cmdletB]
    param([System.Array]$ActiveDirectoryGroups)
    $activeDirectoryGroupNames = New-Object System.Collections.Generic.List[String]
    $ActiveDirectoryGroups | ForEach-Object -Process {
        $group = $_
        $activeDirectoryGroupNames.Add($group.DisplayName)
    }

    $name = Read-Host '[?]Would you like to write Active Directory group names to a file?[Y/n]'
    if ($name -eq 'Y') {
        $current_dir = Get-Location
        '[*]Writing Active Directory group names to file "' + $current_dir + '\ad-group-names.txt"...'
        $ADGroupNamesFilePath = '.\ad-group-names.txt'
        # Set-Content $ADGroupNamesFilePath $activeDirectoryGroupNames
        $activeDirectoryGroupNames.ToArray() > $ADGroupNamesFilePath
        '[+]Active Directory group names successfully written...'
    }
    else {
        $activeDirectoryGroupNames
    }
}

function dumpActiveDirectoryUsers {
    param([System.Array]$ActiveDirectoryUsers)
    # todo: trebam li nešto uopće dodatno
    $name = Read-Host '[?]Would you like to write Active Directory users to a file?[Y/n]'
    if ($name -eq 'Y') {
        $current_dir = Get-Location
        '[*]Writing Active Directory users to file "' + $current_dir + '\ad-users.txt"...'
        $ADUsersPath = '.\ad-users.txt'
        # Set-Content $ADGroupNamesFilePath $activeDirectoryGroupNames
        $ActiveDirectoryUsers > $ADUsersPath
        '[+]Active Directory users successfully written to file...'
    }
    else {
        $ActiveDirectoryUsers
    }
}

function dumpManagementGroups {
    param([System.Array]$ManagementGroups)

    $name = Read-Host '[?]Would you like to write management groups to a file?[Y/n]'
    if ($name -eq 'Y') {
        $current_dir = Get-Location
        '[*]Writing management groups to file "' + $current_dir + '\management-groups.txt"...'
        $ManagementGroupsPath = '.\management-groups.txt'
        $ManagementGroups > $ManagementGroupsPath
        '[+]Management groups successfully written to file...'
    }
}

function dumpResourcesSummary {
    param([System.Array]$ResourceGroups)
    $AllResources = Get-AzResource
    '[*] Found ' + $AllResources.Count + ' total resources...'
    $prompt = Read-Host '[?] Would you like to write Azure resources per group to a file?[Y/n]'   
    
    $ResourceGroups | ForEach-Object -Process {
        if($Null -eq $_.ResourceGroupName) {
            Return
        }
        $resources = Get-AzResource -ResourceGroupName $_.ResourceGroupName
        if ($prompt -eq 'Y') {
            $current_dir = Get-Location
            '[*] Writing management groups to files with prefix "' + $current_dir + '\resources-*"...'
            $ResourcesPathPrefix = '.\resources-'
            $Path = $ResourcesPathPrefix + $_.ResourceGroupName + '.txt'
            '[*] Writing management groups to file "' + $Path + '" for resource group "' + $_.ResourceGroupName + '"...'
            $resources > $Path
            '[+] Successfully written resources to file for resource group "' + $_.ResourceGroupName + '"'
        }
        else {
            '[*] Dumping resources for resource group "' + $_.ResourceGroupName + '":'
            $resources
        }
    }



}

function Main() {
    $context = checkSession

    $acc = $context.Account
    '[*]Logged user data: '
    $acc
    '[+]Found ' + $acc.ExtendedProperties.Count + ' active/available subscriptions/tenants'
    $acc.ExtendedProperties

    '[*]Subscription data for active subscription: ' + $context.Subscription.Id
    '[*]Trying to fetch Active Directory Groups for domain ' + $context.Account.Id.Split('@')[1] + '...'
    $activeDirectoryGroups = Get-AzADGroup
    if ($activeDirectoryGroups.Count -gt 0) {
        '[+]Found ' + $activeDirectoryGroups.Count + ' Active Directory groups'
    
        dumpActiveDirectoryGroupNames -ActiveDirectoryGroups $activeDirectoryGroups
    }

    '[*]Trying to fetch Active Directory users for domain ' + $context.Account.Id.Split('@')[1] + '...'
    Try {
        $activeDirectoryUsers = Get-AZADUser
        if ($activeDirectoryUsers.Count -gt 0) {
            '[+]Found ' + $activeDirectoryUsers.Count + ' Active Directory users'

            dumpActiveDirectoryUsers -ActiveDirectoryUsers $activeDirectoryUsers
        }
    }
    Catch {
        '[-]Sorry, user ' + $context.Account.Id + ' is not authorized to view Active Directory users...'
    }

    '[*]Trying to fetch resource management groups for domain ' + $context.Account.Id.Split('@')[1] + '...'
    Try {
        dumpManagementGroups -ManagementGroups  $(Get-AzManagementGroup -ErrorAction Stop) # na testiranju ne mogu dalje, pa ne znam kakav je output
    }
    Catch {
        '[-]Sorry, user ' + $context.Account.Id + ' does not have authorization to view management groups'
    }

    # todo: ispis korisnika koji mom korisniku dao dozvole
    '[*] Trying to fetch role assignment...'
    Try {
        Get-AzRoleAssignment -Verbose
        # todo: proširenje
    }
    Catch {
        '[-]Unable to fetch role assignment...'
    }

    '[*] Trying to fetch resource groups...'
    $groups = dumpResourceGroups
    $groups.Count

    dumpResourcesSummary -ResourceGroups $groups

    #$groups | ForEach-Object -Process {
    #    $group = $_
    #    '[*] Dumping'
    #    $group
    #}

    # todo: moguće je izlistati sve korisnike koji pripadaju pojedinoj grupi!!
    # todo: što slijedeće :/
    # todo: koji je logični korak nakon toga? ispis baš svih postojećih resursa :/
    Disconnect-AzAccount
}

Main
