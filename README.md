# ðŸ¤– Corporate AI - Cloudflare Agent

**Your 24/7 AI agent running on Cloudflare Workers. Replaces your PC setup.**

## âš¡ ONE-CLICK DEPLOY (Easiest)

### Option 1: PowerShell Script (Windows)
```powershell
# Clone repo
git clone https://github.com/davidmschy/corporate-ai-cloudflare-agent.git
cd corporate-ai-cloudflare-agent

# One command deploys everything
.\deploy-one-click.ps1
```

### Option 2: GitHub Actions (Fully Automated)
1. Fork this repo
2. Add secrets to GitHub:
   - `CLOUDFLARE_API_TOKEN` - From Cloudflare dashboard
   - `CLOUDFLARE_ACCOUNT_ID` - From Cloudflare dashboard
3. Click "Actions" â†’ "Deploy to Cloudflare" â†’ "Run workflow"
4. Done! Check Telegram.

### Option 3: Manual Steps
See [DEPLOY.md](DEPLOY.md) for detailed manual instructions.

---

## ðŸ“± What Happens After Deploy

1. **Agent deploys** to Cloudflare Workers (24/7 running)
2. **Database created** (Cloudflare D1)
3. **Storage created** (Cloudflare R2)
4. **Telegram connected** (Webhook set automatically)
5. **Test message sent** to your Telegram
6. **You reply** to start using it

---

## ðŸ’¬ Using Your Agent

Once deployed, message the bot:

| Command | What It Does |
|---------|--------------|
| `hello` | Introduction and capabilities |
| `status` | Check if agent is running |
| `test` | Run connection test |
| Any message | Agent responds with AI |

---

## ðŸ”„ Migration from PC

Once this is working:
1. âœ… Test the Cloudflare agent (reply to messages)
2. âœ… Copy data from PC Obsidian â†’ Cloudflare R2
3. âœ… Copy conversation history â†’ D1 database
4. âœ… Verify everything works
5. âœ… Turn off PC agent
6. âœ… This becomes primary

---

## ðŸ— What's Included

- âœ… Telegram integration (your bot token included)
- âœ… Cloudflare D1 database (conversations, projects)
- âœ… Cloudflare R2 storage (files, documents)
- âœ… 24/7 availability (no PC needed)
- âœ… Auto-scaling (handles any load)
- âœ… Low cost (~$15/month vs $50 PC electricity)

---

## ðŸš€ Next Steps

Once this works:
1. Add Corporate AI features (CEOs, C-suites, sub-agents)
2. Add team members (Amber, Tony, etc.)
3. Add GCP VMs for heavy tasks
4. Launch publicly

---

## ðŸ†˜ Troubleshooting

**Script won't run?**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Wrangler not found?**
```bash
npm install -g wrangler
```

**Not logged in?**
```bash
wrangler login
```

**Need help?** Check [DEPLOY.md](DEPLOY.md)

---

## ðŸ“Š Cost Comparison

| Setup | Monthly Cost |
|-------|-------------|
| PC Running 24/7 | ~$50 (electricity) |
| **Cloudflare Agent** | **~$15** âœ… |

---

**Ready? Run the one-click deploy script above!** ðŸš€
