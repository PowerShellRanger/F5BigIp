function New-F5Pool
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = "High"
    )]
    param
    (
        # F5Name
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]        
        [string]$F5Name,

        # Token Based Authentication
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]        
        [string]$Token,

        # Name of Pool to create
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]        
        [string]$PoolName,

        # Type of Monitor
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName
        )]  
        [ValidateSet('HTTP', 'HTTPS', 'Custom')]
        $Monitor
    )
   
    DynamicParam
    {
        if ($Monitor -eq 'Custom')
        {
            Write-Verbose 'Create a new ParameterAttribute Object.'
            $eventSourceNameAttribute = New-Object System.Management.Automation.ParameterAttribute
            $eventSourceNameAttribute.Mandatory = $true
            $eventSourceNameAttribute.ValueFromPipeline = $true
            $eventSourceNameAttribute.ValueFromPipelineByPropertyName = $true
            Write-Verbose 'Create an attributecollection object for the attribute just created.'
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($eventSourceNameAttribute)
            $eventSourceNameParam = New-Object System.Management.Automation.RuntimeDefinedParameter('CustomMonitorName', [string], $attributeCollection)
            $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add('CustomMonitorName', $eventSourceNameParam)
            return $paramDictionary
        }
    }
    begin
    {
    }
    process
    {
        if ($PSCmdlet.ShouldProcess("Creates new pool: $PoolName on F5: $F5Name"))
        { 
            $errorAction = $ErrorActionPreference        
            if ($PSBoundParameters["ErrorAction"])
            {
                $errorAction = $PSBoundParameters["ErrorAction"]
            }

            $headers = @{
                'X-F5-Auth-Token' = $Token
            }

            $poolInfo = @{
                name = "$PoolName"
            }
            switch ($Monitor)
            {
                "HTTP" {$poolInfo.Add("monitor", "/Common/http")}
                "HTTPS" {$poolInfo.Add("monitor", "/Common/https_443")}
                "Custom" {$poolInfo.Add("monitor", "/Common/$CustomMonitorName")}
            }
            $poolInfo = $poolInfo | ConvertTo-Json        

            $url = "https://$F5Name/mgmt/tm/ltm/pool"
            Write-Verbose "Invoke Rest Method to: $url"
            Invoke-RestMethod -Method POST -Uri $url -Body $poolInfo -Headers $headers -ContentType "application/json" -ErrorAction $errorAction
        }
    }
    end
    {
    }
}

