
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
        $certificateNameMock = "testcert.crt"
        $newCertificateNameMock = $CertificateNameMock.Replace(".crt", "")
        $caBundleNameMock = "test-bundle.crt"
        $defaultSniMock = $false
        
        Context "Testing Parameters" {
            It "Should throw when mandatory parameters are not provided" {
                $cmdlet.Parameters.F5Name.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.Token.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.ClientSslProfileName.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.CertificateName.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.CABundleName.Attributes.Mandatory | should be $false
                $cmdlet.Parameters.DefaultSni.Attributes.Mandatory | should be $false
            }
        }

        Context 'Testing function calls Invoke-RestMethod' {

            $mockedHeaders = @{
                'X-F5-Auth-Token' = $tokenMock
            }

            Mock -CommandName Invoke-RestMethod -MockWith {return $true}        

            $newNode = New-F5ClientSslProfile -F5Name $F5Name -Token $tokenMock -ClientSslProfileName $clientSslProfileNameMock `
                 -CertificateName $certificateNameMock -CABundleName $caBundleNameMock -DefaultSni $defaultSniMock -Confirm:$false

            It "Should return object with correct properties" {
                $newNode | Should be $true
            }
                
            It 'Assert each mock called 1 time' {
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Uri -eq "https://$F5Name/mgmt/tm/ltm/profile/client-ssl" `
                        -and $ContentType -eq 'application/json' `
                        -and $Method -eq 'POST' `
                        -and $Headers.Keys -eq $mockedHeaders.Keys `
                        -and $Headers.Values -eq $mockedHeaders.Values `
                        -and ($Body | ConvertFrom-Json).name -eq "$clientSslProfileNameMock" `
                        -and ($Body | ConvertFrom-Json).cert -eq "/Common/$($newCertificateNameMock).crt" `
                        -and ($Body | ConvertFrom-Json).key -eq "/Common/$($newCertificateNameMock).key" `
                        -and ($Body | ConvertFrom-Json).chain -eq "/Common/$($caBundleNameMock)" `
                        -and ($Body | ConvertFrom-Json).sniDefault -eq "$defaultSniMock"
                } 
            }
        }   
    }
}
