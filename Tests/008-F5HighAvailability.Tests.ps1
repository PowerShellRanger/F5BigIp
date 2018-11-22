
$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf

Get-Module -Name $moduleName -All | Remove-Module -Force
Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force

InModuleScope -ModuleName $moduleName {

    Describe 'F5HighAvailability Class' {
        
        $tokenMock = 'IHH5ILDD6V4ZO43SEUFZEFOZAD'
        $f5Name = 'foo'
        $session = [F5Session]::New()
        $session.F5Name = $f5Name
        $session.Token = $tokenMock
        $session.Header = @{'X-F5-Auth-Token' = $tokenMock}

        $invokeRestResponse = @{
            Entries = @{
                'https://localhost/mgmt/tm/cm/failover-status/0' = @{
                    nestedStats = @{
                        entries = @{
                            status = @{
                                description = 'ACTIVE'
                            }
                        }
                    }
                }
            }
        }

        Context 'Testing IsActiveNode Method when node is ACTIVE node in cluster' {            
                        
            Mock -CommandName Invoke-RestMethod -MockWith {return $invokeRestResponse} -Verifiable

            $result = [F5HighAvailability]::IsActiveHaNode($session)
            
            It 'Should call Invoke-RestMethod one time' {                        
                
                Assert-MockCalled -CommandName Invoke-RestMethod -Scope Context -Times 1 -Exactly -ParameterFilter {
                    $Uri -eq "https://$f5Name/mgmt/tm/cm/failover-status" `
                        -and $ContentType -eq 'application/json' `
                        -and $Method -eq 'GET'                        
                }
            }

            It 'Should return True if node is Active in HA Cluster' {
                $result | Should be $true
            }
        }

        Context 'Testing IsActiveNode Method when node is NOT ACTIVE node in cluster' {
            
            $invokeRestResponse.entries.'https://localhost/mgmt/tm/cm/failover-status/0'.nestedStats.entries.status.description = ''

            Mock -CommandName Invoke-RestMethod -MockWith {return $invokeRestResponse}
            
            $result = [F5HighAvailability]::IsActiveHaNode($session)
                    
            It 'Should return False when node is not Active in HA Cluster' {
                $result | Should be $false
            }

        }
    }
}
