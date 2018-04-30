
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
        $f5member1NameMock = "testServer1"
        $f5member1IpAddresswMock = "127.0.0.1"
        $f5member2NameMock = "testServer2"
        $f5member2IpAddresswMock = "127.0.0.2"

        $f5membersMock = @(
            [F5Member]::New($f5member1NameMock, $f5member1IpAddresswMock)
            [F5Member]::New($f5member2NameMock, $f5member2IpAddresswMock)
        )

        $f5PoolObjectMock = [F5Pool]::New($poolNameMock, $f5membersMock)
        
        Context "Testing Parameters" {
            It "Should throw when mandatory parameters are not provided" {
                $cmdlet.Parameters.F5Name.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.Token.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.F5Pool.Attributes.Mandatory | should be $true
            }
        }
        
        Context 'Testing function Update-F5PoolMember - 2 servers' {

            $mockedHeaders = @{
                'X-F5-Auth-Token' = $tokenMock
            }

            Mock -CommandName Invoke-RestMethod -MockWith {return $true}
            
            $splatUpdateF5Pool = @{
                F5Name = $F5Name
                Token  = $tokenMock
                F5Pool = $f5PoolObjectMock
            }
            $return = Update-F5PoolMember @splatUpdateF5Pool -Confirm:$false

            It "Should return object with correct properties" {
                $return | Should be $true
            }
                
            It 'Assert each mock called 1 time' {
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Uri -eq "https://$F5Name/mgmt/tm/ltm/pool/~Common~$($f5PoolObjectMock.Name)" `
                        -and $ContentType -eq 'application/json' `
                        -and $Method -eq 'Patch' `
                        -and $Headers.Keys -eq $mockedHeaders.Keys `
                        -and $Headers.Values -eq $mockedHeaders.Values `
                        -and ($body | ConvertFrom-Json).Members[0].Name -eq $f5member1NameMock + ":443" `
                        -and ($body | ConvertFrom-Json).Members[1].Name -eq $f5member2NameMock + ":443" 
                } 
            }
        }

        <#
        Context 'Testing function Update-F5PoolMember - 1 server' {

            $mockedHeaders = @{
                'X-F5-Auth-Token' = $tokenMock
            }

            $f5member3NameMock = "testServer3"
            $f5member3IpAddresswMock = "127.0.0.3"

            Mock -CommandName Invoke-RestMethod -MockWith {return $true}
            
            $splatUpdateF5Pool = @{
                F5Name = $F5Name
                Token  = $tokenMock
                F5Pool = $f5PoolObjectMock
            }
            $return = Update-F5PoolMember @splatUpdateF5Pool -Confirm:$false

            It "Should return object with correct properties" {
                $return | Should be $true
            }
                
            It 'Assert each mock called 1 time' {
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
                    $Uri -eq "https://$F5Name/mgmt/tm/ltm/pool/~Common~$($f5PoolObjectMock.Name)" `
                        -and $ContentType -eq 'application/json' `
                        -and $Method -eq 'Patch' `
                        -and $Headers.Keys -eq $mockedHeaders.Keys `
                        -and $Headers.Values -eq $mockedHeaders.Values `
                        -and ($body | ConvertFrom-Json).Members[0].Name -eq $f5member1NameMock + ":443" `
                        -and ($body | ConvertFrom-Json).Members[1].Name -eq $f5member2NameMock + ":443" 
                } 
            }
        }
        #>        
    }
}
