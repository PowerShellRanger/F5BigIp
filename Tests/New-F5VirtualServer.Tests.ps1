
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
        $servicePortMock = "HTTPS"

        $virtualServerMock = [VirtualServer] @{
            name        = "test1234"
            destination = "127.0.0.1"
            servicePort = "HTTPS"
        }

        Context "Testing Parameters" {
            It "Should throw when mandatory parameters are not provided" {
                $cmdlet.Parameters.F5Name.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.Token.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.VirtualServer.Attributes.Mandatory | should be $true
            }
        }

        Context 'Testing function calls New-F5VirtualServer' {

            $mockedHeaders = @{
                'X-F5-Auth-Token' = $tokenMock
            }

            Mock -CommandName Invoke-RestMethod -MockWith {return $true}        

            $splatNewF5VirtualServer = @{
                F5Name        = $F5Name
                Token         = $tokenMock
                VirtualServer = $virtualServerMock
            }
            $return = New-F5VirtualServer @splatNewF5VirtualServer -confirm:$false
            
            It "Should return object with correct properties" {
                $return | Should be $true
            }
            

            It 'Assert Invoke-RestMethod Mock is called 1 time and validate paramters stay as expected' {
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Uri -eq "https://$F5Name/mgmt/tm/ltm/virtual" `
                        -and $ContentType -eq 'application/json' `
                        -and $Method -eq 'Post' `
                        -and $Headers.Keys -eq $mockedHeaders.Keys `
                        -and $Headers.Values -eq $mockedHeaders.Values `
                        -and ($Body | ConvertFrom-Json).Name -eq $virtualServerMock.name `
                        -and ($Body | ConvertFrom-Json).Destination -eq "/Common/$($virtualServerMock.destination):443" `
                        -and ($Body | ConvertFrom-Json).profiles[0].name -eq "http"
                } 
            }
        }
        
        Context 'Testing function calls New-F5VirtualServer with HTTP port' {
            
            $virtualServerMock = [VirtualServer] @{
                name        = "test1234"
                destination = "127.0.0.1"
                servicePort = "HTTP"
            }

            Mock -CommandName Invoke-RestMethod -MockWith {return $true}        

            $splatNewF5VirtualServer = @{
                F5Name        = $F5Name
                Token         = $tokenMock
                VirtualServer = $virtualServerMock
            }
            $return = New-F5VirtualServer @splatNewF5VirtualServer -confirm:$false
            
            It "Should return object with correct properties" {
                $return | Should be $true
            }

            It 'Assert Invoke-RestMethod Mock is called 1 time and validate paramters stay as expected' {
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
                    ($Body | ConvertFrom-Json).Destination -eq "/Common/$($virtualServerMock.destination):80"
                } 
            }
        }        
        
        Context 'Testing function calls New-F5VirtualServer w/PoolName' {

            Mock -CommandName Invoke-RestMethod -MockWith {return $true}        
            
            $poolNameMock = "TestPool"

            $splatNewF5VirtualServer = @{
                F5Name        = $F5Name
                Token         = $tokenMock
                VirtualServer = $virtualServerMock
                PoolName      = $poolNameMock
            }
            $return = New-F5VirtualServer @splatNewF5VirtualServer -confirm:$false
            
            It "Should return object with correct properties" {
                $return | Should be $true
            }

            It 'Assert Invoke-RestMethod Mock is called 1 time and validate paramters stay as expected' {
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
                   ($Body | ConvertFrom-Json).pool -eq "/Common/$poolNameMock"
                } 
            }
        }
        
        Context 'Testing function calls New-F5VirtualServer w/ClientSSLProfileName' {

            Mock -CommandName Invoke-RestMethod -MockWith {return $true}        

            $clientSslProfileNameMock = "TestClientSSLProfile"

            $splatNewF5VirtualServer = @{
                F5Name               = $F5Name
                Token                = $tokenMock
                VirtualServer        = $virtualServerMock
                ClientSSLProfileName = $clientSslProfileNameMock
            }
            $return = New-F5VirtualServer @splatNewF5VirtualServer -confirm:$false
            
            It "Should return object with correct properties" {
                $return | Should be $true
            }

            It 'Assert Invoke-RestMethod Mock is called 1 time and validate paramters stay as expected' {
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
                   ($Body | ConvertFrom-Json).profiles | Where-Object { $_.Name -like $clientSslProfileNameMock} 
                } 
            }            
        }        
    }
}
