# Troubleshooting Guide

Common issues and solutions for Claude Code Switcher.

## Table of Contents

- [Installation Issues](#installation-issues)
- [API Key Issues](#api-key-issues)
- [Provider-Specific Issues](#provider-specific-issues)
- [Local Provider Issues](#local-provider-issues)
- [Configuration Issues](#configuration-issues)
- [Update Issues](#update-issues)
- [Debug Mode](#debug-mode)

---

## Installation Issues

### "Command not found: claude-switch"

**Problem:** Terminal cannot find the `claude-switch` command.

**Solutions:**

1. **Check if script exists:**
```bash
ls -la ~/.local/bin/claude-switch
```

2. **Verify PATH includes ~/.local/bin:**
```bash
echo $PATH | grep ".local/bin"
```

If not found, add to PATH:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

3. **Make script executable:**
```bash
chmod +x ~/.local/bin/claude-switch
```

4. **Reinstall if needed:**
```bash
curl -fsSL https://raw.githubusercontent.com/renatoroquejani/claude-code-switcher/main/scripts/install.sh | bash
```

---

### "jq: command not found"

**Problem:** Missing `jq` dependency.

**Solution:**
```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq

# Arch Linux
sudo pacman -S jq

# Fedora
sudo dnf install jq
```

---

## API Key Issues

### "API key not configured"

**Problem:** Provider's API key is not set or not loaded.

**Solutions:**

1. **Check if API keys file exists:**
```bash
ls -la ~/.claude/api-keys.env
```

2. **Verify API key is set:**
```bash
echo $ZAI_API_KEY        # Should show your key
echo $DEEPSEEK_API_KEY   # Should show your key
```

3. **Source the API keys file:**
```bash
source ~/.claude/api-keys.env
```

4. **Add to shell config if missing:**
```bash
# Add to ~/.bashrc or ~/.zshrc
if [ -f ~/.claude/api-keys.env ]; then
  source ~/.claude/api-keys.env
fi
```

5. **Verify file permissions:**
```bash
chmod 600 ~/.claude/api-keys.env
```

---

### "Invalid API key format"

**Problem:** API key has incorrect format or contains whitespace.

**Solution:**
```bash
# Edit the API keys file
nano ~/.claude/api-keys.env

# Ensure no whitespace around keys:
export ZAI_API_KEY="your-key-here"        # Correct
export ZAI_API_KEY=" your-key-here "      # Wrong!

# Reload shell
source ~/.bashrc
```

---

## Provider-Specific Issues

### Claude (OAuth) - "Not logged in"

**Problem:** Claude Code is not authenticated with Claude Pro.

**Solution:**
```bash
# Log in to Claude Code
claude login

# Then switch
claude-switch claude
```

---

### Z.AI - "Authentication failed"

**Problem:** Invalid or expired Z.AI API key.

**Solutions:**

1. **Verify API key:**
```bash
echo $ZAI_API_KEY
```

2. **Regenerate key if needed:**
   - Visit: https://z.ai/manage-apikey/apikey-list
   - Create a new key
   - Update `~/.claude/api-keys.env`

3. **Check subscription status:**
   - Ensure your Z.AI subscription is active
   - Monthly: $3/month
   - Annual: $15/month

---

### OpenRouter - "Model not found"

**Problem:** Specified model doesn't exist or incorrect format.

**Solutions:**

1. **Use correct model format:**
```bash
# Correct
claude-switch openrouter:anthropic/claude-opus-4
claude-switch openrouter:qwen/qwen-2.5-coder-32b

# Wrong
claude-switch openrouter:opus
```

2. **List available models:**
```bash
curl https://openrouter.ai/api/v1/models
```

3. **Set default model:**
```bash
# Add to ~/.claude/api-keys.env
export OPENROUTER_DEFAULT_MODEL="anthropic/claude-opus-4.6"

# Then use without specifying model
claude-switch openrouter
```

---

### DeepSeek - "Rate limit exceeded"

**Problem:** Too many requests in short time.

**Solution:**
- Wait a few minutes before retrying
- Consider upgrading to paid tier for higher limits
- Use a different provider temporarily

---

## Local Provider Issues

### Ollama - "Model not found"

**Problem:** Specified Ollama model is not installed.

**Solutions:**

1. **List installed models:**
```bash
ollama list
```

2. **Download the model:**
```bash
ollama pull qwen3-coder:7b
ollama pull qwen3-coder:14b
ollama pull qwen3-coder:32b
```

3. **Verify Ollama is running:**
```bash
pgrep ollama

# If not running, start it:
ollama serve &
```

4. **Test Ollama directly:**
```bash
ollama run qwen3-coder:7b "Hello"
```

---

### Ollama - "Connection refused"

**Problem:** Ollama server is not running.

**Solutions:**

1. **Start Ollama server:**
```bash
ollama serve
```

2. **Check if port is in use:**
```bash
# Default port is 11434
curl http://localhost:11434/api/tags
```

3. **Verify Ollama installation:**
```bash
which ollama
ollama --version
```

---

### LM Studio - "Server not responding"

**Problem:** LM Studio local server is not running.

**Solutions:**

1. **Open LM Studio application**
2. **Load a model**
3. **Go to "Local Server" tab**
4. **Click "Start Server"**
5. **Verify server is running:**
```bash
curl http://localhost:1234/v1/models
```

6. **Check port (default is 1234):**
   - If using different port, update command:
   ```bash
   # Need to configure custom port in claude-switch
   # Currently defaults to 1234
   ```

---

### Ollama - Model mapping issues

**Problem:** Only one tier works, others fail.

**Solution:**
```bash
# Check model mapping
claude-switch models ollama

# Ensure all three tiers map to same model
# Or use specific model explicitly:
claude-switch ollama:qwen3-coder:7b
```

---

## Configuration Issues

### "Permission denied" when modifying settings.json

**Problem:** Insufficient permissions to modify Claude Code settings.

**Solutions:**

1. **Check permissions:**
```bash
ls -la ~/.claude/settings.json
```

2. **Fix permissions:**
```bash
chmod 600 ~/.claude/settings.json
```

3. **Check ownership:**
```bash
# Should be owned by your user
chown $USER:$USER ~/.claude/settings.json
```

---

### "Settings file not found"

**Problem:** Claude Code settings file doesn't exist.

**Solutions:**

1. **Run Claude Code once to create settings:**
```bash
claude
# Exit with Ctrl+D
```

2. **Verify settings location:**
```bash
ls -la ~/.claude/settings.json
```

3. **Create manually if needed:**
```bash
mkdir -p ~/.claude
cat > ~/.claude/settings.json << 'EOF'
{
  "env": {}
}
EOF
```

---

### "Backup failed"

**Problem:** Cannot create backup before switching.

**Solutions:**

1. **Check backup directory:**
```bash
ls -la ~/.claude/backups/
```

2. **Create if missing:**
```bash
mkdir -p ~/.claude/backups
chmod 700 ~/.claude/backups
```

3. **Check disk space:**
```bash
df -h ~
```

---

### Changes not applied in Claude Code

**Problem:** Switched provider but Claude Code still uses old one.

**Solutions:**

1. **Kill Claude Code sessions:**
```bash
pkill -f claude-code
```

2. **Restart Claude Code:**
```bash
claude
```

3. **Verify current config:**
```bash
claude-switch status
```

---

## Update Issues

### "Update failed"

**Problem:** Auto-update cannot download latest version.

**Solutions:**

1. **Check internet connection:**
```bash
curl -I https://github.com
```

2. **Manual update:**
```bash
# Download latest version
curl -fsSL https://raw.githubusercontent.com/renatoroquejani/claude-code-switcher/main/bin/claude-switch -o /tmp/claude-switch

# Replace current version
cp /tmp/claude-switch ~/.local/bin/claude-switch
chmod +x ~/.local/bin/claude-switch

# Verify
claude-switch --version
```

3. **Check current version:**
```bash
claude-switch --version
claude-switch check-update
```

---

### "Version check failed"

**Problem:** Cannot check for updates.

**Solutions:**

1. **Check GitHub connectivity:**
```bash
curl https://api.github.com/repos/renatoroquejani/claude-code-switcher/releases/latest
```

2. **Verify version in script:**
```bash
grep "VERSION=" ~/.local/bin/claude-switch
```

---

## Debug Mode

Enable debug mode for detailed error information:

```bash
# Run with debug output
bash -x ~/.local/bin/claude-switch <provider>

# Or modify script temporarily
nano ~/.local/bin/claude-switch
# Add at beginning: set -x
```

### Collect Debug Information

```bash
# System info
uname -a

# Shell info
echo $SHELL
bash --version
zsh --version

# Claude Code info
claude --version

# Switcher version
claude-switch --version

# Current config
claude-switch status

# Settings file
cat ~/.claude/settings.json | jq '.'

# API keys (sanitized)
env | grep _API_KEY | sed 's/=.*/=***HIDDEN***/'
```

---

## Still Having Issues?

1. **Check the [Documentation](SETUP.md)**
2. **Search existing [GitHub Issues](https://github.com/renatoroquejani/claude-code-switcher/issues)**
3. **Open a new issue** with the following information:

   ```markdown
   **Environment:**
   - OS: [e.g., Ubuntu 22.04, macOS 14, Arch Linux]
   - Shell: [e.g., bash 5.1, zsh 5.8]
   - Claude Code Switcher: [version from `claude-switch --version`]
   - Claude Code: [version from `claude --version`]

   **Problem:**
   [Describe the issue]

   **Steps to Reproduce:**
   1. [Step 1]
   2. [Step 2]
   3. [Step 3]

   **Error Message:**
   ```
   [Paste full error message here]
   ```

   **Current Status:**
   ```
   [Output of `claude-switch status`]
   ```

   **What I've Tried:**
   - [Thing you tried]
   - [Another thing you tried]
   ```

4. **Join the community** for real-time help:
   - GitHub Discussions: https://github.com/renatoroquejani/claude-code-switcher/discussions
