function New-F5Pool
{
    <#
    .Synopsis
       
    .DESCRIPTION
       
    .EXAMPLE
       
    .EXAMPLE
       
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'DefaultMonitor'
    )]
    param
    (
        # F5Name
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'CustomMonitor'
        )]
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'DefaultMonitor'
        )]        
        [string]$F5Name,

        # Token Based Authentication
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'CustomMonitor'
        )]
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'DefaultMonitor'
        )]        
        [string]$Token,

        # Name of Pool to create
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'CustomMonitor'
        )]
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'DefaultMonitor'
        )]        
        [string]$PoolName,

        # Type of Monitor
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'CustomMonitor'
        )]
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'DefaultMonitor'
        )]  
        [ValidateSet('HTTP', 'HTTPS', 'Custom')]
        $Monitor,
        
        [Parameter(
            Mandatory, 
            ValueFromPipeline, 
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'CustomMonitor'
        )]
        $CustomMonitorName
    )
    begin
    {
    }
    process
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
    end
    {
    }
}

