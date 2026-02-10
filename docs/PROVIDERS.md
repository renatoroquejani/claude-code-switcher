# Supported Providers

Comprehensive guide to all LLM providers supported by Claude Code Switcher.

## Cloud Providers

### Anthropic Claude (Official/OAuth)

Official Claude via Anthropic Pro subscription.

| Property | Value |
|----------|-------|
| **Command** | `claude-switch claude` |
| **Alias** | `claude`, `opus` (legacy) |
| **Cost** | $20/month (flat fee) |
| **API Key** | Not required (uses OAuth) |
| **Model Mapping** | Opus→claude-opus-4-6, Sonnet→claude-sonnet-4-5-20250929, Haiku→claude-haiku-4-20250920 |
| **Speed** | Fast |
| **Privacy** | Standard cloud |

**Setup:**
```bash
# Requires active Claude Pro subscription
claude-switch claude
```

**Notes:**
- Highest quality responses
- Best for complex reasoning tasks
- No API key needed - uses your existing Claude account
- Flat monthly fee for unlimited usage

---

### Anthropic Claude (API Key)

Use Anthropic Claude with an API key instead of OAuth.

| Property | Value |
|----------|-------|
| **Command** | `claude-switch anthropic-api` |
| **Alias** | `anthropic-api` |
| **Cost** | Per-use pricing |
| **API Key** | Required |
| **Sign Up** | https://console.anthropic.com/settings/keys |
| **Model Mapping** | Opus→claude-opus-4-6, Sonnet→claude-sonnet-4-5-20250929, Haiku→claude-haiku-4-20250920 |
| **Speed** | Fast |
| **Privacy** | Standard cloud |

**Setup:**
```bash
# 1. Get API key from: https://console.anthropic.com/settings/keys
# 2. Add to ~/.claude/api-keys.env:
export ANTHROPIC_API_KEY="your-key-here"

# 3. Use it
claude-switch anthropic-api
```

**Pricing:**
- Opus: $15/1M input, $75/1M output
- Sonnet: $3/1M input, $15/1M output
- Haiku: $0.25/1M input, $1.25/1M output

**Notes:**
- Good for pay-as-you-go usage
- Same quality as OAuth
- Requires API key management
- Useful for team accounts or enterprise

---

### Z.AI (GLM Models)

Chinese AI provider with competitive pricing.

| Property | Value |
|----------|-------|
| **Command** | `claude-switch zai` or `claude-switch z.ai` |
| **Alias** | `zai`, `z.ai`, `glm` (legacy) |
| **Cost** | $15/month (annual ~$180/year) |
| **Sign Up** | https://z.ai/manage-apikey/apikey-list |
| **Model Mapping** | Opus→glm-4.7, Sonnet→glm-4.6, Haiku→glm-4.5-flash |
| **Speed** | Fast |
| **Privacy** | Standard cloud |

**Setup:**
```bash
# 1. Get API key from: https://z.ai/manage-apikey/apikey-list
# 2. Add to ~/.claude/api-keys.env:
export ZAI_API_KEY="your-key-here"

# 3. Use it
claude-switch zai
```

**Pricing:**
- Monthly: $3/month
- Annual: $15/month (~$180/year)

---

### DeepSeek

Chinese AI lab with very low pricing.

| Property | Value |
|----------|-------|
| **Command** | `claude-switch deepseek` |
| **Alias** | `deepseek` |
| **Cost** | $0.14/1M input, $0.28/1M output |
| **Sign Up** | https://platform.deepseek.com/api_keys |
| **Model Mapping** | All tiers → deepseek-chat |
| **Speed** | Fast |
| **Privacy** | Standard cloud |

**Setup:**
```bash
# 1. Get API key from: https://platform.deepseek.com/api_keys
# 2. Add to ~/.claude/api-keys.env:
export DEEPSEEK_API_KEY="your-key-here"

# 3. Use it
claude-switch deepseek
```

---

### Kimi (Moonshot AI)

Another Chinese AI provider.

| Property | Value |
|----------|-------|
| **Command** | `claude-switch kimi` |
| **Alias** | `kimi` |
| **Cost** | Variable |
| **Sign Up** | https://platform.moonshot.cn/console/api-keys |
| **Model Mapping** | Opus→128k, Sonnet→32k, Haiku→8k (context size) |
| **Speed** | Medium |
| **Privacy** | Standard cloud |

**Setup:**
```bash
# 1. Get API key from: https://platform.moonshot.cn/console/api-keys
# 2. Add to ~/.claude/api-keys.env:
export KIMI_API_KEY="your-key-here"

# 3. Use it
claude-switch kimi
```

---

### Qwen (SiliconFlow)

Alibaba's Qwen models via SiliconFlow.

| Property | Value |
|----------|-------|
| **Command** | `claude-switch qwen` |
| **Alias** | `qwen` |
| **Cost** | $0.42/1M tokens |
| **Sign Up** | https://siliconflow.cn/account/ak |
| **Model Mapping** | Opus→32B, Sonnet→14B, Haiku→7B (Qwen2.5-Coder) |
| **Speed** | Medium |
| **Privacy** | Standard cloud |

**Setup:**
```bash
# 1. Get API key from: https://siliconflow.cn/account/ak
# 2. Add to ~/.claude/api-keys.env:
export SILICONFLOW_API_KEY="your-key-here"

# 3. Use it
claude-switch qwen
```

---

### Groq

Fast inference provider with generous free tier.

| Property | Value |
|----------|-------|
| **Command** | `claude-switch groq` |
| **Alias** | `groq` |
| **Cost** | Free tier available |
| **Sign Up** | https://console.groq.com/keys |
| **Model Mapping** | Opus→llama-3.3-70b-versatile, Sonnet→llama-3.3-70b-versatile, Haiku→mixtral-8x7b-32768 |
| **Speed** | Very Fast |
| **Privacy** | Standard cloud |

**Setup:**
```bash
# 1. Get API key from: https://console.groq.com/keys
# 2. Add to ~/.claude/api-keys.env:
export GROQ_API_KEY="your-key-here"

# 3. Use it
claude-switch groq
```

**Notes:**
- Extremely fast inference (purpose-built infrastructure)
- Generous free tier for development

---

### Together AI

Platform for accessing 100+ open-source models.

| Property | Value |
|----------|-------|
| **Command** | `claude-switch together:model` |
| **Alias** | `together model` |
| **Cost** | Per-use (competitive pricing) |
| **Sign Up** | https://api.together.xyz/settings/api-keys |
| **Model Mapping** | User specified (same for all tiers) |
| **Speed** | Fast |
| **Privacy** | Standard cloud |

**Setup:**
```bash
# 1. Get API key from: https://api.together.xyz/settings/api-keys
# 2. Add to ~/.claude/api-keys.env:
export TOGETHER_API_KEY="your-key-here"

# Optional: Set default model
export TOGETHER_DEFAULT_MODEL="meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo"

# 3. Use with specific model
claude-switch together:meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo

# Or use default (if configured)
claude-switch together
```

**Popular Models:**
```
meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo
mistralai/Mixtral-8x7B-Instruct-v0.1
Qwen/Qwen2.5-72B-Instruct
```

---

### OpenRouter

API aggregator providing access to 100+ models.

| Property | Value |
|----------|-------|
| **Command** | `claude-switch openrouter:model` |
| **Alias** | `openrouter model` |
| **Cost** | Varies by model |
| **Sign Up** | https://openrouter.ai/keys |
| **Model Mapping** | User specified (same for all tiers) |
| **Speed** | Varies |
| **Privacy** | Standard cloud |

**Setup:**
```bash
# 1. Get API key from: https://openrouter.ai/keys
# 2. Add to ~/.claude/api-keys.env:
export OPENROUTER_API_KEY="your-key-here"

# Optional: Set default model
export OPENROUTER_DEFAULT_MODEL="anthropic/claude-opus-4.6"

# 3. Use with specific model
claude-switch openrouter:anthropic/claude-opus-4
```

---

## Local Providers

### Ollama

Run models locally on your machine.

| Property | Value |
|----------|-------|
| **Command** | `claude-switch ollama:model` |
| **Alias** | `ollama-claude` |
| **Cost** | Free |
| **Download** | https://ollama.com |
| **Model Mapping** | All tiers → User-specified local model |
| **Speed** | Depends on hardware |
| **Privacy** | Full privacy (local) |

**Setup:**
```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Start server
ollama serve

# Download models
ollama pull qwen3-coder:7b

# Use with Claude Code
claude-switch ollama:qwen3-coder:7b
```

**Recommended Models:**
- `qwen3-coder:7b` - Fast coding model (~4GB RAM)
- `qwen3-coder:14b` - Balanced coding model (~8GB RAM)
- `qwen3-coder:32b` - Capable coder (~16GB RAM)

---

### LM Studio

GUI application for running local models.

| Property | Value |
|----------|-------|
| **Command** | `claude-switch lmstudio` |
| **Alias** | `lmstudio-claude` |
| **Cost** | Free |
| **Download** | https://lmstudio.ai |
| **Models** | Any GGUF model |
| **Speed** | Depends on hardware |
| **Privacy** | Full privacy (local) |

**Setup:**
```bash
# Download and install LM Studio from https://lmstudio.ai/
# Load a model and start the local server
# Then use:
claude-switch lmstudio
```

---

## Comparison

### Model Mapping Quick Reference

| Provider | Opus Tier | Sonnet Tier | Haiku Tier | Strategy |
|----------|-----------|-------------|------------|----------|
| **Claude (OAuth)** | claude-opus-4-6 | claude-sonnet-4-5-20250929 | claude-haiku-4-20250920 | Official models |
| **Claude (API)** | claude-opus-4-6 | claude-sonnet-4-5-20250929 | claude-haiku-4-20250920 | Official models |
| **Z.AI** | glm-4.7 | glm-4.6 | glm-4.5-flash | Size-based |
| **DeepSeek** | deepseek-chat | deepseek-chat | deepseek-chat | Single model |
| **Kimi** | moonshot-v1-128k | moonshot-v1-32k | moonshot-v1-8k | Context size |
| **Qwen** | Qwen2.5-Coder-32B | Qwen2.5-Coder-14B | Qwen2.5-Coder-7B | Parameter count |
| **Groq** | llama-3.3-70b-versatile | llama-3.3-70b-versatile | mixtral-8x7b-32768 | Speed-based |
| **Together AI** | (user spec) | (same as Opus) | (same as Opus) | User choice |
| **OpenRouter** | (user spec) | (same as Opus) | (same as Opus) | User choice |
| **Ollama** | (local model) | (same as Opus) | (same as Opus) | Local choice |
| **LM Studio** | (loaded model) | (loaded model) | (loaded model) | App choice |

### Cost Comparison

| Provider | Cost Model | Est. Monthly | Best For |
|----------|------------|--------------|----------|
| Claude (Pro) | $20/month flat | $20 | Heavy users |
| Claude (API) | Per-use | $5-100 | Variable usage |
| GLM | $15/month flat | $15 | Regular use |
| DeepSeek | $0.14/1M tokens | $1-10 | Light use |
| Qwen | $0.42/1M tokens | $3-30 | Medium use |
| Groq | Free tier available | $0-20 | Speed/development |
| Together AI | Per-use | $5-50 | Open-source models |
| OpenRouter | Varies | $5-50 | Testing/flexibility |
| Ollama | Free | $0 | Privacy/cost |
| LM Studio | Free | $0 | Privacy/ease |

### Feature Matrix

| Feature | Claude (Pro) | Claude (API) | GLM | DeepSeek | Qwen | Groq | Together AI | OpenRouter | Ollama | LM Studio |
|---------|-------------|--------------|-----|----------|------|------|-------------|------------|--------|-----------|
| Works Offline | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| No API Key | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| Flat Pricing | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| Multiple Models | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ |
| Best Quality | ✅ | ✅ | 🟡 | 🟡 | 🟡 | 🟡 | 🟡 | 🟡 | 🟡 | 🟡 |
| Pay-as-you-go | ❌ | ✅ | ❌ | ✅ | ✅ | 🟡 | ✅ | ✅ | ❌ | ❌ |
| Ultra Fast | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | 🟡 | ❌ | ❌ |

---

## Quick Start Guide

**For maximum quality:**
```bash
claude-switch claude
```

**For best value (cloud):**
```bash
claude-switch zai
```

**For minimal cost:**
```bash
claude-switch deepseek
```

**For ultra-fast inference:**
```bash
claude-switch groq
```

**For open-source models:**
```bash
claude-switch together:meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo
```

**For privacy:**
```bash
ollama pull qwen3-coder:7b
claude-switch ollama:qwen3-coder:7b
```

---

## Getting API Keys

For quick links to get API keys, run:

```bash
claude-switch keys
```
