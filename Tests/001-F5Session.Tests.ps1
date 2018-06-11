
$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf

Get-Module -Name $moduleName -All | Remove-Module -Force
Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force

InModuleScope -ModuleName $moduleName {

    Describe 'F5Session Class' {        

        Context 'Instantiate a new object' {
            
            $session = [F5Session]::New()            

            It 'Should not throw an error' {
                {[F5Session]::New()} | should not throw
            }
            It 'Should create an object with correct properties' {                
                $properties = 'F5Name', 'Token', 'UserName', 'Header', 'Credential'
                
                foreach ($property in $session.psobject.Properties.Name)
                {
                    $properties | should contain $property
                }
            }
            It 'Should create an object of the correct type' {
                $session -is [F5Session] | should be $true
            }
        }

        Context 'Testing GetToken Method' {

            $f5User = 'f5.user'
            $f5Pass = 'f5.pass'

            # build a credential object
            $securePass = ConvertTo-SecureString -String $f5Pass -AsPlainText -Force
            $credential = New-Object -TypeName System.Management.Automation.PSCredential ($f5User, $securePass)
            $tokenMock = [PSCustomObject] @{
                Token = [PSCustomObject] @{
                    Token = 'IHH5ILDD6V4ZO43SEUFZEFOZAD'
                }
            }
                        
            Mock -CommandName Invoke-RestMethod -MockWith {return $tokenMock} -Verifiable
            
            It 'Should call Invoke-RestMethod one time' {
            
                $token = [F5Session]::GetToken('F5Name', $credential)                
                
                Assert-MockCalled -CommandName Invoke-RestMethod -Scope It -Times 1 -Exactly -ParameterFilter {
                    $Uri -eq "https://F5name/mgmt/shared/authn/login" `
                        -and $ContentType -eq 'application/json' `
                        -and $Method -eq 'POST' `
                        -and ($body | ConvertFrom-Json).username -eq $f5User `
                        -and ($body | ConvertFrom-Json).password -eq $f5Pass `
                        -and ($body | ConvertFrom-Json).loginProviderName -eq 'tmos'
                }
            }
        }
    }
}
