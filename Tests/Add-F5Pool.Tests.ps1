
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
        $psObjectPoolMock = [PSCustomObject]@{
            name = "$poolNameMock"
            members = @()
        }
        $psObjectMembersMock = @(
            [PSCustomObject] @{
                hostname  = "TESTWEB01"
                domain    = "think.dev"
                ipaddress = "127.0.0.1"
            },
            [PSCustomObject] @{
                hostname  = "TESTWEB02"
                domain    = "think.dev"
                ipaddress = "127.0.0.2"                    
            }
        )
        $memberObjectMock = $psObjectMembersMock | ConvertTo-Json        
        
        Context "Testing Parameters" {
            It "Should throw when mandatory parameters are not provided" {
                $cmdlet.Parameters.F5Name.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.Token.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.PoolName.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.Members.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.Monitor.Attributes.Mandatory | should be $true
            }
        }

        Context 'Testing adding new pool' {
           
            Mock -CommandName Get-F5Pool -MockWith {return $true}
            Mock -CommandName Get-F5PoolMember -MockWith {return $psObjectMembersMock}
            Mock -CommandName New-F5Pool -MockWith {return $true}            
            Mock -CommandName Update-F5PoolMember -MockWith {return $true}
            
            $splatNewF5Pool = @{                    
                F5Name   = $F5Name
                Token    = $tokenMock
                PoolName = $poolNameMock
                Monitor  = "HTTPS"
                Members  = $memberObjectMock
            }
            $return = Add-F5Pool @splatNewF5Pool -confirm:$false 

            It "Should return object with correct properties" {
                $return | Should be $true
            }
        }        

        Context 'Testing that all servers are in a pre-existing pool already' {
           
            Mock -CommandName Get-F5Pool -MockWith {return $psObjectPoolMock}
            Mock -CommandName Get-F5PoolMember -MockWith {return $psObjectMembersMock}
            Mock -CommandName New-F5Pool -MockWith {return $true}            
            Mock -CommandName Update-F5PoolMember -MockWith {return $true}
            
            $splatNewF5Pool = @{                    
                F5Name   = $F5Name
                Token    = $tokenMock
                PoolName = $poolNameMock
                Monitor  = "HTTPS"
                Members  = $memberObjectMock
            }
            $return = Add-F5Pool @splatNewF5Pool -confirm:$false 

            It "Should return object with correct properties" {
                $return | Should be $null
            }
        }

        Context 'Testing adding one server to a pre-existing pool with one server'  {
           
            Mock -CommandName Get-F5Pool -MockWith {return $psObjectPoolMock}
            Mock -CommandName Get-F5PoolMember -MockWith {return $psObjectMembersMock[0]}
            Mock -CommandName New-F5Pool -MockWith {return $true}            
            Mock -CommandName Update-F5PoolMember -MockWith {return $true}
            
            $splatNewF5Pool = @{                    
                F5Name   = $F5Name
                Token    = $tokenMock
                PoolName = $poolNameMock
                Monitor  = "HTTPS"
                Members  = $memberObjectMock
            }
            $return = Add-F5Pool @splatNewF5Pool -confirm:$false 

            It "Should return object with correct properties" {
                $return | Should be $true
            }
        }

        Context 'Testing add multiple servers to an empty pool'  {
           
            Mock -CommandName Get-F5Pool -MockWith {return $psObjectPoolMock}
            Mock -CommandName Get-F5PoolMember -MockWith {return $true}
            Mock -CommandName New-F5Pool -MockWith {return $true}            
            Mock -CommandName Update-F5PoolMember -MockWith {return $true}
            
            $splatNewF5Pool = @{                    
                F5Name   = $F5Name
                Token    = $tokenMock
                PoolName = $poolNameMock
                Monitor  = "HTTPS"
                Members  = $memberObjectMock
            }
            $return = Add-F5Pool @splatNewF5Pool -confirm:$false 

            It "Should return object with correct properties" {
                $return | Should be $true
            }
        }
    }
}
