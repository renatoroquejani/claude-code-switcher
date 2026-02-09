# 🚀 Claude Code Switcher - Guia de Inicialização do Projeto

## 📌 Visão Geral

Este guia contém o passo-a-passo completo para iniciar o projeto **claude-code-switcher** de forma profissional e estruturada para desenvolvimento colaborativo.

---

## 🎯 Objetivo do Projeto

Ferramenta CLI para alternar facilmente entre diferentes providers de LLM no Claude Code, incluindo:
- **Cloud:** Anthropic (Opus), Z.AI (GLM), DeepSeek, Kimi, SiliconFlow (Qwen), OpenRouter
- **Local:** Ollama, LM Studio

---

## 📋 FASE 1: Setup Inicial do Repositório

### 1.1 Criar Repositório no GitHub

```bash
# Criar diretório do projeto
mkdir -p ~/projects/claude-code-switcher
cd ~/projects/claude-code-switcher

# Inicializar git
git init
git branch -M main

# Criar .gitignore
cat > .gitignore << 'EOF'
# API Keys e configurações sensíveis
*.env
api-keys.env
.credentials.json

# Backups
*.backup
*.bak
backups/

# OS
.DS_Store
Thumbs.db

# Temporários
*.tmp
*.log

# Editor
.vscode/
.idea/
*.swp
*.swo

# Testes
test-output/
EOF
```

### 1.2 Criar no GitHub

1. Acesse: https://github.com/new
2. Nome: `claude-code-switcher`
3. Descrição: "🔄 Alternador de modelos LLM para Claude Code - suporte a múltiplos providers (cloud e local)"
4. Público
5. NÃO marque "Add README" (vamos criar customizado)
6. Criar repositório

```bash
# Conectar com GitHub (substitua SEU_USUARIO)
git remote add origin https://github.com/SEU_USUARIO/claude-code-switcher.git
```

---

## 📁 FASE 2: Estrutura de Diretórios

```bash
# Criar estrutura completa
mkdir -p bin
mkdir -p config
mkdir -p docs
mkdir -p scripts
mkdir -p tests

# Criar arquivos base
touch README.md
touch LICENSE
touch CHANGELOG.md
touch CONTRIBUTING.md
```

### Estrutura Final

```
claude-code-switcher/
├── bin/
│   └── claude-switch              # Script principal
├── config/
│   ├── api-keys.env.example       # Template de configuração
│   └── aliases.sh                 # Aliases bash/zsh
├── docs/
│   ├── SETUP.md                   # Guia de instalação
│   ├── PROVIDERS.md               # Documentação de providers
│   ├── TROUBLESHOOTING.md         # Solução de problemas
│   └── DEVELOPMENT.md             # Guia para contribuidores
├── scripts/
│   ├── install.sh                 # Instalador automático
│   ├── uninstall.sh               # Desinstalador
│   └── update.sh                  # Atualizador (futuro)
├── tests/
│   ├── test-providers.sh          # Testes de providers
│   └── test-config.sh             # Testes de configuração
├── .gitignore
├── README.md                      # Documentação principal
├── LICENSE                        # MIT License
├── CHANGELOG.md                   # Histórico de versões
└── CONTRIBUTING.md                # Guia de contribuição
```

---

## 📝 FASE 3: Criar Arquivos Essenciais

### 3.1 LICENSE (MIT)

```bash
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 Renato Roquejani

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
```

### 3.2 README.md (Básico - expandir depois)

```bash
cat > README.md << 'EOF'
# 🔄 Claude Code Switcher

> Alternador de modelos LLM para Claude Code com suporte a múltiplos providers

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)

## ✨ Features

- 🌐 **Cloud Providers:** Anthropic (Opus), Z.AI (GLM), DeepSeek, Kimi, SiliconFlow (Qwen), OpenRouter
- 🏠 **Local Providers:** Ollama, LM Studio
- ⚡ **Switching Rápido:** Troca de modelo sem reconfiguração manual
- 🔒 **Seguro:** API keys armazenadas com permissões restritas
- 🎨 **Aliases Convenientes:** Comandos simplificados para cada provider

## 🚀 Instalação Rápida

```bash
curl -fsSL https://raw.githubusercontent.com/SEU_USUARIO/claude-code-switcher/main/scripts/install.sh | bash
```

## 📖 Documentação

- [Guia de Instalação](docs/SETUP.md)
- [Providers Suportados](docs/PROVIDERS.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Desenvolvimento](docs/DEVELOPMENT.md)

## 🎯 Uso Básico

```bash
# Alternar para Opus (Claude Pro)
claude-switch opus

# Alternar para GLM (Z.AI)
claude-switch glm

# Alternar para Ollama
claude-switch ollama:qwen3-coder

# Ver ajuda
claude-switch help
```

## 🤝 Contribuindo

Contribuições são bem-vindas! Veja [CONTRIBUTING.md](CONTRIBUTING.md) para detalhes.

## 📜 Licença

[MIT](LICENSE) © 2025 Renato Roquejani

## 🗺️ Roadmap

- [ ] Auto-update via `claude-switch update`
- [ ] Config wizard interativo
- [ ] Homebrew formula (macOS)
- [ ] Testes automatizados
- [ ] CI/CD com GitHub Actions
EOF
```

### 3.3 CHANGELOG.md

```bash
cat > CHANGELOG.md << 'EOF'
# Changelog

Todas as mudanças notáveis neste projeto serão documentadas aqui.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Planejado
- Auto-update via `claude-switch update`
- Config wizard interativo
- Homebrew formula

## [2.0.0] - 2025-02-09

### Adicionado
- Suporte a múltiplos cloud providers (Opus, GLM, DeepSeek, Kimi, Qwen, OpenRouter)
- Suporte a providers locais (Ollama, LM Studio)
- Sistema de aliases para acesso rápido
- Validação de API keys
- Detecção automática de configuração atual
- Backup automático de configurações
- Documentação completa

### Changed
- Refatoração completa do script para arquitetura modular
- Melhorias na UX com cores e feedback visual

## [1.0.0] - 2025-02-09

### Adicionado
- Versão inicial com suporte básico a Opus e GLM
- Script simples de alternância
EOF
```

### 3.4 CONTRIBUTING.md

```bash
cat > CONTRIBUTING.md << 'EOF'
# 🤝 Guia de Contribuição

Obrigado por considerar contribuir com o Claude Code Switcher!

## 📋 Como Contribuir

### 1. Fork e Clone

```bash
# Fork no GitHub, depois:
git clone https://github.com/SEU_USUARIO/claude-code-switcher.git
cd claude-code-switcher
```

### 2. Criar Branch

```bash
git checkout -b feature/nova-funcionalidade
# ou
git checkout -b fix/correcao-bug
```

### 3. Fazer Mudanças

- Siga o estilo de código existente
- Adicione comentários quando necessário
- Teste suas mudanças localmente

### 4. Commit

Use mensagens de commit descritivas:

```bash
git commit -m "feat: adiciona suporte ao provider XYZ"
git commit -m "fix: corrige mapeamento de modelos Ollama"
git commit -m "docs: atualiza guia de instalação"
```

**Prefixos recomendados:**
- `feat:` nova funcionalidade
- `fix:` correção de bug
- `docs:` documentação
- `refactor:` refatoração de código
- `test:` adição de testes
- `chore:` tarefas de manutenção

### 5. Push e Pull Request

```bash
git push origin feature/nova-funcionalidade
```

Abra um Pull Request no GitHub com:
- Descrição clara das mudanças
- Referência a issues relacionadas
- Screenshots (se aplicável)

## 🧪 Testando

Antes de submeter um PR, teste:

```bash
# Teste o script
./bin/claude-switch help
./bin/claude-switch list

# Execute testes (quando disponíveis)
./tests/test-providers.sh
```

## 📝 Adicionando Novos Providers

1. Edite `bin/claude-switch`
2. Adicione case em `apply_config()`
3. Adicione validação de API key
4. Atualize documentação em `docs/PROVIDERS.md`
5. Adicione exemplo no README.md

## 💡 Ideias e Sugestões

Abra uma [issue](https://github.com/SEU_USUARIO/claude-code-switcher/issues) para:
- Reportar bugs
- Sugerir funcionalidades
- Discutir melhorias

## 📧 Contato

- Abra uma issue
- Email: renato.roquejani@gmail.com

Obrigado! 🙌
EOF
```

---

## 🔧 FASE 4: Migrar Script Atual

### 4.1 Copiar script para o projeto

```bash
# Copiar script atual
cp ~/.local/bin/claude-switch ./bin/claude-switch

# Verificar
cat ./bin/claude-switch | head -20
```

### 4.2 Criar template de configuração

```bash
cat > config/api-keys.env.example << 'EOF'
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Claude Code Switcher - API Keys Configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# INSTRUÇÕES:
# 1. Copie este arquivo: cp api-keys.env.example api-keys.env
# 2. Preencha suas API keys
# 3. O arquivo api-keys.env está no .gitignore (não será commitado)
#
# ONDE CONSEGUIR AS KEYS:
# - GLM/Z.AI: https://z.ai/manage-apikey/apikey-list
# - DeepSeek: https://platform.deepseek.com/api_keys
# - Kimi: https://platform.moonshot.cn/console/api-keys
# - SiliconFlow: https://siliconflow.cn/account/ak
# - OpenRouter: https://openrouter.ai/keys
#

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CLOUD PROVIDERS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

export GLM_API_KEY=""                    # Z.AI - Plano anual ~$180/ano
export DEEPSEEK_API_KEY=""               # DeepSeek - $0.14/1M input
export KIMI_API_KEY=""                   # Kimi/Moonshot AI
export SILICONFLOW_API_KEY=""            # SiliconFlow - Qwen models
export OPENROUTER_API_KEY=""             # OpenRouter - 100+ models

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OPENROUTER - MODELO DEFAULT (OPCIONAL)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Se configurado, será usado quando executar: claude-switch openrouter
# Exemplos:
# export OPENROUTER_DEFAULT_MODEL="anthropic/claude-opus-4"
# export OPENROUTER_DEFAULT_MODEL="qwen/qwen-2.5-coder-32b"
# export OPENROUTER_DEFAULT_MODEL="deepseek/deepseek-coder"

# export OPENROUTER_DEFAULT_MODEL=""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
```

### 4.3 Criar arquivo de aliases

```bash
cat > config/aliases.sh << 'EOF'
#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Claude Code Switcher - Shell Aliases
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Para usar, adicione no seu ~/.bashrc ou ~/.zshrc:
# source /caminho/para/claude-code-switcher/config/aliases.sh
#

# Cloud providers
alias opus='claude-switch opus && claude'
alias glm='claude-switch glm && claude'
alias deepseek='claude-switch deepseek && claude'
alias kimi='claude-switch kimi && claude'
alias qwen='claude-switch qwen && claude'

# OpenRouter com modelo dinâmico
openrouter() {
  if [ -z "$1" ]; then
    claude-switch openrouter && claude
  else
    claude-switch "openrouter:$1" && claude
  fi
}

# Local providers
alias ollama-claude='claude-switch ollama && claude'
alias lmstudio-claude='claude-switch lmstudio && claude'

# Atalhos úteis
alias ccs='claude-switch'              # Atalho para o comando principal
alias ccs-status='claude-switch status'
alias ccs-list='claude-switch list'
alias ccs-keys='claude-switch keys'
EOF
```

---

## 🚀 FASE 5: Criar Instalador

```bash
cat > scripts/install.sh << 'EOF'
#!/bin/bash

set -e

VERSION="2.0.0"
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.claude"
REPO_URL="https://github.com/SEU_USUARIO/claude-code-switcher"

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}Claude Code Switcher v${VERSION} - Instalador${NC}\n"

# Detectar shell
SHELL_RC="$HOME/.bashrc"
if [ -n "$ZSH_VERSION" ]; then
  SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
  SHELL_RC="$HOME/.bashrc"
fi

# Criar diretórios
echo -e "${YELLOW}→${NC} Criando diretórios..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$CONFIG_DIR/backups"

# Baixar script principal
echo -e "${YELLOW}→${NC} Baixando claude-switch..."
if command -v curl &> /dev/null; then
  curl -fsSL "$REPO_URL/raw/main/bin/claude-switch" -o "$INSTALL_DIR/claude-switch"
elif command -v wget &> /dev/null; then
  wget -q "$REPO_URL/raw/main/bin/claude-switch" -O "$INSTALL_DIR/claude-switch"
else
  echo -e "${RED}❌ curl ou wget não encontrado${NC}"
  exit 1
fi

chmod +x "$INSTALL_DIR/claude-switch"

# Criar arquivo de configuração se não existir
if [ ! -f "$CONFIG_DIR/api-keys.env" ]; then
  echo -e "${YELLOW}→${NC} Criando template de configuração..."
  curl -fsSL "$REPO_URL/raw/main/config/api-keys.env.example" -o "$CONFIG_DIR/api-keys.env"
  chmod 600 "$CONFIG_DIR/api-keys.env"
fi

# Adicionar ao shell config
if ! grep -q "api-keys.env" "$SHELL_RC" 2>/dev/null; then
  echo -e "${YELLOW}→${NC} Adicionando ao $SHELL_RC..."
  cat >> "$SHELL_RC" << 'SHELLRC'

# Claude Code Switcher
if [ -f ~/.claude/api-keys.env ]; then
  source ~/.claude/api-keys.env
fi
SHELLRC
fi

# Adicionar aliases
if ! grep -q "claude-switch opus" "$SHELL_RC" 2>/dev/null; then
  echo -e "${YELLOW}→${NC} Adicionando aliases..."
  curl -fsSL "$REPO_URL/raw/main/config/aliases.sh" >> "$SHELL_RC"
fi

echo -e "\n${GREEN}✅ Instalação concluída!${NC}\n"
echo -e "${BOLD}Próximos passos:${NC}"
echo -e "1. Recarregue o shell: ${YELLOW}source $SHELL_RC${NC}"
echo -e "2. Configure suas API keys: ${YELLOW}nano ~/.claude/api-keys.env${NC}"
echo -e "3. Veja a ajuda: ${YELLOW}claude-switch help${NC}"
echo -e "4. Liste providers: ${YELLOW}claude-switch list${NC}\n"
EOF

chmod +x scripts/install.sh
```

---

## 🐛 FASE 6: Fixes Necessários (CRÍTICO)

### 6.1 Fix Ollama - Mapeamento de Modelos

O problema do Ollama é que o Claude Code tenta acessar modelos com nomes específicos (claude-sonnet-4-5-20250929) mas o Ollama tem nomes diferentes (qwen3-coder).

**Solução:** Mapear os aliases do Claude Code para os modelos do Ollama.

```bash
# Adicionar no script bin/claude-switch, dentro do case "ollama":

# ANTES (código atual - problemático):
jq --arg model "$model" \
   '.env.ANTHROPIC_AUTH_TOKEN = "ollama" | 
    .env.ANTHROPIC_BASE_URL = "http://localhost:11434/v1/anthropic" |
    .env.ANTHROPIC_DEFAULT_OPUS_MODEL = $model' \
   "$SETTINGS" > "$SETTINGS.tmp"

# DEPOIS (código corrigido):
jq --arg model "$model" \
   '.env.ANTHROPIC_AUTH_TOKEN = "ollama" | 
    .env.ANTHROPIC_BASE_URL = "http://localhost:11434/v1" |
    .env.ANTHROPIC_DEFAULT_OPUS_MODEL = $model |
    .env.ANTHROPIC_DEFAULT_SONNET_MODEL = $model |
    .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = $model' \
   "$SETTINGS" > "$SETTINGS.tmp"
```

**Explicação:** Mapeamos TODOS os aliases (opus, sonnet, haiku) para o mesmo modelo do Ollama, assim qualquer tentativa do Claude Code de usar esses modelos será redirecionada pro modelo local.

### 6.2 Fix OpenRouter - Problema de Silêncio

O comando não mostrava nada porque estava comentado. Mas além disso, o OpenRouter precisa de header adicional.

```bash
# Adicionar no caso "openrouter":

jq --arg token "$OPENROUTER_API_KEY" \
   --arg model "$model" \
   '.env.ANTHROPIC_AUTH_TOKEN = $token | 
    .env.ANTHROPIC_BASE_URL = "https://openrouter.ai/api/v1" |
    .env.ANTHROPIC_DEFAULT_OPUS_MODEL = $model |
    .env.ANTHROPIC_DEFAULT_SONNET_MODEL = $model |
    .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = $model' \
   "$SETTINGS" > "$SETTINGS.tmp"
```

**Nota:** OpenRouter pode precisar de header `HTTP-Referer` e `X-Title` para funcionar corretamente. Isso pode precisar ser configurado via variáveis de ambiente adicionais.

---

## 📚 FASE 7: Criar Documentação

### 7.1 docs/SETUP.md

```bash
cat > docs/SETUP.md << 'EOF'
# 📖 Guia de Instalação

## Pré-requisitos

- Claude Code instalado (`npm install -g @anthropic-ai/claude-code`)
- `jq` instalado (`sudo apt install jq` ou `brew install jq`)
- Bash ou Zsh

## Instalação via Script

```bash
curl -fsSL https://raw.githubusercontent.com/SEU_USUARIO/claude-code-switcher/main/scripts/install.sh | bash
source ~/.bashrc  # ou ~/.zshrc
```

## Instalação Manual

1. Clone o repositório:
```bash
git clone https://github.com/SEU_USUARIO/claude-code-switcher.git
cd claude-code-switcher
```

2. Copie o script:
```bash
cp bin/claude-switch ~/.local/bin/
chmod +x ~/.local/bin/claude-switch
```

3. Configure API keys:
```bash
cp config/api-keys.env.example ~/.claude/api-keys.env
nano ~/.claude/api-keys.env
```

4. Adicione ao shell:
```bash
echo 'source ~/.claude/api-keys.env' >> ~/.bashrc
source config/aliases.sh >> ~/.bashrc
source ~/.bashrc
```

## Verificação

```bash
claude-switch --help
claude-switch list
```

Se aparecer a ajuda e a lista de providers, instalação OK!

## Próximos Passos

- Veja [PROVIDERS.md](PROVIDERS.md) para configurar cada provider
- Veja [TROUBLESHOOTING.md](TROUBLESHOOTING.md) se tiver problemas
EOF
```

### 7.2 docs/PROVIDERS.md

```bash
cat > docs/PROVIDERS.md << 'EOF'
# 🌐 Providers Suportados

## Cloud Providers

### Anthropic Claude (Opus)
- **Comando:** `claude-switch opus` ou `opus`
- **Requisito:** Assinatura Claude Pro ($20/mês)
- **API Key:** Não necessária (usa OAuth)
- **Modelos:** claude-opus-4-6

### Z.AI (GLM)
- **Comando:** `claude-switch glm` ou `glm`
- **Requisito:** Conta Z.AI
- **Onde conseguir:** https://z.ai/manage-apikey/apikey-list
- **Custo:** $3/mês ou $15/mês (anual ~$180/ano)
- **Modelos:** glm-4.5, glm-4.6, glm-4.7

### DeepSeek
- **Comando:** `claude-switch deepseek` ou `deepseek`
- **Onde conseguir:** https://platform.deepseek.com/api_keys
- **Custo:** $0.14/1M input, $0.28/1M output
- **Modelos:** deepseek-chat, deepseek-coder

### Kimi (Moonshot AI)
- **Comando:** `claude-switch kimi` ou `kimi`
- **Onde conseguir:** https://platform.moonshot.cn/console/api-keys
- **Nota:** Pode precisar de número de telefone chinês
- **Modelos:** kimi-for-coding, kimi-k2.5

### Qwen (SiliconFlow)
- **Comando:** `claude-switch qwen` ou `qwen`
- **Onde conseguir:** https://siliconflow.cn/account/ak
- **Custo:** $0.42/1M tokens
- **Modelos:** Qwen2.5-Coder-32B-Instruct

### OpenRouter
- **Comando:** `claude-switch openrouter:modelo` ou `openrouter modelo`
- **Onde conseguir:** https://openrouter.ai/keys
- **Custo:** Varia por modelo
- **Exemplos:**
  ```bash
  claude-switch openrouter:anthropic/claude-opus-4
  claude-switch openrouter:qwen/qwen-2.5-coder-32b
  openrouter deepseek/deepseek-coder
  ```

## Local Providers

### Ollama
- **Comando:** `claude-switch ollama:modelo` ou `ollama-claude`
- **Requisito:** Ollama instalado e rodando
- **Instalação:** https://ollama.com/download
- **Custo:** Gratuito
- **Iniciar:** `ollama serve`
- **Baixar modelos:** `ollama pull qwen2.5-coder:7b`
- **Exemplos:**
  ```bash
  claude-switch ollama:qwen3-coder
  claude-switch ollama:deepseek-coder-v2
  ```

### LM Studio
- **Comando:** `claude-switch lmstudio` ou `lmstudio-claude`
- **Requisito:** LM Studio instalado com servidor ativo
- **Download:** https://lmstudio.ai/
- **Custo:** Gratuito
- **Porta:** 1234 (padrão)
- **Setup:**
  1. Abra LM Studio
  2. Carregue um modelo
  3. Vá em "Local Server"
  4. Clique em "Start Server"

## Comparação de Custos

| Provider | Custo Aproximado | Privacidade | Velocidade |
|----------|-----------------|-------------|------------|
| Opus (Pro) | $20/mês fixo | Baixa | Alta |
| GLM | $15/mês fixo | Baixa | Alta |
| DeepSeek | $0.14/1M tokens | Baixa | Alta |
| Qwen | $0.42/1M tokens | Baixa | Média |
| OpenRouter | Varia | Baixa | Varia |
| Ollama | Gratuito | Alta | Média* |
| LM Studio | Gratuito | Alta | Média* |

*Depende do hardware local
EOF
```

### 7.3 docs/TROUBLESHOOTING.md

```bash
cat > docs/TROUBLESHOOTING.md << 'EOF'
# 🔧 Troubleshooting

## Problemas Comuns

### "API key não configurada"

**Problema:** Ao executar `claude-switch provider`, aparece erro de API key.

**Solução:**
```bash
# Verificar se o arquivo existe
ls -la ~/.claude/api-keys.env

# Verificar se está carregado
echo $GLM_API_KEY

# Se não estiver, recarregar
source ~/.claude/api-keys.env
```

### "Model not found" no Ollama

**Problema:** Claude Code reclama que o modelo não existe.

**Causa:** Ollama não tem os modelos baixados ou o servidor não está rodando.

**Solução:**
```bash
# Verificar se Ollama está rodando
pgrep ollama

# Se não estiver, iniciar
ollama serve &

# Listar modelos instalados
ollama list

# Baixar modelo se necessário
ollama pull qwen2.5-coder:7b
```

### OpenRouter não funciona

**Problema:** OpenRouter não responde ou dá erro.

**Causas possíveis:**
1. API key inválida
2. Modelo especificado incorretamente
3. Falta de headers HTTP

**Solução:**
```bash
# Verificar formato do modelo
claude-switch openrouter:anthropic/claude-opus-4
# Não: claude-switch openrouter:opus

# Testar API key
curl -H "Authorization: Bearer $OPENROUTER_API_KEY" \
     https://openrouter.ai/api/v1/models
```

### "Command not found: claude-switch"

**Problema:** Terminal não encontra o comando.

**Solução:**
```bash
# Verificar se está no PATH
which claude-switch

# Se não estiver, adicionar ao PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Ou reinstalar
curl -fsSL https://raw.githubusercontent.com/SEU_USUARIO/claude-code-switcher/main/scripts/install.sh | bash
```

### Claude Code não aplica a mudança

**Problema:** Troquei o provider mas Claude Code ainda usa o anterior.

**Causa:** Claude Code precisa ser reiniciado.

**Solução:**
```bash
# Matar sessões ativas
pkill -f claude-code

# Ou usar a opção do script
claude-switch provider
# Responder 's' quando perguntar se quer encerrar sessões
```

### LM Studio não conecta

**Problema:** `claude-switch lmstudio` dá erro de conexão.

**Checklist:**
1. LM Studio está aberto?
2. Um modelo está carregado?
3. Servidor local está rodando?
4. Porta é 1234 (padrão)?

**Verificar:**
```bash
# Testar se servidor responde
curl http://localhost:1234/v1/models
```

### Permissão negada no arquivo de configuração

**Problema:** Erro ao tentar modificar settings.json

**Solução:**
```bash
# Verificar permissões
ls -la ~/.claude/settings.json

# Corrigir se necessário
chmod 600 ~/.claude/settings.json
```

## Debug Avançado

### Ativar modo verbose

```bash
# Adicionar ao início do script claude-switch
set -x  # Ativa debug mode
```

### Verificar configuração atual

```bash
# Ver settings.json
cat ~/.claude/settings.json | jq '.env'

# Ver status do switcher
claude-switch status
```

### Restaurar backup

```bash
# Listar backups disponíveis
ls -la ~/.claude/backups/

# Restaurar backup específico
cp ~/.claude/backups/settings.json.backup-20250209-120000 ~/.claude/settings.json
```

## Ainda com problemas?

Abra uma issue no GitHub:
https://github.com/SEU_USUARIO/claude-code-switcher/issues

Inclua:
- Comando executado
- Erro completo
- Output de `claude-switch status`
- Output de `claude --version`
- Sistema operacional
EOF
```

---

## 🧪 FASE 8: Criar Testes Básicos

```bash
cat > tests/test-providers.sh << 'EOF'
#!/bin/bash

# Teste básico dos providers

echo "🧪 Testando Claude Code Switcher..."

# Teste 1: Script existe e é executável
if [ -x "$HOME/.local/bin/claude-switch" ]; then
  echo "✅ Script instalado corretamente"
else
  echo "❌ Script não encontrado ou não executável"
  exit 1
fi

# Teste 2: Comandos básicos funcionam
if claude-switch help > /dev/null 2>&1; then
  echo "✅ Comando help funciona"
else
  echo "❌ Comando help falhou"
  exit 1
fi

# Teste 3: Lista de providers
if claude-switch list > /dev/null 2>&1; then
  echo "✅ Comando list funciona"
else
  echo "❌ Comando list falhou"
  exit 1
fi

# Teste 4: Status atual
if claude-switch status > /dev/null 2>&1; then
  echo "✅ Comando status funciona"
else
  echo "❌ Comando status falhou"
  exit 1
fi

echo ""
echo "✅ Todos os testes básicos passaram!"
EOF

chmod +x tests/test-providers.sh
```

---

## 📦 FASE 9: Primeiro Commit

```bash
# Adicionar tudo ao staging
git add .

# Primeiro commit
git commit -m "feat: versão inicial do claude-code-switcher

- Suporte a 8 providers (cloud e local)
- Sistema de aliases para acesso rápido
- Documentação completa
- Script de instalação automatizado
- Testes básicos
- Estrutura modular para expansão futura

Providers cloud:
- Anthropic Opus (OAuth)
- Z.AI (GLM)
- DeepSeek
- Kimi
- SiliconFlow (Qwen)
- OpenRouter

Providers locais:
- Ollama
- LM Studio"

# Push para o GitHub
git push -u origin main
```

---

## 🎯 FASE 10: Desenvolvimento no Claude Code

### 10.1 Abrir projeto no Claude Code

```bash
cd ~/projects/claude-code-switcher
claude
```

### 10.2 Tarefas prioritárias para o Claude Code

**TAREFA 1: Corrigir bugs críticos**
```
@claude fix o mapeamento de modelos do Ollama e OpenRouter conforme descrito em PROJECT_INIT.md seção 6.1 e 6.2
```

**TAREFA 2: Adicionar testes**
```
@claude crie testes para validar que cada provider configura corretamente o settings.json
```

**TAREFA 3: Melhorar documentação**
```
@claude expanda o README.md com screenshots e exemplos mais detalhados
```

**TAREFA 4: Criar desinstalador**
```
@claude crie scripts/uninstall.sh que remove o switcher e limpa configurações
```

### 10.3 Workflow de desenvolvimento recomendado

1. **Branch por feature:**
```bash
git checkout -b fix/ollama-model-mapping
# Fazer mudanças
git commit -m "fix: corrige mapeamento de modelos Ollama"
git push origin fix/ollama-model-mapping
```

2. **Pull Request:**
- Criar PR no GitHub
- Descrever mudanças
- Mergear na main

3. **Release:**
```bash
# Atualizar CHANGELOG.md
# Criar tag de versão
git tag -a v2.0.1 -m "Correções de bugs do Ollama e OpenRouter"
git push origin v2.0.1
```

---

## 🗺️ ROADMAP

### v2.1.0 (Próxima versão)
- [ ] Fix: Ollama model mapping
- [ ] Fix: OpenRouter headers
- [ ] Testes automatizados completos
- [ ] CI/CD com GitHub Actions

### v2.2.0 (Futuro próximo)
- [ ] Config wizard interativo
- [ ] Auto-update via `claude-switch update`
- [ ] Suporte a mais providers (Groq, Together AI)

### v3.0.0 (Futuro médio)
- [ ] Homebrew formula (macOS)
- [ ] AUR package (Arch Linux)
- [ ] Interface web opcional
- [ ] Telemetria de uso (opt-in)

---

## 📞 Próximos Passos IMEDIATOS

1. **Execute os comandos da FASE 1-9** para criar o repositório
2. **Substitua `SEU_USUARIO`** pelo seu username do GitHub em todos os arquivos
3. **Faça o primeiro push**
4. **Abra no Claude Code** e comece pelos fixes críticos

---

## 💡 Dicas Pro

- Use **GitHub Projects** para organizar issues/features
- Configure **GitHub Actions** para CI/CD quando tiver testes
- Adicione **badges** no README (build status, version, license)
- Crie **release notes** detalhadas a cada versão
- Mantenha **CHANGELOG.md** atualizado
- Responda **issues** rapidamente para engajar comunidade

---

Qualquer dúvida durante o desenvolvimento, é só chamar o Claude Code com `@claude`!

Boa sorte com o projeto! 🚀
EOF
```

---

Agora vou apresentar esse arquivo para você:

<function_calls>
<invoke name="present_files">
<parameter name="filepaths">["/home/claude/PROJECT_INIT.md"]