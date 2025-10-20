# Windows Developer Onboarding Script

**Created by:** Carlo Quick  
**Purpose:** Automated Windows development environment setup for teams

## Project Purpose

This PowerShell automation script is designed to streamline the onboarding process for new developers by eliminating the tedious manual setup of development tools and repositories. Whether you're onboarding a single developer or an entire team, this script handles the installation and configuration of essential development tools, authentication setup, and repository cloning—all with minimal user interaction.

The script is fully customizable via `settings.json` and `manifest.json`, allowing you to adapt it to your organization's specific tech stack, repository structure, and workflow requirements. It supports both single-repository and multi-repository project structures, making it flexible for various development environments.

Ideal for:

- Companies onboarding new developers
- Development teams standardizing local environments
- Solo developers setting up new machines
- Anyone who values automation over repetitive manual setup

## What This Script Does

This PowerShell script automates the setup of a complete Windows development environment, including:

- **WSL2** (Windows Subsystem for Linux) with Ubuntu
- **Git** with user configuration
- **Docker Desktop** with WSL2 backend
- **Visual Studio Code** with development extensions
- **GitHub CLI** with authentication
- **Project repositories** (supports single-repo and multi-repo setups)

## Prerequisites

- Windows 10 (version 2004+) or Windows 11
- Administrator access
- Active internet connection
- GitHub account with repository access

> **Note:** It's somewhat ironic that you may need GitHub access to download this script, but you have two options:
>
> 1. Download as ZIP from GitHub (no authentication required)
> 2. Have someone transfer the folder to your new machine via USB/network share

## Files Overview

- `onboarding.ps1` - Main automation script
- `manifest.json` - Tracks installation progress (managed by script, safe to commit)
- `settings.example.json` - Template configuration file (commit this)
- `settings.json` - Your personal configuration (create from example, do not commit)
- `README.md` - This documentation

## Setup Instructions

### 1. Configure Your Settings

**First, create your personal settings file:**

1. Copy `settings.example.json` to `settings.json`:
   ```powershell
   Copy-Item settings.example.json settings.json
   ```
2. Edit `settings.json` with your personal information and project details:

```json
{
  "distro": "Ubuntu-24.04",
  "devDir": "C:\\dev",
  "gitCreds": {
    "name": "Jane Doe",
    "email": "jane.doe@company.com"
  },
  "vsCodeExtensions": [
    "eamodio.gitlens",
    "esbenp.prettier-vscode",
    "ms-vscode-remote.remote-ssh",
    "bmewburn.vscode-intelephense-client"
  ],
  "projects": [
    {
      "name": "my-project",
      "multiRepo": true,
      "backendRepo": "https://github.com/your-org/backend-repo.git",
      "backendName": "backend-folder-name",
      "frontendRepo": "https://github.com/your-org/frontend-repo.git",
      "frontendSubdir": "src",
      "unifiedRepo": ""
    },
    {
      "name": "another-project",
      "multiRepo": false,
      "backendRepo": "",
      "backendName": "",
      "frontendRepo": "",
      "frontendSubdir": "",
      "unifiedRepo": "https://github.com/your-org/single-repo.git"
    }
  ]
}
```

> **Important:** `settings.json` is gitignored and should contain your real credentials. Never commit this file to version control. Always commit changes to `settings.example.json` instead when updating the template.

**Configuration Details:**

- `distro`: WSL2 Linux distribution to install (default: Ubuntu-24.04)
- `devDir`: Root directory where projects will be cloned
- `gitCreds.name`: Your full name for Git commits
- `gitCreds.email`: Your email for Git commits
- `vsCodeExtensions`: Array of extension IDs to install
  - Find extension IDs in the **VSCode Extensions Marketplace** (accessible in VSCode: Ctrl+Shift+X)
  - Click on any extension → Look for the ID under the extension name
  - Feel free to **add or remove extensions** based on your needs
- `projects`: Array of projects to clone
  - **Single-repo setup:** Set `multiRepo: false`, populate `unifiedRepo`
  - **Multi-repo setup:** Set `multiRepo: true`, populate backend/frontend repos and directory structure

**Project Structure Examples:**

**Single Repository:**

```
C:\dev\
└── my-single-project\
    ├── src\
    ├── tests\
    └── ...
```

**Multi-Repository (Nested):**

```
C:\dev\
└── backend-folder-name\
    ├── docker-compose.yml
    ├── infra\
    └── src\                  ← Frontend repo cloned here
        ├── app\
        ├── resources\
        └── ...
```

Ensure your `settings.json` reflects how your projects are organized in your version control system.

### 2. Run the Script

1. **Right-click PowerShell** → Select **"Run as Administrator"**
2. Navigate to the script directory:
   ```powershell
   cd C:\path\to\onboarding
   ```
3. Run the script:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\onboarding.ps1
   ```

### 3. Follow Prompts

The script will:

- Install components automatically
- Prompt for reboot after WSL2 installation
- Ask you to authenticate with GitHub (browser will open)
- Request manual Docker Desktop configuration

### 4. After Reboot

Simply rerun the same command:

```powershell
powershell -ExecutionPolicy Bypass -File .\onboarding.ps1
```

The script will resume from where it left off.

### 5. Post-Installation VSCode Configuration

After the script completes, open VSCode and configure:

1. Open Settings (Ctrl+,)
2. Search for "format on save"
3. Enable **"Editor: Format On Save"**
4. Search for "default formatter"
5. Set **"Editor: Default Formatter"** to **"Prettier - Code formatter"**

These settings ensure consistent code formatting across your team.

## Manual Steps Required

### WSL2 Installation

- Script will prompt you to **restart your computer**
- After restart, rerun the script

### GitHub Authentication

- Browser window will open during GitHub CLI setup
- Copy the one-time code displayed
- Paste it in the browser and authorize

### Docker Desktop

- After installation, you'll need to:
  1. Open Docker Desktop from Start Menu
  2. Accept the service agreement
  3. Wait for Docker to start (whale icon appears in system tray)
  4. Verify WSL2 backend is enabled (Settings → General)
- Press Enter in the script when complete

## Installed VSCode Extensions

The script installs the following extensions by default (customize in `settings.json`):

- **GitLens** - Supercharged Git capabilities
- **Prettier** - Code formatter
- **Remote - SSH** - SSH remote development
- **PHP Intelephense** - PHP language support

**To add more extensions:**

1. Open VSCode
2. Go to Extensions (Ctrl+Shift+X)
3. Find the extension you want
4. Copy its ID (shown under the extension name)
5. Add it to the `vsCodeExtensions` array in `settings.json`

**To remove extensions:**
Simply delete them from the `vsCodeExtensions` array before running the script.

## Project Structure

After completion, your projects will be located at:

```
C:\dev\
├── Docker-order-shunostyle\    (Backend repo)
│   ├── docker-compose.yml
│   ├── infra\
│   └── src\                     (Frontend repo, nested)
│       ├── app\
│       ├── resources\
│       └── ...
└── [other projects]
```

## Starting Your Development Environment

```powershell
# Navigate to project
cd C:\dev\Docker-order-shunostyle

# Start Docker containers
docker compose up -d

# Navigate to frontend code
cd src

# Install dependencies (first time only)
docker compose exec app composer install

# Open in VSCode
code .
```

## Troubleshooting

### Script Fails or Stops

The script is **idempotent** - you can safely rerun it. It will:

- Skip already-completed steps
- Resume from the last failure point

### Git Not Recognized After Installation

Close and reopen PowerShell. The script attempts to refresh PATH automatically, but a new terminal session ensures it's loaded.

### Docker Desktop Won't Start

1. Ensure WSL2 is properly installed: `wsl --list --verbose`
2. Check Windows Features: "Virtual Machine Platform" must be enabled
3. Restart Docker Desktop from the system tray

### GitHub Authentication Fails

Run manually:

```powershell
gh auth login
```

Follow the prompts to authenticate.

### Nested Virtualization Issues (VM Only)

If running in a VM (VirtualBox, UTM, etc.), WSL2/Docker may not work due to nested virtualization limitations. Test on physical hardware.

### Permission Errors

Ensure you're running PowerShell as Administrator:

1. Right-click PowerShell
2. Select "Run as Administrator"

## Learning Git & GitHub

New to Git or GitHub? Here are some resources to get started:

- [GitHub's Official Git Guide](https://docs.github.com/en/get-started/using-git/about-git)
- [Understanding Branches](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-branches)
- [Creating Pull Requests](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request)
- [GitHub Flow Workflow](https://docs.github.com/en/get-started/quickstart/github-flow)

These resources will help you understand version control fundamentals, branching strategies, and collaborative development workflows.

## Post-Installation

### Verify Installations

```powershell
# Check WSL
wsl --list --verbose

# Check Git
git --version

# Check Docker
docker --version

# Check VSCode
code --version

# Check GitHub CLI
gh --version
```

### Configure Additional Git Settings (Optional)

```powershell
# Set default branch name
git config --global init.defaultBranch main

# Set up SSH keys for GitHub (if preferred over HTTPS)
ssh-keygen -t ed25519 -C "your.email@watahan.com"
```

## Support

If you encounter issues not covered in this README:

1. Check the error message in the PowerShell output
2. Verify you're running as Administrator
3. Ensure internet connection is stable
4. Contact your team lead for assistance

## Script Maintenance & Customization

### Adding New Steps

**For simple commands (no winget install):**

Add to `manifest.json`:

```json
{
  "newStep": {
    "cmd": ["command to run", "another command"],
    "stepSuccess": false
  }
}
```

Example:

```json
{
  "node": {
    "cmd": ["node --version", "npm --version"],
    "stepSuccess": false
  }
}
```

The script will automatically pick up and run these commands.

**For winget installations requiring PATH refresh:**

You'll need to add a case to the switch statement in `onboarding.ps1`:

```powershell
"newApp" {
    if($step.Value.wingetSuccess -eq $false){
        Write-Host "Running $($step.Value.wingetCmd)" -ForegroundColor Blue
        Invoke-Expression $step.Value.wingetCmd
        $step.Value.wingetSuccess = $true
        RefreshPath
    }
    # Additional setup commands here
    break
}
```

Then add to `manifest.json`:

```json
{
  "newApp": {
    "wingetCmd": "winget install --id SomeApp.Name",
    "wingetSuccess": false,
    "stepSuccess": false
  }
}
```

### Adding New Projects

To add new projects to clone, edit `settings.json`:

```json
"projects": [
  {
    "name": "new-project",
    "multiRepo": false,
    "unifiedRepo": "https://github.com/org/repo.git"
  }
]
```

The script supports:

- **Single-repository projects** (`multiRepo: false`)
- **Multi-repository projects** (`multiRepo: true`) with nested directory structures

Ensure your `projects` array accurately reflects your organization's repository structure.

---

**Project Repository:** [GitHub - Carlo Quick](https://github.com/CarloQuick)  
**Maintained by:** Carlo Quick  
**Last Updated:** October 2025  
**License:** MIT (or specify your license)

**Contributions & Issues:** Feel free to open issues or submit pull requests for improvements!
