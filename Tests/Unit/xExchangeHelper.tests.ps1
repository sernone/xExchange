#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCHelperName = "xExchangeHelper"

# Unit Test Template Version: 1.2.2
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper.psm1')) -Force

#endregion HEADER

function Invoke-TestSetup
{

}

function Invoke-TestCleanup
{

}

# Begin Testing
try
{
    Invoke-TestSetup

    InModuleScope $script:DSCHelperName {

        $getInstallStatusParams = @{
            Arguments = '/mode:Install /role:Mailbox /Iacceptexchangeserverlicenseterms'
        }

        Describe 'xExchangeHelper\Get-InstallStatus' -Tag 'Helper' {
            AfterEach {
                Assert-MockCalled -CommandName Get-ShouldInstallLanguagePack -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Get-IsSetupRunning -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Get-IsSetupComplete -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Get-IsExchangePresent -Exactly -Times 1 -Scope It
            }

            Context 'When Exchange is not present on the system' {
                It 'Should only recommend starting the install' {
                    Mock -CommandName Get-ShouldInstallLanguagePack -MockWith { return $false }
                    Mock -CommandName Get-IsSetupRunning -MockWith { return $false }
                    Mock -CommandName Get-IsSetupComplete -MockWith { return $false }
                    Mock -CommandName Get-IsExchangePresent -MockWith { return $false }

                    $installStatus = Get-InstallStatus @getInstallStatusParams

                    $installStatus.ShouldInstallLanguagePack | Should -Be $false
                    $installStatus.SetupRunning | Should -Be $false
                    $installStatus.SetupComplete | Should -Be $false
                    $installStatus.ExchangePresent | Should -Be $false
                    $installStatus.ShouldStartInstall | Should -Be $true
                }
            }

            Context 'When Exchange Setup has fully completed' {
                It 'Should indicate setup is complete and Exchange is present' {
                    Mock -CommandName Get-ShouldInstallLanguagePack -MockWith { return $false }
                    Mock -CommandName Get-IsSetupRunning -MockWith { return $false }
                    Mock -CommandName Get-IsSetupComplete -MockWith { return $true }
                    Mock -CommandName Get-IsExchangePresent -MockWith { return $true }

                    $installStatus = Get-InstallStatus @getInstallStatusParams

                    $installStatus.ShouldInstallLanguagePack | Should -Be $false
                    $installStatus.SetupRunning | Should -Be $false
                    $installStatus.SetupComplete | Should -Be $true
                    $installStatus.ExchangePresent | Should -Be $true
                    $installStatus.ShouldStartInstall | Should -Be $false
                }
            }

            Context 'When Exchange Setup has partially completed' {
                It 'Should indicate that Exchange is present, but setup is not complete, and recommend starting an install' {
                    Mock -CommandName Get-ShouldInstallLanguagePack -MockWith { return $false }
                    Mock -CommandName Get-IsSetupRunning -MockWith { return $false }
                    Mock -CommandName Get-IsSetupComplete -MockWith { return $false }
                    Mock -CommandName Get-IsExchangePresent -MockWith { return $true }

                    $installStatus = Get-InstallStatus @getInstallStatusParams

                    $installStatus.ShouldInstallLanguagePack | Should -Be $false
                    $installStatus.SetupRunning | Should -Be $false
                    $installStatus.SetupComplete | Should -Be $false
                    $installStatus.ExchangePresent | Should -Be $true
                    $installStatus.ShouldStartInstall | Should -Be $true
                }
            }

            Context 'When Exchange Setup is currently running' {
                It 'Should indicate that Exchange is present and that setup is running' {
                    Mock -CommandName Get-ShouldInstallLanguagePack -MockWith { return $false }
                    Mock -CommandName Get-IsSetupRunning -MockWith { return $true }
                    Mock -CommandName Get-IsSetupComplete -MockWith { return $false }
                    Mock -CommandName Get-IsExchangePresent -MockWith { return $true }

                    $installStatus = Get-InstallStatus @getInstallStatusParams

                    $installStatus.ShouldInstallLanguagePack | Should -Be $false
                    $installStatus.SetupRunning | Should -Be $true
                    $installStatus.SetupComplete | Should -Be $false
                    $installStatus.ExchangePresent | Should -Be $true
                    $installStatus.ShouldStartInstall | Should -Be $false
                }
            }

            Context 'When a Language Pack install is requested, and the Language Pack has not been installed' {
                It 'Should indicate that setup has completed and a language pack Should -Be installed' {
                    Mock -CommandName Get-ShouldInstallLanguagePack -MockWith { return $true }
                    Mock -CommandName Get-IsSetupRunning -MockWith { return $false }
                    Mock -CommandName Get-IsSetupComplete -MockWith { return $true }
                    Mock -CommandName Get-IsExchangePresent -MockWith { return $true }

                    $installStatus = Get-InstallStatus @getInstallStatusParams

                    $installStatus.ShouldInstallLanguagePack | Should -Be $true
                    $installStatus.SetupRunning | Should -Be $false
                    $installStatus.SetupComplete | Should -Be $true
                    $installStatus.ExchangePresent | Should -Be $true
                    $installStatus.ShouldStartInstall | Should -Be $true
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
