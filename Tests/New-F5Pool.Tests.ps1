
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

        $f5PoolObjectMock = [F5Pool]::New($poolNameMock)
        
        Context "Validating mandatory parameters" {
            It "Should throw when mandatory parameters are not provided" {
                $cmdlet.Parameters.F5Name.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.Token.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.F5Pool.Attributes.Mandatory | should be $true
            }
        }
      
       
        Context 'Testing function - Calls New-F5Pool' {

            $mockedHeaders = @{
                'X-F5-Auth-Token' = $tokenMock
            }

            Mock -CommandName Invoke-RestMethod -MockWith {return $true}        
            
            $splatNewF5Pool = @{
                F5Name = $F5Name
                Token  = $tokenMock
                F5Pool = $f5PoolObjectMock
            }
            $return = New-F5Pool @splatNewF5Pool -confirm:$false 

            It "Should return object with correct properties" {
                $return | Should be $true
            }
                
            It 'Validating Invoke-RestMethod parameters in function' {
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Uri -eq "https://$F5Name/mgmt/tm/ltm/pool" `
                        -and $ContentType -eq 'application/json' `
                        -and $Method -eq 'POST' `
                        -and $Headers.Keys -eq $mockedHeaders.Keys `
                        -and $Headers.Values -eq $mockedHeaders.Values `
                        -and ($Body | ConvertFrom-Json).Name -eq "$poolNameMock" `
                        -and ($Body | ConvertFrom-Json).Monitor -eq "/Common/https_443" 
                        
                } 
            }
        }
        
        Context 'Testing function - Calls New-F5Pool - CustomMonitor' {
            $customMonitorNameMocked = "https_custom"
            $customMonitorNameMocked = [F5Pool]::GetMonitorName($customMonitorNameMocked)
            $f5PoolObjectMock.Monitor = $customMonitorNameMocked

            Mock -CommandName Invoke-RestMethod -MockWith {return $true}        

            $splatNewF5Pool = @{
                F5Name = $F5Name
                Token  = $tokenMock
                F5Pool = $f5PoolObjectMock
            }
            $null = New-F5Pool @splatNewF5Pool -confirm:$false 

            It 'Validating Invoke-RestMethod parameters in function' {
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
                    ($Body | ConvertFrom-Json).Monitor -eq $customMonitorNameMocked
                } 
            }
        }

        #Todo add member object testing
    }
}
