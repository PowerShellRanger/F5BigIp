
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
        $clientSslProfileNameMock = "test1234"
        
        Context 'Validating mandatory parameters' {
            It 'Should throw when mandatory parameters are not provided' {
                $cmdlet.Parameters.F5Name.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.Token.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.ClientSslProfileName.Attributes.Mandatory | should be $true
            }
        }

        Context 'Testing function - Calls Clear-F5ClientSslProfile' {

            $mockedHeaders = @{
                'X-F5-Auth-Token' = $tokenMock
            }

            Mock -CommandName Invoke-RestMethod -MockWith {return $true}        

            $return = Clear-F5ClientSslProfile -F5Name $F5Name -Token $tokenMock -ClientSslProfileName $clientSslProfileNameMock -confirm:$false 

            It 'Validating function returns values' {
                $return | Should be $true
            }
                
            It 'Validating Invoke-RestMethod parameters in function' {
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Uri -eq "https://$F5Name/mgmt/tm/ltm/profile/client-ssl/~Common~$ClientSslProfileNameMock" `
                        -and $ContentType -eq 'application/json' `
                        -and $Method -eq 'Delete' `
                        -and $Headers.Keys -eq $mockedHeaders.Keys `
                        -and $Headers.Values -eq $mockedHeaders.Values
                } 
            }
        }   
    }
}
