# Detailed Deployment Guide

## Prerequisites

1. **Node.js 18+** - [Download](https://nodejs.org/)
2. **Cloudflare Account** - [Sign up](https://dash.cloudflare.com/sign-up) (free)
3. **Wrangler CLI** - Install: `npm install -g wrangler`

## Step-by-Step Deployment

### 1. Get Your Cloudflare Credentials

**API Token:**
1. Go to https://dash.cloudflare.com/profile/api-tokens
2. Click "Create Token"
3. Use "Edit Cloudflare Workers" template
4. Copy the token

**Account ID:**
1. Go to https://dash.cloudflare.com
2. Look on the right sidebar for "Account ID"
3. Copy it

### 2. Login to Wrangler

```bash
wrangler login
# Opens browser, click approve
```

### 3. Clone This Repo

```bash
git clone https://github.com/davidmschy/corporate-ai-cloudflare-agent.git
cd corporate-ai-cloudflare-agent
```

### 4. Create D1 Database

```bash
wrangler d1 create corporate-ai-david
```

**Output example:**
```
âœ… Successfully created DB 'corporate-ai-david'
ðŸ“‹ Database ID: 12345678-1234-1234-1234-123456789012
```

**Copy the Database ID.**

### 5. Update Configuration

Edit `wrangler.toml`:

```toml
[[env.production.d1_databases]]
binding = "DB"
database_name = "corporate-ai-david"
database_id = "12345678-1234-1234-1234-123456789012"  # <-- PASTE YOUR ID HERE
```

### 6. Create Database Tables

```bash
wrangler d1 execute corporate-ai-david --file=schema.sql
```

### 7. Create R2 Bucket

```bash
wrangler r2 bucket create corporate-ai-david
```

### 8. Deploy the Worker

```bash
wrangler deploy
```

**Output example:**
```
âœ¨ Success! Uploaded corporate-ai-david
ðŸŒŽ https://corporate-ai-david.your-subdomain.workers.dev
```

**Copy your Worker URL.**

### 9. Set Telegram Webhook

Replace `YOUR_WORKER_URL` with the URL from step 8:

```bash
curl -X POST "https://api.telegram.org/bot8527939205:AAFWI1EtRA2IAyYnsCnvnFeln0-G4xSvBxY/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{"url": "YOUR_WORKER_URL/telegram"}'
```

### 10. Test It

Visit your worker's test endpoint:

```bash
curl https://your-worker-url/test-message
```

**Check Telegram!** You should receive a message.

---

## Verification

Test these endpoints:

1. **Status Check:**
   ```
   https://your-worker-url/status
   ```

2. **Send Test Message:**
   ```
   https://your-worker-url/test-message
   ```

3. **Message the bot on Telegram**
   - It should reply to any message

---

## Common Issues

### "database_id is invalid"
- Make sure you copied the full UUID from step 4
- Format: `12345678-1234-1234-1234-123456789012`

### "Failed to create bucket"
- R2 might need to be enabled in your Cloudflare account
- Go to https://dash.cloudflare.com â†’ R2 â†’ Enable

### "Webhook not set"
- Check worker URL is correct
- Try manually visiting the webhook URL in browser
- Check Telegram bot token is correct

### "Test message not received"
- Worker might still be starting (wait 30 seconds)
- Check worker logs: `wrangler tail`
- Verify webhook is set: https://api.telegram.org/bot8527939205:AAFWI1EtRA2IAyYnsCnvnFeln0-G4xSvBxY/getWebhookInfo

---

## After Deployment

1. âœ… Test messaging the bot
2. âœ… Verify 24/7 availability
3. âœ… Migrate data from PC
4. âœ… Turn off PC agent
5. âœ… Add team members

---

## Costs

- **Cloudflare Workers**: $5/month (10M requests included)
- **D1 Database**: $5/month (5M rows included)
- **R2 Storage**: First 10GB free, then $0.015/GB
- **Total**: ~$10-15/month

---

**Questions?** Open an issue on GitHub.
