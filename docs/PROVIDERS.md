## Cloud Providers

### Anthropic Claude (Official)

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
# or: claude-switch z.ai
```

**Pricing:**
- Monthly: $3/month
- Annual: $15/month (~$180/year)
- Good value for frequent use

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

**Model Mapping:**
- **All tiers** → `deepseek-chat` (same model for Opus, Sonnet, Haiku)

**Notes:**
- Extremely cost-effective for occasional use
- Good coding capabilities
- Fast response times

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

**Model Mapping:**
- **Opus tier** → `moonshot-v1-128k` (largest context)
- **Sonnet tier** → `moonshot-v1-32k` (medium context)
- **Haiku tier** → `moonshot-v1-8k` (smallest context, fastest)

**Notes:**
- May require Chinese phone number for signup
- Good Chinese language support

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

**Model Mapping:**
- **Opus tier** → `Qwen/Qwen2.5-Coder-32B-Instruct` (most capable)
- **Sonnet tier** → `Qwen/Qwen2.5-Coder-14B-Instruct` (balanced)
- **Haiku tier** → `Qwen/Qwen2.5-Coder-7B-Instruct` (fast)

**Notes:**
- Strong coding model (Qwen2.5-Coder)
- Competitive pricing
- Good alternative to Western providers

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

# Or use default (if configured)
claude-switch openrouter
```

**Model Mapping:**
- All tiers (Opus, Sonnet, Haiku) → User-specified model
- Example: `openrouter:qwen/qwen-2.5-coder-32b` sets all tiers to that model

**Popular Models:**
```
anthropic/claude-opus-4
qwen/qwen-2.5-coder-32b
deepseek/deepseek-coder
google/gemini-pro-1.5
meta-llama/llama-3.1-70b
```

**Notes:**
- Most flexibility - access to many models
- Pricing varies per model (check OpenRouter site)
- Good for testing different models

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

1. Install Ollama:
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

2. Start server:
```bash
ollama serve
```

3. Download models:
```bash
ollama pull qwen2.5-coder:7b
ollama pull deepseek-coder-v2:16b
ollama pull llama3.2
```

4. Use with Claude Code:
```bash
# With specific model
claude-switch ollama:qwen2.5-coder:7b

# Or use first available model
claude-switch ollama
```

**Model Mapping:**
- All tiers (Opus, Sonnet, Haiku) → Same local model
- Example: `ollama:qwen2.5-coder:7b` sets all tiers to that local model

**Recommended Models:**
- `qwen2.5-coder:7b` - Fast coding model (~4GB RAM)
- `qwen2.5-coder:14b` - Balanced coding model (~8GB RAM)
- `deepseek-coder-v2:16b` - Strong coder (~10GB RAM)
- `llama3.2` - General purpose (~4GB RAM for 3B)

**Notes:**
- Complete privacy - no data leaves your machine
- Requires adequate RAM (check model size)
- Speed depends on your CPU/GPU

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
| **Port** | 1234 (default) |

**Setup:**

1. Download and install LM Studio from https://lmstudio.ai/

2. Open LM Studio and:
   - Search for a model (e.g., "Qwen 2.5 Coder")
   - Download the model
   - Click "Load Model"

3. Start the local server:
   - Go to "Local Server" tab
   - Click "Start Server"
   - Note the port (default: 1234)

4. Use with Claude Code:
```bash
claude-switch lmstudio
```

**Notes:**
- User-friendly GUI
- Good for beginners
- Can download models from within the app
- Server must be running before switching

---

## Comparison

### Model Mapping Quick Reference

| Provider | Opus Tier | Sonnet Tier | Haiku Tier | Strategy |
|----------|-----------|-------------|------------|----------|
| **Claude** | claude-opus-4-6 | claude-sonnet-4-5-20250929 | claude-haiku-4-20250920 | Official models |
| **Z.AI** | glm-4.7 | glm-4.6 | glm-4.5-flash | Size-based |
| **DeepSeek** | deepseek-chat | deepseek-chat | deepseek-chat | Single model |
| **Kimi** | moonshot-v1-128k | moonshot-v1-32k | moonshot-v1-8k | Context size |
| **Qwen** | Qwen2.5-Coder-32B | Qwen2.5-Coder-14B | Qwen2.5-Coder-7B | Parameter count |
| **OpenRouter** | (user spec) | (same as Opus) | (same as Opus) | User choice |
| **Ollama** | (local model) | (same as Opus) | (same as Opus) | Local choice |
| **LM Studio** | (loaded model) | (loaded model) | (loaded model) | App choice |

**Check mapping for any provider:**
```bash
claude-switch models zai
claude-switch models qwen
```

### Cost Comparison

| Provider | Cost Model | Est. Monthly | Best For |
|----------|------------|--------------|----------|
| Opus (Pro) | $20/month flat | $20 | Heavy users |
| GLM | $15/month flat | $15 | Regular use |
| DeepSeek | $0.14/1M tokens | $1-10 | Light use |
| Qwen | $0.42/1M tokens | $3-30 | Medium use |
| OpenRouter | Varies | $5-50 | Testing/flexibility |
| Ollama | Free | $0 | Privacy/cost |
| LM Studio | Free | $0 | Privacy/ease |

### Speed Comparison

| Provider | Speed | Notes |
|----------|-------|-------|
| Opus (Pro) | ⚡⚡⚡ Fastest | Official servers |
| GLM | ⚡⚡⚡ Fast | Good infrastructure |
| DeepSeek | ⚡⚡⚡ Fast | Good infrastructure |
| Qwen | ⚡⚡ Medium | Slightly slower |
| OpenRouter | ⚡ Varies | Depends on model |
| Ollama | ⚡⚡ Medium* | CPU-bound |
| LM Studio | ⚡⚡ Medium* | CPU-bound |

*Faster with GPU acceleration

### Privacy Comparison

| Provider | Privacy | Data Stored |
|----------|---------|-------------|
| Opus (Pro) | 🔒 Standard | Anthropic servers |
| All Cloud | 🔒 Standard | Provider servers |
| Ollama | 🔒🔒🔒 Full | None (local) |
| LM Studio | 🔒🔒🔒 Full | None (local) |

### Feature Matrix

| Feature | Opus | GLM | DeepSeek | Qwen | OpenRouter | Ollama | LM Studio |
|---------|------|-----|----------|------|------------|--------|-----------|
| Works Offline | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| No API Key | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| Flat Pricing | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ |
| Multiple Models | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ |
| Best Quality | ✅ | 🟡 | 🟡 | 🟡 | 🟡 | 🟡 | 🟡 |

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

**For privacy:**
```bash
# Install Ollama first
ollama pull qwen2.5-coder:7b
claude-switch ollama:qwen2.5-coder:7b
```

**For flexibility:**
```bash
claude-switch openrouter:qwen/qwen-2.5-coder-32b
```

---

## Getting API Keys

For quick links to get API keys, run:

```bash
claude-switch keys
```

This will display direct links to each provider's API key page.
