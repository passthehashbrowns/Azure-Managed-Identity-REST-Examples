# Azure-Managed-Identity-REST-Examples

## This repository contains my musings with the Azure Managed Identity REST API.

### Why?
In Azure, administrators can assign managed identities to virtual machines. Similar to common AWS SSRF attacks, these identities can potentially be abused to access additional resources and perform lateral movement or escalate privileges.

### Samples
- Run-VMCommandREST - This script will run a command on an arbitrary virtual machine that the managed identity has at least contributor permission to. The output of the command is not returned, so consider using an exfiltration mechanism or establish an alternate means of communication with the host.
- Run-AzRunBook - This script will create a runbook for an automation account and run a local, user-provided PowerShell script. The runbook will be deleted afterwards, but a job will still exist in the "Jobs" tab of the automation account.
- Get-AzAutomationAccountCreds - This script is a copy of the password dumping tools from the MicroBurst project, but using the REST API instead of the AzureRM PowerShell modules. It will dump certificates and credentials for automation accounts.


