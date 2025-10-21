$manifestContent = Get-Content -Path "manifest1.json" -Raw -Encoding UTF8
$manifestData = ConvertFrom-Json -InputObject $manifestContent
$settingsContent = Get-Content -Path "settings.json" -Raw -Encoding UTF8
$settingsData = ConvertFrom-Json -InputObject $settingsContent

function PrintStep {
    param(
        [string]$Step
    )
    Write-Host "`n[STEP] $Step" -ForegroundColor Yellow
}

function RefreshPath {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

foreach ($step in $manifestData.PSObject.Properties) {
    try {
        if($step.Value.stepSuccess -eq $true){
            continue
        }
		PrintStep -Step $step.Name
		switch ($step.Name){
			"wslInstall" {
				Write-Host "Installing wsl with $($settingsData.disto)" -ForegroundColor Blue
				Invoke-Expression "wsl --install --web-download -d `"$($settingsData.distro)`""
				Write-Host "Setting WSL default version to 2" -ForegroundColor Blue
				Invoke-Expression "wsl --set-default-version 2"

				Write-Host "[STEP] $($step.Name) successful" -ForegroundColor Green  
				Write-Host "[WARNING] Please Restart your computer and re-run these script" -ForegroundColor Yellow 
				$step.Value.stepSuccess = $true
				exit 0 # Exit for restart
			}
			"git" {
				if($step.Value.wingetSuccess -eq $false){
					Write-Host "Running $($step.Value.wingetCmd)" -ForegroundColor Blue
					Invoke-Expression $step.Value.wingetCmd
					RefreshPath
					$step.Value.wingetSuccess = $true
							
				}
				Write-Host "Running git config --global user.name $($settingsData.gitCreds.name)" -ForegroundColor Blue
				Invoke-Expression "git config --global user.name `"$($settingsData.gitCreds.name)`""				
				Write-Host "Running  git config --global user.email $($settingsData.gitCreds.email)" -ForegroundColor Blue
                Invoke-Expression "git config --global user.email `"$($settingsData.gitCreds.email)`""
				Write-Host "Running git config --global core.autocrlf input" -ForegroundColor Blue
				Invoke-Expression "git config --global core.autocrlf input"
	
				Write-Host "[STEP] $($step.Name) successful" -ForegroundColor Green    
				
				break
			}
			"docker" {
				if($step.Value.wingetSuccess -eq $false){
					Write-Host "Running $($step.Value.wingetCmd)" -ForegroundColor Blue
					Invoke-Expression $step.Value.wingetCmd
					$step.Value.wingetSuccess = $true
					RefreshPath
				}
				Write-Host "`n[INFO] Docker Desktop installed successfully" -ForegroundColor Green
				Write-Host "`nManual steps required:" -ForegroundColor Yellow
				foreach ($manualStep in $step.Value.manualSteps) {
					Write-Host "  $manualStep" -ForegroundColor Gray
				}
				Write-Host "`nPress Enter after you've completed these steps to continue..." -ForegroundColor Cyan
				Read-Host
				# Now test if docker is available
				try {
					Invoke-Expression "docker --version"
					break
				} 
				catch {
					Write-Host "[ERROR] Docker not available yet. Please ensure Docker Desktop is running." -ForegroundColor Red
					exit 1
				}
			}
			"vsCode" {
				if($step.Value.wingetSuccess -eq $false){
					Write-Host "Running $($step.Value.wingetCmd)" -ForegroundColor Blue
					Invoke-Expression $step.Value.wingetCmd
					$step.Value.wingetSuccess = $true
				}
				RefreshPath
	
				foreach ($ext in $settingsData.vsCodeExtensions) {
					Write-Host "Adding VsCode extension: $($ext)" -ForegroundColor Blue
					Invoke-Expression "code --install-extension `"$($ext)`""
				}
				break
			}
            "githubCLI" {
                if($step.Value.wingetSuccess -eq $false){
					    Write-Host "Getting the GitHub CLI with $($step.Value.wingetCmd)" -ForegroundColor Blue
					    Invoke-Expression $step.Value.wingetCmd
					    $step.Value.wingetSuccess = $true
				}
                RefreshPath
                Write-Host "Authenticating GitHub" -ForegroundColor Blue
				Invoke-Expression "gh auth login"
            }
            "projects" {
                Write-Host "Cloning Repos" -ForegroundColor Blue
                
                # Ensure dev directory exists
                if (!(Test-Path $settingsData.devDir)) {
                    New-Item -ItemType Directory -Force -Path $settingsData.devDir | Out-Null
                    Write-Host "Created directory: $($settingsData.devDir)" -ForegroundColor Green
                }
                
                foreach ($project in $settingsData.projects) {
                    Write-Host "`nProject: $($project.name)" -ForegroundColor Yellow
                    if ($project.multiRepo -eq $true) {
                        # Clone backend repo
                        $backendPath = "$($settingsData.devDir)\$($project.backendName)"
                        
                        if (!(Test-Path $backendPath)) {
                            Write-Host "Cloning backend to: $backendPath" -ForegroundColor Blue
                            # Invoke-Expression "gh repo clone $($project.backendRepo) `"$backendPath`""
							& gh repo clone $project.backendRepo $backendPath
							if ($LASTEXITCODE -ne 0) {
    							throw "Failed to clone backend repo"
							}
                        } else {
                            Write-Host "Backend already exists at: $backendPath" -ForegroundColor Gray
                        }
                        
                        # Clone frontend repo INSIDE backend
                        $frontendPath = "$backendPath\$($project.frontendSubdir)"
                        
                        if (!(Test-Path $frontendPath)) {
                            Write-Host "Cloning frontend to: $frontendPath" -ForegroundColor Blue
                            # Invoke-Expression "gh repo clone $($project.frontendRepo) `"$frontendPath`""
							& gh repo clone $project.frontendRepo $frontendPath
							if ($LASTEXITCODE -ne 0) {
    							throw "Failed to clone frontend repo"
							}
                        } else {
                            Write-Host "Frontend already exists at: $frontendPath" -ForegroundColor Gray
                        }
                    }
                    else {
                        # Single repo
                        $path = "$($settingsData.devDir)\$($project.name)"
                        
                        if (!(Test-Path $path)) {
                            Write-Host "Cloning repo to: $path" -ForegroundColor Blue
                            # Invoke-Expression "gh repo clone $($project.unifiedRepo) `"$path`""
							gh repo clone $project.unifiedRepo $path
							if ($LASTEXITCODE -ne 0) {
    							throw "Failed to clone the unified repo"
							}
                        } else {
                            Write-Host "Repo already exists at: $path" -ForegroundColor Gray
                        }
                    }
                }
                
                break
            }
			default {
				foreach ($c in $step.Value.cmd) {
					Write-Host "Running $($c)" -ForegroundColor Blue
					Invoke-Expression $c
				}
			}
		}
        $step.Value.stepSuccess = $true
        Write-Host "[STEP] $($step.Name) successful" -ForegroundColor Green        
		}
		catch {
			Write-Host "$($step.Name) Failed"  -ForegroundColor Red
			Write-Error "An error occurred: $($_.Exception.Message)"
			exit 1
		}
		finally {
			$manifestData | ConvertTo-Json -Depth 10 | Set-Content manifest1.json
		}
}
