
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
        $memberObjectMock = @(
            [PSCustomObject] @{
                hostname = "TESTWEB01"
                domain =  "think.dev"
                ipaddress = "127.0.0.1"
            },
            [PSCustomObject] @{
                hostname = "TESTWEB02"
                domain =  "think.dev"
                ipaddress = "127.0.0.2"                    
            }
        )
        #$memberObjectMock = $psObjectBody | ConvertTo-Json
        
        Context "Testing Parameters" {
            It "Should throw when mandatory parameters are not provided" {
                $cmdlet.Parameters.F5Name.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.Token.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.PoolName.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.Members.Attributes.Mandatory | should be $true
            }
        }
        <#
        Context 'Testing function calls Invoke-RestMethod' {

            $mockedHeaders = @{
                'X-F5-Auth-Token' = $tokenMock
            }

            Mock -CommandName Invoke-RestMethod -MockWith {return $true}        

            $return = Update-F5PoolMember -F5Name $F5Name -Token $tokenMock -PoolName $poolNameMock -Members $memberObjectMock -Confirm:$false

            It "Should return object with correct properties" {
                $return | Should be $true
            }
                
            It 'Assert each mock called 1 time' {
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Uri -eq "https://$F5Name/mgmt/tm/ltm/pool/~Common~$poolNameMock" `
                        -and $ContentType -eq 'application/json' `
                        -and $Method -eq 'Patch' `
                        -and $Headers.Keys -eq $mockedHeaders.Keys `
                        -and $Headers.Values -eq $mockedHeaders.Values
                } 
            }
        }#>   
    }
}
