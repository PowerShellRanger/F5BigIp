
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
                $cmdlet.Parameters.F5Name.Attributes.Mandatory | should be @($true, $true)
                $cmdlet.Parameters.Token.Attributes.Mandatory | should be @($true, $true)                                
            }

            It "Should have non-mandatory parameters and not throw when they are not used" {
                $cmdlet.Parameters.CertificateName.Attributes.Mandatory | should be $false
                $cmdlet.Parameters.GetAllCertificates.Attributes.Mandatory | should be $false
            }

            It "CertificateName parameter should accept an array of strings" {
                $cmdlet.Parameters.CertificateName.ParameterType.Name | should be 'String[]'
            }
        }

        Context 'Testing function calls Invoke-RestMethod' {            

            Mock -CommandName Invoke-RestMethod -MockWith {}

            $f5Name = 'foo'
            $token = ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_}) -join ''

            It "Should Invoke-RestMethod to get all Certificates when GetAllCertificates switch is used" {                
                $null = Get-F5SslCertificate -F5Name $f5Name -Token $token -GetAllCertificates
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {$Uri -eq "https://$f5Name/mgmt/tm/sys/file/ssl-cert"}
            }

            It "Should Invoke-RestMethod to get one Certificate when CertificateName parameter is used" {                
                $certificate = 'fooCert.crt'
                $null = Get-F5SslCertificate -F5Name $f5Name -Token $token -CertificateName $certificate
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {$Uri -eq "https://$f5Name/mgmt/tm/sys/file/ssl-cert/~Common~$certificate"}
            }
        }        
    }
}
