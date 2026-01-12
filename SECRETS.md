# Secrets Management

This dotfiles repository is public and contains **NO secrets**. All sensitive data is managed separately.

## How Secrets Work

### ZSH Secrets (`~/.zsh/secrets/`)

The `.zshrc` sources all files in `~/.zsh/secrets/`. This directory is created by chezmoi but its contents are NOT committed.

**To add a secret:**

```bash
# Create a secret file (any name works, .secret extension is convention)
echo 'export MY_API_KEY="your-secret-value"' > ~/.zsh/secrets/api_keys.secret
echo 'export GITHUB_TOKEN="ghp_xxxx"' >> ~/.zsh/secrets/api_keys.secret
```

**Common secrets you might store:**

- API keys
- Tokens (GitHub, GitLab, etc.)
- Private environment variables
- Machine-specific configuration

### Git Configuration

Git signing keys and emails are stored in chezmoi's config (`~/.config/chezmoi/chezmoi.toml`), which is local to each machine and not committed.

When you run `chezmoi init` on a new machine, you'll be prompted for:
- Machine type (desktop/laptop/macmini)
- Personal email and GPG signing key
- Work email and GPG signing key (optional)

### Alternative: Age Encryption (Advanced)

For secrets that MUST be synced across machines, chezmoi supports [age](https://github.com/FiloSottile/age) encryption.

**Setup age encryption:**

1. Install age:
   ```bash
   # Arch Linux
   sudo pacman -S age
   
   # macOS
   brew install age
   ```

2. Generate a key:
   ```bash
   age-keygen -o ~/.config/chezmoi/key.txt
   chmod 600 ~/.config/chezmoi/key.txt
   ```

3. Add the recipient to chezmoi config:
   ```toml
   # ~/.config/chezmoi/chezmoi.toml
   [age]
     identity = "~/.config/chezmoi/key.txt"
     recipient = "age1..." # your public key from key.txt
   ```

4. Add encrypted files:
   ```bash
   chezmoi add --encrypt ~/.ssh/config
   ```

**Note:** The age key file must be transferred securely to each machine (USB drive, secure channel, etc.).

## Security Best Practices

1. **Never commit secrets** - Always use `.gitignore` and verify with `git status`
2. **Use unique secrets per machine** when possible
3. **Rotate secrets regularly**
4. **Use a password manager** for storing master keys
5. **Review `chezmoi diff`** before committing any changes
