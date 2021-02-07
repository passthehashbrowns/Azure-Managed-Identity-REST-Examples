#Example of using the API with a managed identity token to get the contents of all runbooks in a subscription to search for secrets.

Function Get-RunbookContentsREST
{

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false,
        HelpMessage="Subscription ID")]
        [string]$SubscriptionId,

        [Parameter(Mandatory=$true,
        HelpMessage="The management scoped token")]
        [string]$managementToken
    )

    # Sort out which subscription to list keys from
    if ($SubscriptionId -eq ''){

        # List all subscriptions for a tenant
        $subscriptions = ((Invoke-WebRequest -Uri ('https://management.azure.com/subscriptions?api-version=2019-11-01') -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).content | ConvertFrom-Json).value

        # Select which subscriptions to dump info for
        $subChoice = $subscriptions | out-gridview -Title "Select One or More Subscriptions" -PassThru

        if($subChoice.count -eq 0){Write-Verbose 'No subscriptions selected, exiting'; break}

    }
    else{$subChoice = $SubscriptionId; $noLoop = 1}

    $SubscriptionId = $subChoice.SubscriptionId

    $automationAccounts = ((Invoke-WebRequest -uri (-join ("https://management.azure.com/subscriptions/",$SubscriptionId,"/providers/Microsoft.Automation/automationAccounts?api-version=2015-10-31") ) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).content | ConvertFrom-Json).value
        
    foreach($account in $automationAccounts){
        $resourceGroup = $account.id.split('/')[4]
        $runbooks = ((Invoke-WebRequest -uri (-join ("https://management.azure.com/subscriptions/",$SubscriptionId,"/resourceGroups/",$resourceGroup,"/providers/Microsoft.Automation/automationAccounts/",$account.name,"/runbooks?api-version=2015-10-31") ) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).content | ConvertFrom-Json).value
        foreach($runbook in $runbooks){

            try{
            $runbookContent = Invoke-WebRequest -uri (-join ("https://management.azure.com/subscriptions/",$SubscriptionId,"/resourceGroups/",$resourceGroup,"/providers/Microsoft.Automation/automationAccounts/",$account.name,"/runbooks/",$runbook.name,"/content?api-version=2015-10-31") ) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing
            
            #If we don't check for this we might get a big memory stream. Plan to revisit this to capture those as well.
            if($runbookContent.Headers["Content-Type"] -eq "text/powershell"){
                Write-Output "------------------------------------------------"
                Write-Host (-join "Output from ",$runbook.name)
                Write-Host $runbookContent.Content
                }

            }
            catch{}

        }
    }
}
