
$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf

Get-Module -Name $moduleName -All | Remove-Module -Force
Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force

InModuleScope -ModuleName $moduleName {

    $sut = Split-Path $MyInvocation.MyCommand.ScriptBlock.File -Leaf
    $cmdletName = $sut.Split('.')[0]
    $cmdlet = Get-Command -Name $cmdletName

    Describe 'Set-F5MaintenanceMode' {        

        Context 'Testing Parameters' {            

            It "Should throw when mandatory parameters are not provided" {
                $cmdlet.Parameters.Name.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.MaintenanceMode.Attributes.Mandatory | should be $true
            }        
        }
        <#
        Context 'Testing function validates an iRule with Get-F5iRule' {

            Mock -CommandName Get-F5iRule -MockWith {} -Verifiable

            Set-F5MaintenanceMode -Name foo -MaintenanceMode Off -Confirm:$false

            It 'Should call the Get-F5iRule function 1 time' {
                Assert-MockCalled -CommandName Get-F5iRule -Times 1 -Exactly -Scope Context
            }            
        }
        #>        
    }
}
