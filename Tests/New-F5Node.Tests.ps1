
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
        
        Context "Testing Parameters" {            

            It "Should throw when mandatory parameters are not provided" {
                $cmdlet.Parameters.F5Name.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.Token.Attributes.Mandatory | should be $false
                $cmdlet.Parameters.NodeName.Attributes.Mandatory | should be $false
                $cmdlet.Parameters.IpV4Address.Attributes.Mandatory | should be $false
            }        
        }

        Context 'Testing function calls Invoke-RestmMthod' {

            $mockedResponse = @{
                kind      = "tm:ltm:node:nodestate"
                name      = "test1234"
                partition = "Common"
                address   = "10.209.11.24"
                logging   = "disabled"
                monitor   = "default"
                rateLimit = "disabled"
                ratio     = "1"
                session   = "monitor-enabled"
                state     = "checking"
            }

            Mock -CommandName Invoke-RestMethod -MockWith {return $mockedResponse}

            $tokenMock = "IHH5ILDD6V4ZO43SEUFZEFOZAD"
            $F5Name = 'foo'
            $nodeNameMock = "test1234"
            $ipV4AddressMock = "10.209.11.24"
            $psObjectHeader = [PSCustomObject] @{
                'X-F5-Auth-Token' = $tokenMock
            }
            $headerMock = $psobjectHeader | ConvertTo-Json            
            $psObjectBody = [PSCustomObject] @{
                node    = $nodeNameMock
                address = $ipV4AddressMock
            }
            $bodyMock = $psobjectBody | ConvertTo-Json

            $newNode = New-F5Node -F5Name $F5Name -Token $tokenMock -NodeName $nodeNameMock -IpV4Address $ipV4AddressMock -confirm:$false

            It "Should return object with correct properties" {                
                foreach ($property in $newNode.PSObject.Properties)
                {
                    $newNode.$property | Should Be $mockedResponse.$property
                }
            }

            It 'Assert each mock called 1 time' {                
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {$Uri -eq "https://$F5Name/mgmt/tm/ltm/node"}
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {$ContentType -eq 'application/json'}
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {$Method -eq 'Post'}
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {$Body -eq $bodyMock}
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {$Header -eq $headerMock}
            }
        }        
    }
}
