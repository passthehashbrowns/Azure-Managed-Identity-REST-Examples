Function Get-AzDomainInfoREST {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false,
        HelpMessage="Subscription ID")]
        [string]$SubscriptionId,

        [Parameter(Mandatory=$false,
        HelpMessage="The management scoped token")]
        [string]$managementToken

    )

    if ($SubscriptionId -eq ''){

        # List all subscriptions for a tenant
        $subscriptions = ((Invoke-WebRequest -Uri ('https://management.azure.com/subscriptions?api-version=2019-11-01') -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).content | ConvertFrom-Json).value
        write-output $subscriptions
        # Select which subscriptions to dump info for
        #$subChoice = $subscriptions | out-gridview -Title "Select One or More Subscriptions" -PassThru
        $subChoice = $subscriptions[0]
        if($subChoice.count -eq 0){Write-Verbose 'No subscriptions selected, exiting'; break}

    }
    else{$subChoice = $SubscriptionId; $noLoop = 1}

    $SubscriptionId = $subChoice.subscriptionId

    $resourceGroups = ((Invoke-WebRequest -uri (-join ("https://management.azure.com/subscriptions/",$SubscriptionId,"/resourcegroups?api-version=2020-10-01") ) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).content | ConvertFrom-Json).value

    Write-Output $resourceGroups

    $subName = $subChoice.displayName

    $responseKeys = Invoke-WebRequest -Uri (-join ('https://management.azure.com/subscriptions/',$SubscriptionId,'/providers/Microsoft.Storage/storageAccounts?api-version=2019-06-01')) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $token"} -UseBasicParsing
    $storageACCTS = ($responseKeys.Content | ConvertFrom-Json).value

    Write-Output $storageACCTS

    <#
    #Write-Output $storageACCTS
    if($Resources -eq "Y"){
    $automationAccounts = ((Invoke-WebRequest -uri (-join ("https://management.azure.com/subscriptions/",$SubscriptionId,"/providers/Microsoft.Automation/automationAccounts?api-version=2015-10-31") ) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).content | ConvertFrom-Json).value
    
    Write-Output $automationAccounts

    foreach($account in $automationAccounts){
        $runbooks = ((Invoke-WebRequest -uri (-join ("https://management.azure.com" + $account.id + "/runbooks?api-version=2015-10-31") ) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).content | ConvertFrom-Json).value
        Write-output $runbooks
        foreach($runbook in $runbooks){
            $content = (Invoke-WebRequest -uri (-join ("https://management.azure.com" + $runbook.id + "/content?api-version=2015-10-31") ) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing)
            if($content.Headers["Content-Type"] -eq "text/powershell"){
                Write-Output "------------------------------------------------"
                Write-Host (-join "Output from ",$runbook.name)
                Write-Host $content.Content
                }

            }

        $variables = ((Invoke-WebRequest -uri (-join ("https://management.azure.com" + $account.id + "/variables?api-version=2015-10-31") ) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).content | ConvertFrom-Json).value
        Write-Output $variables
    }
    }
    #>
    
    <#
    $virtualMachines = ((Invoke-WebRequest -Uri (-join ('https://management.azure.com/subscriptions/',$SubscriptionId,"/providers/Microsoft.Compute/virtualMachines?api-version=2020-06-01")) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).Content) | ConvertFrom-Json
    foreach($vm in $virtualMachines){
        Write-Output $vm
    }
    #$virtualMachineScaleSets = ((Invoke-WebRequest -Uri (-join ('https://management.azure.com/subscriptions/',$SubscriptionId,"/providers/Microsoft.Compute/virtualMachines?api-version=2020-06-01")) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).Content) | ConvertFrom-Json
    foreach($group in $resourceGroups){
        $vmss = ((Invoke-WebRequest -Uri (-join ('https://management.azure.com/subscriptions/',$SubscriptionId,"/resourceGroups/",$group.name,"/providers/Microsoft.Compute/virtualMachineScaleSets?api-version=2020-12-01")) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).Content) | ConvertFrom-Json
        Write-Output $vmss
    }

    $networkInterfaces = (((Invoke-WebRequest -Uri (-join ('https://management.azure.com/subscriptions/',$SubscriptionId,"/providers/Microsoft.Network/networkInterfaces?api-version=2020-11-01")) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).Content) | ConvertFrom-Json).value
    foreach($interface in $networkInterfaces){
        #Write-Output $interface
        foreach($prop in $interface.properties){
            Write-Output $prop
        }
    }
    $networkSecurityGroups = (((Invoke-WebRequest -Uri (-join ('https://management.azure.com/subscriptions/',$SubscriptionId,"/providers/Microsoft.Network/networkSecurityGroups?api-version=2020-11-01")) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).Content) | ConvertFrom-Json).value
    foreach($group in $networkSecurityGroups){
        foreach($prop in $group.properties){
            Write-Output $prop
        }
    }

    $roleAssignments = (((Invoke-WebRequest -Uri (-join ('https://management.azure.com/subscriptions/',$SubscriptionId,"/providers/Microsoft.Authorization/roleAssignments?api-version=2015-07-01")) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).Content) | ConvertFrom-Json).value
    foreach($role in $roleAssignments){
       write-output $role
    }
    #>
    <#
    $sqlServers = (((Invoke-WebRequest -Uri (-join ('https://management.azure.com/subscriptions/',$SubscriptionId,"/providers/Microsoft.Sql/servers?api-version=2020-08-01-preview")) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).Content) | ConvertFrom-Json).value
    foreach($server in $sqlServers){
        $databases = (((Invoke-WebRequest -Uri (-join ('https://management.azure.com',$server.id,'/databases?api-version=2020-08-01-preview')) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).Content) | ConvertFrom-Json).value
   
    }
    #>

    #$resources = ((Invoke-WebRequest -uri (-join ("https://management.azure.com/subscriptions/",$SubscriptionId,"/resources?api-version=2020-10-01") ) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).content | ConvertFrom-Json).value

    #Write-Output $resources
    
    #$appServices = ((Invoke-WebRequest -uri (-join ("https://management.azure.com/subscriptions/",$SubscriptionId,"/providers/Microsoft.Web/sites?api-version=2019-08-01") ) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).content | ConvertFrom-Json).value

    #Write-Output $appServices

    #$disks = ((Invoke-WebRequest -uri (-join ("https://management.azure.com/subscriptions/",$SubscriptionId,"/providers/Microsoft.Compute/disks?api-version=2020-12-01") ) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).content | ConvertFrom-Json).value

    #$keyVaults = ((Invoke-WebRequest -Uri (-join ('https://management.azure.com/subscriptions/',$SubscriptionId,"/providers/Microsoft.KeyVault/vaults?api-version=2019-09-01")) -Verbose:$false -Method GET -Headers @{ Authorization ="Bearer $managementToken"} -UseBasicParsing).Content | ConvertFrom-Json).value

    }