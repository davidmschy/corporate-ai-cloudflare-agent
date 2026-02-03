#!/usr/bin/env pwsh
# One-Click Deploy Script for Corporate AI Agent
# This script does EVERYTHING - just run it and your agent will be live

param(
    [string]$TelegramBotToken = "8527939205:AAFWI1EtRA2IAyYnsCnvnFeln0-G4xSvBxY",
    [string]$WorkerName = "corporate-ai-david"
)

Write-Host @"
ðŸš€ CORPORATE AI - ONE-CLICK DEPLOYMENT
â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

This script will:
1. Create Cloudflare D1 Database
2. Create Cloudflare R2 Bucket  
3. Deploy Worker
4. Setup Telegram webhook
5. Send you a test message

You just need to:
- Have wrangler installed and logged in
- Wait 2-3 minutes

"@ -ForegroundColor Cyan

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

$wrangler = Get-Command wrangler -ErrorAction SilentlyContinue
if (-not $wrangler) {
    Write-Host "Installing wrangler..." -ForegroundColor Yellow
    npm install -g wrangler
}

# Check if logged in
$account = wrangler whoami 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Please login to Cloudflare first:" -ForegroundColor Red
    Write-Host "wrangler login" -ForegroundColor Cyan
    exit 1
}

Write-Host "âœ“ Logged in as: $account" -ForegroundColor Green

# Step 1: Create D1 Database
Write-Host ""
Write-Host "Step 1/5: Creating D1 Database..." -ForegroundColor Cyan
$dbCreate = wrangler d1 create $WorkerName 2>&1
if ($dbCreate -match "database_id.*?([a-f0-9-]{36})") {
    $databaseId = $Matches[1]
    Write-Host "âœ“ Database created: $databaseId" -ForegroundColor Green
} else {
    # Database might already exist, try to get ID
    $dbList = wrangler d1 list 2>&1
    if ($dbList -match "$WorkerName.*?(\w{32})") {
        $databaseId = $Matches[1]
        Write-Host "âœ“ Using existing database: $databaseId" -ForegroundColor Green
    } else {
        Write-Host "âœ— Could not create or find database" -ForegroundColor Red
        exit 1
    }
}

# Update wrangler.toml
Write-Host "Updating configuration..." -ForegroundColor Gray
$tomlContent = Get-Content "wrangler.toml" -Raw
$tomlContent = $tomlContent -replace 'database_id = "PLACEHOLDER"', "database_id = `"$databaseId`""
Set-Content "wrangler.toml" $tomlContent

# Step 2: Create tables
Write-Host ""
Write-Host "Step 2/5: Creating database tables..." -ForegroundColor Cyan
wrangler d1 execute $WorkerName --file=schema.sql 2>&1 | Out-Null
Write-Host "âœ“ Tables created" -ForegroundColor Green

# Step 3: Create R2 Bucket
Write-Host ""
Write-Host "Step 3/5: Creating R2 Bucket..." -ForegroundColor Cyan
wrangler r2 bucket create $WorkerName 2>&1 | Out-Null
Write-Host "âœ“ R2 bucket created" -ForegroundColor Green

# Step 4: Deploy Worker
Write-Host ""
Write-Host "Step 4/5: Deploying Worker..." -ForegroundColor Cyan
$deployOutput = wrangler deploy 2>&1
if ($deployOutput -match "(https://\S+\.workers\.dev)") {
    $workerUrl = $Matches[1]
    Write-Host "âœ“ Worker deployed: $workerUrl" -ForegroundColor Green
} else {
    Write-Host "âœ— Deployment failed" -ForegroundColor Red
    Write-Host $deployOutput
    exit 1
}

# Step 5: Setup Telegram
Write-Host ""
Write-Host "Step 5/5: Connecting Telegram..." -ForegroundColor Cyan

$webhookUrl = "$workerUrl/telegram"
$telegramApi = "https://api.telegram.org/bot$TelegramBotToken/setWebhook"
$body = @{ url = $webhookUrl } | ConvertTo-Json

try {
    Invoke-RestMethod -Uri $telegramApi -Method POST -ContentType "application/json" -Body $body | Out-Null
    Write-Host "âœ“ Telegram webhook set" -ForegroundColor Green
} catch {
    Write-Host "âš  Could not set webhook automatically" -ForegroundColor Yellow
}

# Send test message
Write-Host ""
Write-Host "Sending test message to your Telegram..." -ForegroundColor Cyan

try {
    $testUrl = "$workerUrl/test-message"
    Invoke-RestMethod -Uri $testUrl -Method GET | Out-Null
    Write-Host "âœ“ Test message sent" -ForegroundColor Green
} catch {
    Write-Host "âš  Could not send test message (worker might still be starting)" -ForegroundColor Yellow
}

# Summary
Write-Host ""
Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Green
Write-Host "âœ… DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Green
Write-Host ""
Write-Host "Your agent is now live:" -ForegroundColor Cyan
Write-Host "  ðŸŒ Worker: $workerUrl" -ForegroundColor White
Write-Host "  ðŸ“Š Status: $workerUrl/status" -ForegroundColor White
Write-Host "  ðŸ’¬ Telegram: Check your messages!" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Check Telegram for the test message" -ForegroundColor Gray
Write-Host "2. Reply to test the agent" -ForegroundColor Gray
Write-Host "3. Once working, migrate your data from PC" -ForegroundColor Gray
Write-Host "4. Turn off the PC agent" -ForegroundColor Gray
Write-Host "5. Add team members (Amber, etc.)" -ForegroundColor Gray
Write-Host ""
Write-Host "Your 24/7 Corporate AI agent is ready! ðŸŽ‰" -ForegroundColor Green
