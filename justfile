# Default recipe to run when just is called without arguments
default:
    @just --list

# Clean cache files and directories from terragrunt/terraform
clean:
    find . -type d \( -name '.terragrunt-cache' -o -name '.terraform' \) -print -prune -exec rm -rf {} \;
    find . -type f -name '.terraform.lock.hcl' -print -prune -exec rm -f {} \;

# Run pre-commit to lint and fix files, se .pre-commit-config.yaml
lint:
    pre-commit run --all-files --verbose --show-diff-on-failure --color always
