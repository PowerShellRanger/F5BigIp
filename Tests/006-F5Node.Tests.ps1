
$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf

Get-Module -Name $moduleName -All | Remove-Module -Force
Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force

InModuleScope -ModuleName $moduleName {

    Describe 'F5Node Class' {

        BeforeAll {            
            $tokenMock = 'IHH5ILDD6V4ZO43SEUFZEFOZAD'
            $F5Name = 'foo'
            $session = [F5Session]::New()
            $session.F5Name = $F5Name
            $session.Token = $tokenMock
            $session.Header = @{'X-F5-Auth-Token' = $tokenMock}
        }

        BeforeEach {
            $resource = [F5Node]::New()
            $resource.Name = 'TestServer'
            $resource.IpAddress = '127.0.0.5'
        }
        <#
        Context "When the Create method is called" {
            
            Mock -CommandName Invoke-RestMethod -MockWith {} -Verifiable

            It 'Should not return output' {
                $resource.Create($session) | should be $null
            }
            It 'Should call Invoke-RestMethod one time' {
                Assert-MockCalled -CommandName Invoke-RestMethod -Scope Context -Times 1 -Exactly -ParameterFilter {
                    $Uri -eq "https://$($session.F5Name)/mgmt/tm/ltm/node" `
                        -and $ContentType -eq 'application/json' `
                        -and $Method -eq 'POST'
                }
            }
        }
        
        Context "When the Update method is called" {
            It 'Should not throw an error' {
                {$resource.Update($Script:F5Session)} | Should Not Throw

                Assert-MockCalled -CommandName Invoke-RestMethod -Scope It -Times 1 -Exactly -ParameterFilter {
                    $Uri -eq "https://$($script:F5Session.F5Name)/mgmt/tm/ltm/node/~Common~$($resource.Name)" `
                        -and $Method -eq 'PUT' `
                        -and ($body | ConvertFrom-Json).address -eq $resource.IpAddress
                }
            }
        }

        Context "When the SetState method is called" {
            $states = @('enable', 'disable', 'forceoffline')
            $status = [PSCustomObject] @{
                state   = $null
                session = $null
            }
            ForEach ($state in $states)
            {
                It "Should not throw an error with $($state) as the value" {
                    {$resource.SetState($state, $Script:F5Session)} | Should Not Throw

                    Switch ($state)
                    {
                        'enable' {$status.state = 'user-up'; $status.session = 'user-enabled'}
                        'disable' {$status.state = $null; $status.session = 'user-disabled'}
                        'forceoffline' {$status.state = 'user-down'; $status.session = 'user-disabled'}
                    }
                    Assert-MockCalled -CommandName Invoke-RestMethod -Scope It -Times 1 -Exactly -ParameterFilter {
                        $Uri -eq "https://$($script:F5Session.F5Name)/mgmt/tm/ltm/node/~Common~$($resource.Name)" `
                            -and $Method -eq 'PATCH' `
                            -and ($body | ConvertFrom-Json).state -eq $status.state `
                            -and ($body | ConvertFrom-Json).session -eq $status.session
                    }
                }
            }
        }

        Context "When the Delete method is called" {
            It 'Should not throw an error' {
                {$resource.Delete($Script:F5Session)} | Should Not Throw

                Assert-MockCalled -CommandName Invoke-RestMethod -Scope It -Times 1 -Exactly -ParameterFilter {
                    $Uri -eq "https://$($script:F5Session.F5Name)/mgmt/tm/ltm/node/~Common~$($resource.Name)" `
                        -and $Method -eq 'DELETE'
                }
            }
        }
        #>
    }
}
