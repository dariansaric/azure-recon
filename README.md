# azure-recon

This PowerShell script uses submitted credentials to enumerate Microsoft Azure services available to a user with provided credentials.
At the moment it can enumerate following services:
    -<b>Active Directory Groups</b>
    -<b>Active Directory Users</b>
    -<b>Resource groups</b>
    -<b>Management groups</b>
    -<b>Resources</b>
    -<b>Key Vaults and their content</b>
    -<b>Virtual Machines</b>
    
<h1>Usage</h1>
.base-recon.ps1 [-Credential <credentials>] [-OutputFormat (Console|Text)]
    
