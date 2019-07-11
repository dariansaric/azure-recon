# azure-recon

This PowerShell script uses submitted credentials to enumerate Microsoft Azure services available to a user with provided credentials.
At the moment it can enumerate following services:
-   Active Directory Groups
-   Active Directory Users
-   Resource groups
-   Management groups
-   Resources
-   Key Vaults and their content
-   Virtual Machines

### Usage
```
.\base-recon.ps1 [-Credential <credentials>] [-OutputFormat (Console|Text)]
```
  
