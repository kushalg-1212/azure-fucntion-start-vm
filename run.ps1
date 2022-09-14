using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Interact with query parameters or the body of the request.
$rgname = $Request.Query.resourcegroup
if (-not $rgname) {
    $rgname = $Request.Body.resourcegroup
}
$vmname = $Request.Query.vm
if (-not $vmname) {
    $vmname = $Request.Body.vm
}
$action = $Request.Query.action
if (-not $action) {
    $action = $Request.Body.action
}

# Check required params
if ($rgname -and $vmname -and $action) {
    $status = [HttpStatusCode]::OK    

    if ($action -ceq "get") {
        $body = Get-AzVM -ResourceGroupName $rgname  -status | select-object Name, PowerState
    }
    if ($action -ceq "start") {
        $body = Start-AzVM -AsJob -ResourceGroupName $rgname -Name $vmname
    }
    if ($action -ceq "stop") {
        $body = Stop-AzVM -AsJob -ResourceGroupName $rgname -Name $vmname -Force
    }
}
else{
    #Bad request if a required param is missing
    $status = [HttpStatusCode]::BADREQUEST
    $body = "required params : action , resourcegroup, vm"
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $status
        Body       = $body
    })
