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
        $F5Pool
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
            $customMonitorNameParam = New-Object System.Management.Automation.RuntimeDefinedParameter('CustomMonitorName', [string], $attributeCollection)
            $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add('CustomMonitorName', $customMonitorNameParam)
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

            $body = $F5Pool | ConvertTo-Json        
            
            $splatInvokeRestMethod = @{
                Uri         = "https://$F5Name/mgmt/tm/ltm/pool"
                ContentType = 'application/json'
                Method      = 'POST'
                Body        = $body
                Headers     = $headers
                ErrorAction = $errorAction
            }
            Invoke-RestMethod @splatInvokeRestMethod
        }
    }
    end
    {
    }
}

