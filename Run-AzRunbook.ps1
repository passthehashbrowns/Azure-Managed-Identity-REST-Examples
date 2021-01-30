function Run-AzRunbook {
        [CmdletBinding()]
        Param(

        [Parameter(Mandatory=$true,
        HelpMessage="The management scoped token")]
        [string]$managementToken,
        

        [Parameter(Mandatory=$true,
        HelpMessage="The target automation account")]
        [string]$automationAccount,

        [Parameter(Mandatory=$false,
        HelpMessage="The name of the runbook. Defaults to random.")]
        [string]$runbookName,

        [Parameter(Mandatory=$true,
        HelpMessage="The subscription id where the automation account is located")]
        [string]$subscriptionId,
        
        [Parameter(Mandatory=$true,
        HelpMessage="The resource group where the automation account is located")]
        [string]$resourceGroupId,

        [Parameter(Mandatory=$true,
        HelpMessage="The script you'd like to run")]
        [string]$targetScript
        
        )
        

        if($runbookName -eq '') {$runbookName = -join ((65..90) + (97..122) | Get-Random -Count 15 | % {[char]$_})}

        Write-Verbose (-join ("Name of runbook: ",$runbookName))
        
      
        #If we create a draft we can input the content directly instead of needing to host a file.
        #$draftBody = "Write-Verbose Success!"
        Write-Verbose "Creating draft runbook..."
        $draftBody = -join ('{"properties":{"runbookType":"PowerShell","draft":{}},"name":"',$runbookName,'","location":"eastus"}')
        $createDraft= ((Invoke-WebRequest -Uri (-join ('https://management.azure.com/subscriptions/',$subscriptionId,'/resourceGroups/',$resourceGroupId,'/providers/Microsoft.Automation/automationAccounts/',$automationAccount,'/runbooks/',$runbookName,'?api-version=2015-10-31')) -Verbose:$false -ContentType "application/json" -Method PUT -Body $draftBody -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).Content | ConvertFrom-Json).value
        
        #Write-Verbose $createDraft
        Write-Verbose "Replacing script content..."
        #$editDraftBody = "Write-Verbose Edited script!"
        $editDraftBody = Get-Content $targetScript
        $editDraft = (Invoke-WebRequest -Uri (-join ('https://management.azure.com/subscriptions/',$subscriptionId,'/resourceGroups/',$resourceGroupId,'/providers/Microsoft.Automation/automationAccounts/',$automationAccount,'/runbooks/',$runbookName,'/draft/content?api-version=2015-10-31')) -Verbose:$false -ContentType "text/powershell" -Method PUT -Body $editDraftBody -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).Content
        
        #Write-Verbose $editDraft
        Write-Verbose "Publishing draft..."
        $publishDraft = (Invoke-WebRequest -Uri (-join ('https://management.azure.com/subscriptions/',$subscriptionId,'/resourceGroups/',$resourceGroupId,'/providers/Microsoft.Automation/automationAccounts/',$automationAccount,'/runbooks/',$runbookName,'/draft/publish?api-version=2015-10-31')) -Verbose:$false -Method POST -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).Content
        
        Write-Verbose $publishDraft

        $jobBody = -join ('{"properties":{"runbook":{"name":"',$runbookName,'"},"runOn":""}}')

        $jobGUID = [GUID]::NewGuid().ToString()
        
        Write-Verbose "Starting job..."        
        
        $startJob = (Invoke-WebRequest -Uri (-join ('https://management.azure.com/subscriptions/',$subscriptionId,'/resourceGroups/',$resourceGroupId,'/providers/Microsoft.Automation/automationAccounts/',$automationAccount,'/jobs/',$jobGUID,'?api-version=2015-10-31')) -Verbose:$false -ContentType "application/json" -Method PUT -Body $jobBody -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).Content
        
        $jobsResults = (Invoke-WebRequest -Uri (-join ('https://management.azure.com/subscriptions/',$subscriptionId,'/resourceGroups/',$resourceGroupId,'/providers/Microsoft.Automation/automationAccounts/',$automationAccount,'/jobs/',$jobGUID,'/output?api-version=2015-10-31')) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing)
        
        if($jobsResults.RawContentLength -ne 0) {$isDone = $false}
        else
        {
            $isDone = $true
            Write-Verbose "Looping until job completes..."
            while($isDone){
                #Don't want to spam the API
                Start-Sleep 5
                $jobsResults = (Invoke-WebRequest -Uri (-join ('https://management.azure.com/subscriptions/',$subscriptionId,'/resourceGroups/',$resourceGroupId,'/providers/Microsoft.Automation/automationAccounts/',$automationAccount,'/jobs/',$jobGUID,'/output?api-version=2015-10-31')) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing)
                if($jobsResults.RawContentLength -ne 0){$isDone = $false}
            }
        }

        Write-Verbose "Got job output!"
        Write-Verbose $jobsResults.Content

        Write-Verbose "Deleting runbook"
        $deleteRunbook = (Invoke-WebRequest -Uri (-join ('https://management.azure.com/subscriptions/',$subscriptionId,'/resourceGroups/',$resourceGroupId,'/providers/Microsoft.Automation/automationAccounts/',$automationAccount,'/runbooks/',$runbookName,'?api-version=2015-10-31')) -Verbose:$false -Method DELETE -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).Content
       
    }


 
