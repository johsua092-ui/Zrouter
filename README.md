<div align="center">

# ZelAI Gateway

**Local-first AI gateway and LLM proxy for OpenAI, Anthropic, and custom models.**

Keep a single stable endpoint while ZelAI routes requests, refreshes OAuth tokens, enforces quotas, and monitors live telemetry.

<p>
  <a href="https://github.com/zelapii/Zrouter/releases"><img src="https://img.shields.io/badge/version-v0.1.3-6366f1?style=flat-square" alt="Version"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-22c55e?style=flat-square" alt="MIT License"></a>
  <a href="https://nodejs.org/"><img src="https://img.shields.io/badge/node-%3E%3D22-339933?style=flat-square&logo=node.js&logoColor=white" alt="Node.js"></a>
  <a href="https://hono.dev/"><img src="https://img.shields.io/badge/Hono-v4-e36002?style=flat-square" alt="Hono"></a>
  <a href="https://react.dev/"><img src="https://img.shields.io/badge/React-v19-61dafb?style=flat-square&logo=react&logoColor=black" alt="React"></a>
  <a href="https://www.sqlite.org/"><img src="https://img.shields.io/badge/SQLite-WAL-003b57?style=flat-square&logo=sqlite&logoColor=white" alt="SQLite"></a>
</p>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-dark.gif">
    <source media="(prefers-color-scheme: light)" srcset="docs/images/demo-light.gif">
    <img src="docs/images/demo-dark.gif" alt="ZelAI Dashboard Walkthrough" width="100%">
  </picture>
</p>

[Quick Start](#quick-start) | [Features](#features) | [Providers](#supported-providers) | [API Reference](#api-endpoints) | [Docker](#docker) | [Development](#development) | [CLI](#cli-tools) | [Architecture](#architecture)

</div>

---

## Table of Contents

- [Quick Start](#quick-start)
- [Features](#features)
- [Supported Providers](#supported-providers)
- [Connect Coding Tools](#connect-coding-tools)
- [Integrate](#integrate)
- [API Endpoints](#api-endpoints)
- [Docker](#docker)
- [Development](#development)
- [CLI Tools](#cli-tools)
- [Architecture](#architecture)
- [Configuration](#configuration)
- [Security](#security)
- [Contributing](#contributing)
- [License](#license)

---

## Quick Start

Get ZelAI running locally in under a minute.

### Option A: Docker (Recommended)

```bash
docker run -d \
  --name zelai \
  --restart unless-stopped \
  -p 3000:3000 \
  -p 1455:1455 \
  -v zelai_data:/root/.srouter \
  ghcr.io/seaavey/srouter:latest
```

### Option B: Local Node.js

```bash
git clone https://github.com/zelapii/Zrouter.git
cd SRouter
pnpm install
pnpm build
pnpm start
```

### First Run

1. Open **`http://localhost:3000`** to access the dashboard
2. Create your admin password on first visit
3. Configure provider accounts under **Providers**
4. Generate a virtual key in **API Keys**
5. Test endpoints immediately in **Playground**

---

## Features

### Core

| Feature | Description |
|---------|-------------|
| **Unified Protocol Translation** | Translate between OpenAI `chat/completions` and Anthropic `messages` formats dynamically |
| **Multi-Provider Routing** | Route requests to 57+ upstream providers through a single endpoint |
| **Failover & Cascade Routing** | Define fallback chains: when a provider returns 429 or is down, automatically try the next |
| **Virtual API Keys** | Issue scoped keys (`sr-live-*`) with rate limits, token quotas, credit limits, and model allowlists |
| **Automated OAuth Refresh** | Background sweeper keeps short-lived OAuth sessions refreshed without downtime |
| **Token Saver Engine** | System-level prompt compression and concise coding rules to cut inference cost |
| **Built-in Cloudflare Tunnel** | Expose your local gateway securely with zero open ports, managed from the UI |
| **Embedded Observability** | Track token usage, cache efficiency, estimated costs, and latency in SQLite WAL |
| **Web Search Interception** | Intercepts `web_search` tool calls and performs them server-side via DuckDuckGo |
| **Admin Dashboard** | Full React UI for managing providers, keys, models, settings, logs, and tunnel state |

### Security

| Feature | Description |
|---------|-------------|
| **Local-First Credential Isolation** | OAuth tokens and provider secrets stay in your local SQLite database |
| **Virtual Client Keys** | Downstream apps use virtual keys, never touching upstream master credentials |
| **Rate Limiting** | Per-key rate limit enforcement at the middleware level |
| **CSRF Protection** | Origin guard for cookie-authenticated mutations |
| **Security Headers** | X-Powered-By, X-Version, X-Content-Type-Options, X-Frame-Options, XSS-Protection |

---

## Supported Providers

ZelAI normalizes authentication and protocol differences across all major model providers:

### OAuth Providers

| Provider | Model Prefix | Auth Method | Streaming |
| :--- | :--- | :--- | :---: |
| **Google Antigravity** | `antigravity/*` | OAuth 2.0 PKCE | Yes |
| **OpenAI Codex / ChatGPT** | `openai_codex/*` | OAuth 2.0 PKCE | Yes |
| **Anthropic Claude** | `anthropic/*` | API Key / OAuth | Yes |
| **CodeBuddy** | `codebuddy/*` | OAuth | Yes |
| **Qoder** | `qoder/*` | OAuth / Device Token | Yes |

### API Key Providers

| Provider | Model Prefix | Base URL |
| :--- | :--- | :--- |
| **DeepSeek** | `deepseek/*` | chat.deepseek.com |
| **Groq** | `groq/*` | api.groq.com/openai/v1 |
| **Mistral AI** | `mistral/*` | api.mistral.ai/v1 |
| **Google Gemini** | `gemini/*` | generativelanguage.googleapis.com |
| **Together AI** | `together/*` | api.together.xyz/v1 |
| **OpenRouter** | `openrouter/*` | openrouter.ai/api/v1 |
| **Cerebras** | `cerebras/*` | api.cerebras.ai/v1 |
| **Fireworks AI** | `fireworks/*` | api.fireworks.ai/inference/v1 |
| **xAI (Grok)** | `xai/*` | api.x.ai/v1 |
| **Cohere** | `cohere/*` | api.cohere.com/v2 |
| **Perplexity** | `perplexity/*` | api.perplexity.ai |
| **NVIDIA NIM** | `nvidia/*` | integrate.api.nvidia.com/v1 |
| **SambaNova** | `sambanova/*` | api.sambanova.ai/v1 |
| **Kimi (Moonshot)** | `kimi/*` | api.moonshot.cn/v1 |
| **GLM (Zhipu AI)** | `glm/*` | open.bigmodel.cn/api/paas/v4 |
| **Amazon Q / Kiro** | `kiro/*` | Custom |
| **Command Code** | `commandcode/*` | api.commandcode.ai |
| + 40 more providers | | |

### Free Tier Providers

| Provider | Model Prefix |
| :--- | :--- |
| **GoRouter** | `gorouter/*` |
| **BluesMinds** | `bluesminds/*` |
| **SeekAI** | `seekai/*` |
| **TabiToken** | `tabitoken/*` |
| **OpenCode Zen** | `opencode_zen/*` |

### Self-Hosted Providers

| Provider | Model Prefix | Default URL |
| :--- | :--- | :--- |
| **Ollama** | `ollama/*` | http://localhost:11434/v1 |
| **vLLM** | `vllm/*` | http://127.0.0.1:8000/v1 |
| **SGLang** | `sglang/*` | http://127.0.0.1:30000/v1 |
| **LM Studio** | `lmstudio/*` | http://localhost:1234/v1 |
| **llama.cpp** | `llamacpp/*` | http://127.0.0.1:8080/v1 |

---

## Connect Coding Tools

### CLI (Recommended)

```bash
# Interactive setup wizard
npx @srouter/cli setup

# Check status and link tools
npx @srouter/cli doctor
npx @srouter/cli link claude --model claude-sonnet-4-20250514
npx @srouter/cli link opencode --model antigravity/gemini-2.5-flash

# Run tools directly wrapped in ZelAI environment
npx @srouter/cli run claude
```

### Manual Configuration

Point your editor or extension to your local ZelAI instance:

| Setting | Value |
|---------|-------|
| **Base URL** | `http://localhost:3000/v1` |
| **API Key** | `sr-live-your_key` |
| **Model** | Any model from `/v1/models` |

Supported tools: OpenCode, Claude Code, Cursor, Cline, Windsurf, Continue, GitHub Copilot, OpenAI Codex.

---

## Integrate

ZelAI exposes standard OpenAI and Anthropic compatible interfaces.

### OpenAI SDK (Python)

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:3000/v1",
    api_key="sr-live-your_virtual_key"
)

stream = client.chat.completions.create(
    model="deepseek/deepseek-chat",
    messages=[{"role": "user", "content": "Explain vector embeddings in one sentence."}],
    stream=True
)

for chunk in stream:
    print(chunk.choices[0].delta.content or "", end="", flush=True)
```

### Anthropic SDK (TypeScript)

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic({
    baseURL: "http://localhost:3000/v1",
    apiKey: "sr-live-your_virtual_key"
});

const message = await client.messages.create({
    model: "anthropic/claude-sonnet-4-20250514",
    max_tokens: 1024,
    messages: [{ role: "user", "content: "Hello from ZelAI!" }]
});

console.log(message.content[0].text);
```

### cURL

```bash
curl -N http://localhost:3000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sr-live-your_virtual_key" \
  -d '{
    "model": "deepseek/deepseek-chat",
    "messages": [{"role": "user", "content": "Ping!"}],
    "stream": true
  }'
```

---

## API Endpoints

All gateway endpoints are served under `/v1`:

### Inference

| Method | Endpoint | Auth | Description |
| :--- | :--- | :--- | :--- |
| `POST` | `/v1/chat/completions` | ApiKeyAuth | OpenAI chat completion (streaming supported) |
| `POST` | `/v1/messages` | ApiKeyAuth | Anthropic messages endpoint |
| `GET` | `/v1/models` | ApiKeyAuth | List all discovered and connected models |
| `GET` | `/v1/models/:model` | ApiKeyAuth | Retrieve specific model schema and capabilities |

### Management

| Method | Endpoint | Auth | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/health` | None | Server health check |
| `GET` | `/v1` | None | API info and base URL discovery |
| `GET` | `/v1/quota` | ApiKeyAuth | Real-time provider balance and reset countdowns |
| `GET` | `/v1/logs` | ApiKeyAuth | Query request audit logs and token telemetry |
| `GET` | `/v1/logs/stats` | ApiKeyAuth | Aggregated log statistics |

### Providers

| Method | Endpoint | Auth | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/v1/providers` | ApiKeyAuth | List all configured providers |
| `GET` | `/v1/providers/catalog` | ApiKeyAuth | Full provider catalog |
| `GET` | `/v1/providers/:id` | ApiKeyAuth | Get specific provider status |
| `POST` | `/v1/providers` | RequireAdmin | Add or connect a new provider |
| `POST` | `/v1/providers/verify` | RequireAdmin | Verify provider credentials |
| `DELETE` | `/v1/providers/:id` | RequireAdmin | Delete a provider connection |

### API Keys

| Method | Endpoint | Auth | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/v1/keys` | ApiKeyAuth | List all virtual API keys |
| `POST` | `/v1/keys` | RequireAdmin | Create a new virtual API key |
| `PATCH` | `/v1/keys/:id` | RequireAdmin | Update a virtual API key |
| `POST` | `/v1/keys/:id/credit` | RequireAdmin | Add credit to a key |
| `DELETE` | `/v1/keys/:id` | RequireAdmin | Delete a virtual API key |

### Settings

| Method | Endpoint | Auth | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/v1/settings` | ApiKeyAuth | Get global system settings |
| `PATCH` | `/v1/settings` | RequireAdmin | Update global settings |
| `GET` | `/v1/settings/token-saver` | ApiKeyAuth | Get Token Saver config |
| `PATCH` | `/v1/settings/token-saver` | RequireAdmin | Update Token Saver config |
| `GET` | `/v1/settings/fallbacks` | ApiKeyAuth | Get all fallback rules |
| `POST` | `/v1/settings/fallbacks` | RequireAdmin | Create a fallback rule |

### OAuth

| Method | Endpoint | Auth | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/v1/auth/:provider/login` | RequireAdmin | Start OAuth flow |
| `GET/POST` | `/v1/auth/:provider/callback` | None | OAuth callback |
| `POST` | `/v1/auth/:provider/token` | RequireAdmin | Import token manually |

### Admin

| Method | Endpoint | Auth | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/v1/admin/status` | None | Check admin setup status |
| `POST` | `/v1/admin/setup` | None | First-run admin account setup |
| `POST` | `/v1/admin/login` | None | Admin login (cookie-based) |
| `POST` | `/v1/admin/change-password` | Session | Change admin password |
| `POST` | `/v1/admin/logout` | Session | Admin logout |

### Tunnel

| Method | Endpoint | Auth | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/v1/tunnel/status` | RequireAdmin | Get tunnel daemon status |
| `POST` | `/v1/tunnel/start` | RequireAdmin | Start Cloudflare tunnel |
| `POST` | `/v1/tunnel/stop` | RequireAdmin | Stop Cloudflare tunnel |
| `PUT` | `/v1/tunnel/config` | RequireAdmin | Update tunnel configuration |
| `POST` | `/v1/tunnel/install` | RequireAdmin | Install cloudflared binary |

---

## Docker

### Single Container

```bash
docker run -d \
  --name zelai \
  --restart unless-stopped \
  -p 3000:3000 \
  -p 1455:1455 \
  -v zelai_data:/root/.srouter \
  ghcr.io/seaavey/srouter:latest
```

### Docker Compose

```yaml
services:
  zelai:
    image: ghcr.io/seaavey/srouter:latest
    container_name: zelai
    restart: unless-stopped
    ports:
      - "3000:3000"
      - "1455:1455"
    volumes:
      - zelai_data:/root/.srouter
    environment:
      - PORT=3000
      - NODE_ENV=production

volumes:
  zelai_data:
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3000` | API Gateway and Dashboard port |
| `OAUTH_PORT` | `1455` | OAuth Callback Listener port |
| `DATABASE_PATH` | `~/.srouter/srouter.db` | SQLite database file location |
| `NODE_ENV` | `development` | Node environment |
| `SROUTER_ADMIN_PASSWORD` | - | Bootstrap admin account from environment |
| `SROUTER_SECURE_COOKIES` | `false` | Enable Secure flag on admin session cookies |
| `SROUTER_CORS_ORIGINS` | - | Comma-separated CORS origins allowlist |

---

## Development

### Prerequisites

- Node.js >= 22.0.0 (native `node:sqlite` required)
- pnpm >= 10

### Setup

```bash
git clone https://github.com/zelapii/Zrouter.git
cd SRouter
pnpm install
```

### Commands

| Command | Description |
|---------|-------------|
| `pnpm dev` | Start API + Dashboard with HMR |
| `pnpm dev:api` | API-only dev with hot reload |
| `pnpm dev:web` | Dashboard-only dev with HMR |
| `pnpm build` | Full monorepo build |
| `pnpm build:api` | Build API only |
| `pnpm build:web` | Build dashboard only |
| `pnpm clean` | Clean all build artifacts |
| `pnpm format` | Format codebase with Prettier |

### Project Structure

```
srouter/
├── apps/
│   ├── api/          Hono 4 REST API server
│   └── web/          React 19 dashboard UI
├── packages/
│   ├── types/        Zod schemas and TypeScript interfaces
│   ├── constants/    Version constants and provider catalog
│   ├── db/           SQLite repository layer (WAL mode)
│   ├── executors/    Upstream provider driver classes
│   ├── pricing/      Token pricing and cost calculators
│   ├── providers/    Multi-provider runtime coordinator
│   └── translator/   OpenAI/Anthropic protocol translation
└── docs/             Documentation assets
```

### Tech Stack

| Layer | Technology |
|-------|-----------|
| Runtime | Node.js >= 22, ESM only |
| Monorepo | pnpm workspaces + Turborepo |
| API | Hono 4 on `@hono/node-server` |
| Validation | Zod 3.24 via `@hono/zod-validator` |
| Database | Native `node:sqlite` (WAL mode) |
| Dashboard | React 19, TanStack Router + Query |
| Styling | Tailwind CSS v4, OKLCH theme |
| Build | Vite 6 (web), tsup (API), tsc (packages) |
| Testing | `node:test` via tsx |

---

## CLI Tools

The ZelAI CLI provides quick setup and tool integration:

```bash
# Install globally
npm install -g @srouter/cli

# Or use directly
npx @srouter/cli <command>
```

### Commands

| Command | Description |
|---------|-------------|
| `setup` | Interactive setup wizard for first-time configuration |
| `doctor` | Check status and diagnose linked tools |
| `link <tool> --model <model>` | Link a coding tool to ZelAI |
| `run <tool>` | Run a tool wrapped in ZelAI environment |
| `status` | Show current ZelAI status |
| `sync` | Synchronize provider configurations |

### Supported Tools

- **OpenCode** - `~/.config/opencode/opencode.json`
- **Claude Code** - `~/.claude/settings.json`
- **Cursor** - `~/.cursor/settings.json`
- **Cline** - `~/.cline/data/globalState.json`
- **OpenAI Codex** - `~/.codex/config.toml`
- **GitHub Copilot** - `~/.config/Code/User/chatLanguageModels.json`

---

## Architecture

### Request Flow

```
Client Request
     │
     ▼
┌─────────────────┐
│  ZelAI Gateway   │
│  (Hono 4)       │
├─────────────────┤
│  ApiKeyAuth      │  Validate virtual key
│  RateLimit       │  Check rate limits
│  ModelAccess     │  Check model allowlist
├─────────────────┤
│  ChatLogic       │  Route + fallback
├─────────────────┤
│  Translator      │  Protocol translation
├─────────────────┤
│  Executor        │  Provider-specific driver
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Upstream API    │
│  (OpenAI, etc.)  │
└─────────────────┘
```

### Dependency Flow

```
routes/v1 → controllers → logic → services / packages/*
```

- **Routes** declare paths, method, validation, and auth
- **Controllers** adapt HTTP to domain calls
- **Logic** owns decisions: cascade, failover, orchestration
- **Services** own side effects: filesystem, tunnels, schedulers
- **Packages** are reusable libraries

---

## Security

ZelAI takes security seriously. For details, see [SECURITY.md](SECURITY.md).

### Key Principles

- **Local-first**: All credentials stay in your local SQLite database
- **No telemetry**: ZelAI never phones home or collects usage data
- **Virtual keys**: Downstream apps never see upstream credentials
- **Optional auth**: Gateway endpoints can be locked down via settings

### Reporting Vulnerabilities

Please report security issues privately via email or GitHub Security Advisory. See [SECURITY.md](SECURITY.md) for details.

---

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Guidelines

- Follow the existing code style
- Write meaningful commit messages
- Update documentation for user-facing changes
- Add tests for new functionality

---

## License

Distributed under the [MIT License](LICENSE). See `LICENSE` for more information.

---

<div align="center">

**Built with care by the ZelAI team**

[GitHub](https://github.com/zelapii/Zrouter) | [Issues](https://github.com/zelapii/Zrouter/issues) | [Discussions](https://github.com/zelapii/Zrouter/discussions)

</div>
