# Import-Module Az
# Dozvoljeni output:
#   - Text -> .txt datoteke
#   - Console -> Ispis na konzolu !DEFAULT!
#   - Html -> HTML dokument s hiper-vezama

param(
    [System.String]$Scope = 'All',
    [String]$OutputFormat = 'Console',
    [PSCredential]$Credential
)

# Konstante
$TextOutput = 'Text'
$ConsoleOutput = 'Console'
$HTMLOutput = 'Html'
function Open-Session {
    # [cmdletbinding()]
    $Error.Clear()
    $context = Get-AzContext
    if ($Null -eq $context) {
        # todo: ne radi ispis čuda u funkciji, EDIT: privremeno popravljeno
        '[X] You are not logged in on any Azure service, login with a username and password...'
        '[*] Logging in to Azure with custom credentials...'
        $connection = $Null
        if ($Null -eq $Credential) {
            $connection = Connect-AzAccount -Credential $(Get-Credential)
        }
        else {
            $connection = Connect-AzAccount -Credential $Credential
        }
        if ($Null -eq $connection) {
            '[-] Login failed, check your credentials and try again!'
            Return $Null
        }
        $context = Get-AzContext -ErrorAction Continue
    }
    '[+] Logged in as  ' + $context.Account.Id
}

function Get-ResourceGroups {
    # [cmdletbinding()]
    # param( [Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext]$context)
    # if ($Null -eq $context) {
    #     Return $Null
    # }
    param([System.Array]$ResourceGroups)
    
    '[+] Found ' + $ResourceGroups.Count + ' resource groups...'
    if ($ResourceGroups.Count -gt 0) {
        switch ($OutputFormat) {
            $TextOutput {
                $current_dir = Get-Location
                '[*] Writing resource group dump to file "' + $current_dir + '\resource-groups.txt"...'
                $ResourceGroupFilePath = '.\resource-groups.txt'
    
                # $groups.ToArray() > $ResourceGroupFilePath
                $ResourceGroups > $ResourceGroupFilePath
                '[+] Active resource groups successfully written...'
            }
            $ConsoleOutput {
                '[*] Dumping resource groups...'
                $ResourceGroups
            }
        }
    }
}

function Get-ActiveDirectoryGroupNames {
    param([System.Array]$ActiveDirectoryGroups)
    $activeDirectoryGroupNames = New-Object System.Collections.Generic.List[String]
    foreach ($group in $ActiveDirectoryGroups) {
        $activeDirectoryGroupNames.Add($group.DisplayName)
    }

    switch ($OutputFormat) {
        $TextOutput {
            $current_dir = Get-Location
            '[*] Writing Active Directory group names to file "' + $current_dir + '\ad-group-names.txt"...'
            $ADGroupNamesFilePath = '.\ad-group-names.txt'
            # Set-Content $ADGroupNamesFilePath $activeDirectoryGroupNames
            $activeDirectoryGroupNames.ToArray() > $ADGroupNamesFilePath
            '[+] Active Directory group names successfully written...'
        }
        $ConsoleOutput {
            '[*] Dumping Active Directory group names...'
            $activeDirectoryGroupNames
        }
    }
}

function Get-ActiveDirectoryUsers {
    param([System.Array]$ActiveDirectoryUsers)
    # todo: trebam li nešto uopće dodatno
    # $name = Read-Host '[?]Would you like to write Active Directory users to a file?[Y/n]'
    switch ($OutputFormat) {
        $TextOutput {
            $current_dir = Get-Location
            '[*]Writing Active Directory users to file "' + $current_dir + '\ad-users.txt"...'
            $ADUsersPath = '.\ad-users.txt'
            # Set-Content $ADGroupNamesFilePath $activeDirectoryGroupNames
            $ActiveDirectoryUsers > $ADUsersPath
            '[+]Active Directory users successfully written to file...'
        }
        $ConsoleOutput {
            '[*] Dumping all Active directory users...'
            $ActiveDirectoryUsers
        }
    }
}

function Get-ManagementGroups {
    param([System.Array]$ManagementGroups)

    switch ($OutputFormat) {
        $TextOutput {
            $current_dir = Get-Location
            '[*] Writing management groups to file "' + $current_dir + '\management-groups.txt"...'
            $ManagementGroupsPath = '.\management-groups.txt'
            $ManagementGroups > $ManagementGroupsPath
            '[+] Management groups successfully written to file...'    
        }
        $ConsoleOutput {
            '[*] Dumping management groups...'
            $ManagementGroups
        }
    }
}

function Get-Resources {
    param(
        [System.Array]$ResourceGroups,
        [System.Array]$AllResources)
    '[*] Found ' + $AllResources.Count + ' total resources...'
    if (0 -eq $AllResources.Count) {
        Return
    }
    if ($TextOutput -eq $OutputFormat) {
        $current_dir = Get-Location
        '[*] Writing management groups to files with prefix "' + $current_dir + '\resources-*"...'
    }

    foreach ($group in $ResourceGroups) {
    
        if ($Null -eq $group.ResourceGroupName) {
            Return
        }
        $resources = Get-AzResource -ResourceGroupName $group.ResourceGroupName
        switch ($OutputFormat) {
            $TextOutput {
                $ResourcesPathPrefix = '.\resources-'
                $Path = $ResourcesPathPrefix + $group.ResourceGroupName + '.txt'
                '[*] Writing management groups to file "' + $Path + '" for resource group "' + $group.ResourceGroupName + '"...'
                $resources > $Path
                '[+] Successfully written resources to file for resource group "' + $group.ResourceGroupName + '"'
            }
            $ConsoleOutput {
                '[*] Dumping resources for resource group "' + $group.ResourceGroupName + '":'
                $resources
            }
        }
    }

}

function Get-KeyVaults {
    param(
        [System.Array]$KeyVaults
    )
    if ($Null -eq $KeyVaults) {
        '[-] No key vaults were retrieved...'
        Return
    }

    '[+] Found ' + $KeyVaults.Count + ' key vaults...'
    $current_dir = Get-Location
    '[*] Writing key vault contents in directory "' + $current_dir + "\key-vault\..."

    foreach ($vault in $KeyVaults) {
        '[*] Dumping data found in vault: ' + $vault.VaultName
        $secrets = Get-AzKeyVaultSecret -VaultName $vault.VaultName
        '[*] KeyVault "' + $vault.VaultName + '": Found ' + $secrets.Count + ' secrets...'
        $keys = Get-AzKeyVaultKey -VaultName $vault.VaultName
        '[*] KeyVault "' + $vault.VaultName + '": Found ' + $keys.Count + ' keys...'
        $certificates = Get-AzKeyVaultCertificate -VaultName $vault.VaultName
        '[*] KeyVault "' + $vault.VaultName + '": Found ' + $certificates.Count + ' certificates'

        $trash = mkdir 'key-vault'
        switch ($OutputFormat) {
            $TextOutput {
                $Path = '.\key-vault\' + $vault.VaultName + '\'
                $trash = mkdir $Path
                '[*] KeyVault: "' + $vault.VaultName + '": Writing contents to directory "' + $Path + '"'
                if (0 -lt $secrets.Count) {
                    '[*] KeyVault: "' + $vault.VaultName + '": Writing secrets...'
                    # todo: uljepšati ispis
                    foreach ($s in $secrets) {
                        $v = Get-AzKeyVaultSecret -VaultName $vault.VaultName -Name $s.Name
                        $s.Name >>($Path + 'secrets.txt')
                        $s >> $($Path + 'secrets.txt')
                        'Secret       : ' + $v.SecretValueText >> $($Path + 'secrets.txt')
                    }
                    '[+] KeyVault: "' + $vault.VaultName + '": Secrets successfully written to file...'
                }
                if (0 -lt $keys.Count) {
                    '[*] KeyVault: "' + $vault.VaultName + '": Writing keys...'
                    # foreach ($k in $keys) {
                        # $k
                    # }
                    $keys > $($Path + 'keys.txt')
                    '[+] KeyVault: "' + $vault.VaultName + '": Keys successfully written to file...'
                }
                if (0 -lt $certificates.Count) {
                    '[*] KeyVault: "' + $vault.VaultName + '": Writing certificates...'
                    $certificates > $($Path + 'certificates.txt')
                    '[+] KeyVault: "' + $vault.VaultName + '": Certificates successfully written to file...'
                }
            }
            $ConsoleOutput {
                if (0 -lt $secrets.Count) {
                    '[+] KeyVault: "' + $vault.VaultName + '": Dumping secrets...'
                    foreach ($s in $secrets) {
                        # $v = Get-AzKeyVaultSecret -VaultName $vault.VaultName -Name $s.Name
                        $s
                        'Secret       : ' + $(Get-AzKeyVaultSecret -VaultName $vault.VaultName -Name $s.Name).SecretValueText
                    }
                    # $secrets
                }
                if (0 -lt $keys.Count) {
                    # todo: nemam zasad pametnijeg posla
                    '[+] KeyVault: "' + $vault.VaultName + '": Dumping keys...'
                    $keys
                }
                if (0 -lt $certificates.Count) {
                    #todo: nemam zasad pametnijeg posla
                    '[+] KeyVault: "' + $vault.VaultName + '": Dumping certificates...'
                    $certificates
                }
            }
        }

    }
}

function Get-VMs {
    param(
        [System.Array]$Vms
    )

    '[*] Found ' + $Vms.Count + ' virtual machine instances'

    if (0 -eq $Vms.Count) {
        Return
    }

    switch($OutputFormat) {
        $TextOutput {
            $current_dir = Get-Location
            $Path = 'virtual-machines.txt'
            '[*] Writing virtual machine information to file "' + $current_dir + '\' + $Path + '"...'
            
            'Virtual machine information: ' > $Path
            foreach ($vm in $Vms) {
                $sb = [System.Text.StringBuilder]::new()
                [Void]$sb.AppendLine('Name    : ' + $vm.Name)
                [Void]$sb.AppendLine('VM Id : ' + $vm.VmId)
                [Void]$sb.AppendLine('Resource ID : ' + $vm.Id)
                $sb.ToString() >> $Path
            }

            '[+]Successfully written VM data to file...'
        }
        $ConsoleOutput {
            '[*] Dumping information about virtual machines...'
            $Vms
        }
    }


}
function Main() {
    Open-Session
    $context = Get-AzContext
    if ($Null -eq $context) {
        Return
    }

    $acc = $context.Account
    '[*] Logged user data: '
    $acc
    '[+] Found ' + $acc.ExtendedProperties.Count + ' active/available subscriptions/tenants'
    $acc.ExtendedProperties

    '[*] Subscription data for active subscription: ' + $context.Subscription.Id
    '[*] Trying to fetch Active Directory Groups for domain ' + $context.Account.Id.Split('@')[1] + '...'
    $activeDirectoryGroups = Get-AzADGroup
    if ($activeDirectoryGroups.Count -gt 0) {
        '[+] Found ' + $activeDirectoryGroups.Count + ' Active Directory groups'
    
        Get-ActiveDirectoryGroupNames -ActiveDirectoryGroups $activeDirectoryGroups
    }

    '[*] Trying to fetch Active Directory users for domain ' + $context.Account.Id.Split('@')[1] + '...'
    Try {
        $activeDirectoryUsers = Get-AZADUser
        if ($activeDirectoryUsers.Count -gt 0) {
            '[+] Found ' + $activeDirectoryUsers.Count + ' Active Directory users'

            Get-ActiveDirectoryUsers -ActiveDirectoryUsers $activeDirectoryUsers
        }
    }
    Catch {
        '[-] Sorry, user ' + $context.Account.Id + ' is not authorized to view Active Directory users...'
    }

    '[*] Trying to fetch resource management groups for domain ' + $context.Account.Id.Split('@')[1] + '...'
    Try {
        Get-ManagementGroups -ManagementGroups  $(Get-AzManagementGroup -ErrorAction Stop) # na testiranju ne mogu dalje, pa ne znam kakav je output
    }
    Catch {
        '[-] Sorry, user ' + $context.Account.Id + ' does not have authorization to view management groups'
    }

    '[*] Trying to fetch role assignment...'
    Try {
        Get-AzRoleAssignment -Verbose
        # todo: proširenje
    }
    Catch {
        '[-] Unable to fetch role assignment...'
    }

    '[*] Trying to fetch resource groups...'
    $groups = Get-AzResourceGroup
    Get-ResourceGroups -ResourceGroups $groups

    '[*] Trying to fetch resources...'
    $resources = Get-AzResource
    Get-Resources -ResourceGroups $groups -AllResources $resources

    '[*] Trying to fetch key vaults'
    $keyVaults = Get-AzKeyVault
    # $keyVaults
    Get-KeyVaults -KeyVaults $keyVaults

    '[*] Enumerating VM-s...'
    '[*] Trying to fetch VM-s'
    $vms = Get-AzVM
    Get-VMs -VMs $vms
    # todo: moguće je izlistati sve korisnike koji pripadaju pojedinoj grupi!!
    # todo: pokretanje s argumentima koji će proširiti/suziti područja pretrage


    '[!] Logging out of Azure...'
    if ($Null -ne $(Disconnect-AzAccount)) {
        '[+] Successfully logged out of Azure, bye!!'
    }
}

Main
