
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
        $clientSslProfileNameMock = "testClientSslProfile"
        $certificateNameMock = "testClientSsl.crt"
        $caBundleMock = "ca-bundle.crt"
        
        $splatAddF5ClientSslProfile = @{                    
            F5Name               = $F5Name
            Token                = $tokenMock
            ClientSslProfileName = $clientSslProfileNameMock
            CertificateName      = $certificateNameMock
            CABundleName         = $caBundleMock
            DefaultSni           = "false"               
        }
        
        Context "Testing Parameters" {
            It "Should throw when mandatory parameters are not provided" {
                $cmdlet.Parameters.F5Name.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.ClientSslProfileName.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.CertificateName.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.CABundleName.Attributes.Mandatory | should be $false
                $cmdlet.Parameters.DefaultSni.Attributes.Mandatory | should be $false
            }
        }
        
        Context 'Testing creating new Client SSL Profile' {           
            $clientSslProfileMock = @(
                [PSCustomObject] @{
                    name       = "testProfile"
                    cert       = "/Common/$($certificateNameMock).crt"
                    key        = "/Common/$($certificateNameMock).key"
                    chain      = "/Common/$caBundleMock"
                    sniDefault = "false"
                }
            )
            
            Mock -CommandName Invoke-RestMethod -MockWith {return $true}
            Mock -CommandName Get-F5ClientSslProfile -MockWith {return $clientSslProfileMock}
            Mock -CommandName Update-F5ClientSslProfile -MockWith {return $true}
            Mock -CommandName New-F5ClientSslProfile -MockWith {return $true}
                        
            $return = Add-F5ClientSslProfile @splatAddF5ClientSslProfile -Confirm:$false
            
            It "Should return object with correct properties" {
                $return | Should be $true
            }
        }        
        
        <#
        Context 'Testing if IP of new node is used buy another node' {
            $nodeMock = [PSCustomObject] @{
                name    = "test1235"
                address = $ipV4AddressMock 
            }

            Mock -CommandName Get-F5Node -MockWith {return $nodeMock}
            Mock -CommandName Update-F5Node -MockWith {return $true}
            Mock -CommandName New-F5Node -MockWith {return $true}

            $return = Add-F5Node @splatAddF5Node -Confirm:$false

            It "Should return object with correct properties" {
                $return | Should be $null
            }
        }

        Context 'Testing if IP of new node is used buy another node' {
            $nodeMock = @(
                [PSCustomObject] @{
                    name    = "test1235"
                    address = $ipV4AddressMock
                },
                [PSCustomObject] @{
                    name    = $nodeNameMock
                    address = "127.0.0.2"
                }
            )

            Mock -CommandName Get-F5Node -MockWith {return $nodeMock}
            Mock -CommandName Update-F5Node -MockWith {return $true}
            Mock -CommandName New-F5Node -MockWith {return $true}

            $return = Add-F5Node @splatAddF5Node -Confirm:$false

            It "Should return object with correct properties" {
                $return | Should be $null
            }
        }

        Context 'Testing if IP of new node is used buy another node w/Force' {
            $nodeMock = @(
                [PSCustomObject] @{
                    name    = "test1235"
                    address = $ipV4AddressMock
                },
                [PSCustomObject] @{
                    name    = $nodeNameMock
                    address = "127.0.0.2"
                }
            )

            Mock -CommandName Get-F5Node -MockWith {return $nodeMock}
            Mock -CommandName Update-F5Node -MockWith {return $true}
            Mock -CommandName New-F5Node -MockWith {return $true}

            $return = Add-F5Node @splatAddF5Node -Force -Confirm:$false

            It "Should return object with correct properties" {
                $return | Should be $true
            }
        }        

        Context 'Testing if IP of new node is used buy another node w/Force' {
            $nodeMock = @(
                [PSCustomObject] @{
                    name    = "test1235"
                    address = "127.0.0.2"
                }
            )

            Mock -CommandName Get-F5Node -MockWith {return $nodeMock}
            Mock -CommandName Update-F5Node -MockWith {return $true}
            Mock -CommandName New-F5Node -MockWith {return $true}

            $return = Add-F5Node @splatAddF5Node -Force -Confirm:$false

            It "Should return object with correct properties" {
                $return | Should be $true
            }
        }
        #>  
    }
}
