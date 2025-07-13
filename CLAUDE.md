# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Bashew is a bash script/project creator that generates robust bash scripts with built-in option parsing, color output, and comprehensive boilerplate code. It's a template system for creating professional bash scripts and projects.

## Key Commands

### Development and Testing
- `./bashew.sh script` - Create a new standalone script interactively
- `./bashew.sh project` - Create a new bash project folder with full repo structure
- `./bashew.sh init` - Initialize a cloned bashew template repo as a new project
- `./bashew.sh update` - Update bashew to latest version (git pull)

### Testing
- `tests/run_tests.sh` - Run all tests using bash_unit framework
- `bash_unit tests/test_*` - Run tests directly with bash_unit (requires installation)
- `shellcheck *.sh` - Run shellcheck for code quality analysis

### CI/CD
- GitHub Actions automatically run shellcheck and bash_unit tests on push/PR
- Workflows: `.github/workflows/bash_unit.yml` and `.github/workflows/shellcheck.yml`

## Architecture

### Core Components
- `bashew.sh` - Main script that creates new scripts/projects
- `template/script.sh` - Template for generated standalone scripts
- `template/` - Contains all template files for bashew script/project generation
- `tests/` - Unit tests using bash_unit framework

### Script Generation Process
1. `bashew.sh` uses `get_author_data()` to collect author information
2. `copy_and_replace()` processes templates with AWK to substitute variables
3. Generated scripts include full bashew library functions embedded

### Template Variables
Templates use these placeholders that get replaced during generation:
- `author_name` → Author's full name
- `author_username` → GitHub username
- `author@email.com` → Author's email
- `package_name` → Script/project name
- `package_description` → Description of the script
- `meta_today` → Creation date
- `bashew_version` → Version of bashew used

### Generated Script Structure
Generated scripts follow this pattern:
- Option parsing configuration in `Option:config()`
- Main logic in `Script:main()`
- Helper functions at the top
- Full bashew library embedded at the bottom

## Testing Requirements

Tests use bash_unit framework. Install with:
- macOS: `brew install bash_unit`
- Other: Follow instructions at https://github.com/pgrange/bash_unit

## Version Management

Version is managed through:
- `script_version` variable in `bashew.sh`
- `VERSION.md` file (takes priority if present)
- Compatible with pforret/setver for semantic versioning