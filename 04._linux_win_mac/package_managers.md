# Package Managers

## Overview
Package managers are tools that automate the process of installing, upgrading, configuring, and removing software packages. They handle dependencies and ensure that software is installed correctly.

### `apt` (Advanced Package Tool)
**Description:**
apt is a command-line tool for handling packages on Debian-based Linux distributions such as Ubuntu. It simplifies the process of managing software by automatically resolving and installing dependencies.

**Basic Commands:**
- Update the package list:
  ```bash
  sudo apt update
  ```
- Upgrade installed packages:
  ```bash
  sudo apt upgrade
  ```
- Install a package:
  ```bash
  sudo apt install <package_name>
  ```
- Remove a package:
  ```bash
  sudo apt remove <package_name>
  ```
- Search for a package:
  ```bash
  apt search <package_name>
  ```

### `brew` - Mac OS
**Description:**
Homebrew (brew) is a package manager for macOS and Linux. It simplifies the installation of software on Apple's operating system and provides a simple way to install and manage software packages.

**Basic Commands:**
- Install Homebrew:
  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```
- Update Homebrew:
  ```bash
  brew update
  ```
- Install a package:
  ```bash
  brew install <package_name>
  ```
- Uninstall a package:
  ```bash
  brew uninstall <package_name>
  ```
- Search for a package:
  ```bash
  brew search <package_name>
  ```

### Chocolatey - Windows
**Description:**
Chocolatey is a package manager for Windows. It allows users to install, upgrade, and manage software packages from the command line, similar to apt on Linux or brew on macOS.

**Basic Commands:**
- Install Chocolatey (use Powershell for this part):
  ```powershell
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
  ```
- Install a package:
  ```powershell
  choco install <package_name>
  ```
- Uninstall a package:
  ```powershell
  choco uninstall <package_name>
  ```
- Search for a package:
  ```powershell
  choco search <package_name>
  ```
- Update a package:
  ```powershell
  choco upgrade <package_name>
  ```
