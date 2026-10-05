<#
.SYNOPSIS
    Automates Active Directory user creation from a CSV file.

.DESCRIPTION
    This script reads user details from Users.csv, constructs a hashtable 
    for user attributes, creates each Active Directory user inside the 
    Department-IT OU, and enables the account.

.PARAMETER CsvPath
    Specifies the file path to the Users.csv file.

.EXAMPLE
    PS> .\AddNewUser.ps1 -CsvPath "C:\Users\Administrator\Documents\Users.csv"

.NOTES
    Author: Bhupinder Singh
    Created: 2026-10-05
    Version: 1.0
    Last Modified: 2026-10-05
    Change Log:
        1.0 - Initial release for Lab 3

.LINK
    https://github.com/bhupinder/MyProject
#>

param (
    [string]$CsvPath = "C:\Users\Administrator\Documents\Users.csv"
)

function Import-ADUsersFromCSV {
    param (
        [string]$Path
    )

    if (-not (Test-Path -Path $Path)) {
        Write-Error "CSV file not found at path: $Path"
        return
    }

    $users = Import-Csv -Path $Path

    foreach ($user in $users) {
        try {
            $NewUserParameters = @{
                'GivenName'         = $user.firstName
                'Surname'           = $user.lastName
                'Name'              = "$($user.firstName) $($user.lastName)"
                'UserPrincipalName' = $user.userPrincipalName
                'AccountPassword'   = (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force)
                'Path'              = "OU=Department-IT,DC=bhupinder,DC=com"
                'Enabled'           = $true
            }

            New-ADUser @NewUserParameters -ErrorAction Stop
            Write-Host "Successfully created user: $($user.userName)" -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to create user '$($user.userName)': $_"
        }
    }
}

Import-ADUsersFromCSV -Path $CsvPath
