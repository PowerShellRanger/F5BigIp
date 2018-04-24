
$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf

Get-Module -Name $moduleName -All | Remove-Module -Force
Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force

InModuleScope -ModuleName $moduleName {

    $sut = Split-Path $MyInvocation.MyCommand.ScriptBlock.File -Leaf
    $cmdletName = $sut.Split('.')[0]
    $cmdlet = Get-Command -Name $cmdletName

    Describe $cmdletName {                   
        
        

        $tokenMock = "IHH5ILDD6V4ZO43SEUFZEFOZAD"
        $F5Name = 'foo'
        $poolNameMock = "test1234"

        Context "Testing Parameters" {           

            It "Should throw when mandatory parameters are not provided" {
                $cmdlet.Parameters.F5Name.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.Token.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.PoolName.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.Monitor.Attributes.Mandatory | should be $true
            }        
        }
        
        Context 'Testing function calls Invoke-RestMethod' {

            $mockedResponse = @{
                name                  = "test1234"
                partition             = "Common"
                fullPath              = "/Common/test1234"
                generation            = "766"
                allowNat              = "yes"
                allowSnat             = "yes"
                ignorePersistedWeight = "disabled"
                ipTosToClient         = "pass-through"
                ipTosToServer         = "pass-through"
                linkQosToClient       = "pass-through"
                linkQosToServer       = "pass-through"
                loadBalancingMode     = "round-robin"
                minActiveMembers      = "0"
                minUpMembers          = "0"
                minUpMembersAction    = "failover"
                minUpMembersChecking  = "disabled"
                monitor               = "/Common/https_443"
                queueDepthLimit       = "0"
                queueOnConnectionLimit= "disabled"
                queueTimeLimit        = "0"
                reselectTries         = "0"
                serviceDownAction     = "none"
                slowRampTime          = "10"
            }

            $newNode = New-F5Pool -F5Name $F5Name -Token $tokenMock -PoolName $poolNameMock -Monitor "HTTPS" -confirm:$false

            It "Should return object with correct properties" {
                Mock -CommandName Invoke-RestMethod -MockWith {return $mockedResponse}               
                $newNode | Should be $mockedResponse
            }

        }
        

    }
}
