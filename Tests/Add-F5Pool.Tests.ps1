
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
        
        $f5PoolObjectMock = [F5Pool]::New($poolNameMock)        
                
        $membersMockWithItems = [PSCustomObject] @{
            Items = @(
                [F5Member]::New($f5member1NameMock, $f5member1IpAddresswMock),
                [F5Member]::New($f5member2NameMock, $f5member2IpAddresswMock)
            )
        }

        $splatAddF5Pool = @{                    
            F5Name  = $F5Name
            Token   = $tokenMock
            F5Pool  = $f5PoolObjectMock                
        }
        
        Context "Testing Parameters" {
            It "Should throw when mandatory parameters are not provided" {
                $cmdlet.Parameters.F5Name.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.Token.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.F5Pool.Attributes.Mandatory | should be $true
            }
        }
        
        Context 'Testing adding new pool' {
           
            $membersMock = @(
                [F5Member]::New($f5member1NameMock, $f5member1IpAddresswMock),
                [F5Member]::New($f5member2NameMock, $f5member1IpAddresswMock)
            )
            $f5PoolObjectMock.Members = $membersMock

            Mock -CommandName Get-F5Pool -MockWith {return $true}
            Mock -CommandName Get-F5PoolMember -MockWith {return $membersMockWithItems}
            Mock -CommandName New-F5Pool -MockWith {return $true}            
            Mock -CommandName Update-F5PoolMember -MockWith {return $true}
                        
            $return = Add-F5Pool @splatAddF5Pool -Confirm:$false
            
            It "Should return object with correct properties" {
                $return | Should be $true
            }
        }        
        
        Context 'Testing that all servers are in a pre-existing pool already' {
           
            Mock -CommandName Get-F5Pool -MockWith {return $f5PoolObjectMock}
            Mock -CommandName Get-F5PoolMember -MockWith {return $membersMockWithItems}
            Mock -CommandName New-F5Pool -MockWith {return $true}            
            Mock -CommandName Update-F5PoolMember -MockWith {return $true}

            $return = Add-F5Pool @splatAddF5Pool -Confirm:$false

            It "Should return object with correct properties" {
                $return | Should be $null
            }
        }

        
        Context 'Testing adding one server to a pre-existing pool with one server' {
 
            $membersMockWithItems = [PSCustomObject] @{
                Items = @(
                    [F5Member]::New('TESTWEB01', '127.0.0.1')                    
                )
            }
           
            Mock -CommandName Get-F5Pool -MockWith {return $f5PoolObjectMock}
            Mock -CommandName Get-F5PoolMember -MockWith {return $membersMockWithItems}
            Mock -CommandName New-F5Pool -MockWith {return $true}            
            Mock -CommandName Update-F5PoolMember -MockWith {return $true}
                        
            $return = Add-F5Pool @splatAddF5Pool -Confirm:$false 

            It "Should return object with correct properties" {
                $return | Should be $true
            }
        }

        Context 'Testing add multiple servers to an empty pool' {
           
            Mock -CommandName Get-F5Pool -MockWith {return $f5PoolObjectMock}
            Mock -CommandName Get-F5PoolMember -MockWith {return $true}
            Mock -CommandName New-F5Pool -MockWith {return $true}
            Mock -CommandName Update-F5PoolMember -MockWith {return $true}
            
            $return = Add-F5Pool @splatAddF5Pool -Confirm:$false 

            It "Should return object with correct properties" {
                $return | Should be $true
            }
        }
        
    }
}
