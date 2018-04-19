
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
                $cmdlet.Parameters.F5Name.Attributes.Mandatory | should be $true
                $cmdlet.Parameters.Credential.Attributes.Mandatory | should be $true
            }        
        }

        Context 'Testing function calls Invoke-RestmMthod' {

            $tokenMock = ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_}) -join ''
            $mockedResponse = @{
                UserName = $env:USERNAME
                Token    = $tokenMock
            }

            Mock -CommandName Invoke-RestMethod -MockWith {return $mockedResponse}

            $F5Name = 'foo'
            $securePass = ConvertTo-SecureString -String 'Some Really Complex Password' -AsPlainText -Force
            $credential = New-Object -TypeName System.Management.Automation.PSCredential ($env:USERNAME, $securePass)
            $psObjectBody = [PSCustomObject] @{
                username          = $credential.UserName
                password          = $credential.GetNetworkCredential().Password
                loginProviderName = "tmos"
            }
            $bodyMock = $psobjectBody | ConvertTo-Json

            $newApiToken = New-F5RestApiToken -F5Name $F5Name -Credential $credential -Confirm:$false

            It "Should return two objects with correct properties" {                
                foreach ($property in $newApiToken.PSObject.Properties)
                {
                    $newApiToken.$property | Should Be $mockedResponse.$property
                }
            }

            It 'Assert each mock called 1 time' {                
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {$Uri -eq "https://$F5Name/mgmt/shared/authn/login"}
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {$ContentType -eq 'application/json'}
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {$Method -eq 'Post'}
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {$Body -eq $bodyMock}
            }
        }        
    }
}
