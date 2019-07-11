# azure-recon

This PowerShell script uses submitted credentials to enumerate Microsoft Azure services available to a user with provided credentials.
At the moment it can enumerate following services:
<ul>
    <li><b>Active Directory Groups</b></li>
    <li><b>Active Directory Users</b></li>
    <li><b>Resource groups</b></li>
    <li><b>Management groups</b></li>
    <li><b>Resources</b></li>
    <li><b>Key Vaults and their content</b></li>
    <li><b>Virtual Machines</b></li>
</ul>
<h1>Usage</h1>
```.\base-recon.ps1 [-Credential <credentials>] [-OutputFormat (Console|Text)]```
    
