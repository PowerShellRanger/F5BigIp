
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
        $nodeNameMock = "test1234"
        $ipV4AddressMock = "127.0.0.1"
        
        Context "Testing Parameters" {
            It "Should throw when mandatory parameters are not provided" {
                $cmdlet.Parameters.F5Name.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.Token.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.NodeName.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.IpV4Address.Attributes.Mandatory | should be $true
            }
        }

        Context 'Testing function calls Invoke-RestMethod' {

            $mockedHeaders = @{
                'X-F5-Auth-Token' = $tokenMock
            }

            Mock -CommandName Invoke-RestMethod -MockWith {return $true}        
            $splatNewF5Node = @{
                F5Name   = $F5Name
                Token    = $tokenMock
                NodeName = $nodeNameMock
                IpV4Address  = $ipV4AddressMock
            }
            $return = New-F5Node @splatNewF5Node -confirm:$false 

            It "Should return object with correct properties" {
                $return | Should be $true
            }
                
            It 'Assert each mock called 1 time' {
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Uri -eq "https://$F5Name/mgmt/tm/ltm/node" `
                        -and $ContentType -eq 'application/json' `
                        -and $Method -eq 'POST' `
                        -and $Headers.Keys -eq $mockedHeaders.Keys `
                        -and $Headers.Values -eq $mockedHeaders.Values
                } 
            }
        }   
    }
}
