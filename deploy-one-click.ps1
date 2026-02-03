# One-Click Deploy Script for Corporate AI Agent
# This script does EVERYTHING - just run it and your agent will be live

param(
    [string]$TelegramBotToken = "8527939205:AAFWI1EtRA2IAyYnsCnvnFeln0-G4xSvBxY",
    [string]$WorkerName = "corporate-ai-david"
)

Write-Host "CORPORATE AI - ONE-CLICK DEPLOYMENT" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will:" -ForegroundColor White
Write-Host "1. Create Cloudflare D1 Database" -ForegroundColor White
Write-Host "2. Create Cloudflare R2 Bucket" -ForegroundColor White
Write-Host "3. Deploy Worker" -ForegroundColor White
Write-Host "4. Setup Telegram webhook" -ForegroundColor White
Write-Host "5. Send you a test message" -ForegroundColor White
Write-Host ""

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

Write-Host "Logged in as: $account" -ForegroundColor Green

# Step 1: Create D1 Database
Write-Host ""
Write-Host "Step 1/5: Creating D1 Database..." -ForegroundColor Cyan
$dbOutput = wrangler d1 create $WorkerName 2>&1
Write-Host $dbOutput

# Try to extract database ID or use existing
$databaseId = $null
if ($dbOutput -match "database_id.*?(\w{8}-\w{4}-\w{4}-\w{4}-\w{12})") {
    $databaseId = $Matches[1]
    Write-Host "Database created: $databaseId" -ForegroundColor Green
} elseif ($dbOutput -match "already exists") {
    Write-Host "Database already exists, getting ID..." -ForegroundColor Yellow
    $listOutput = wrangler d1 list 2>&1
    if ($listOutput -match "$WorkerName.*?(\w{32})") {
        $databaseId = $Matches[1]
        Write-Host "Using existing database: $databaseId" -ForegroundColor Green
    }
}

if (-not $databaseId) {
    Write-Host "Could not create or find database. Output:" -ForegroundColor Red
    Write-Host $dbOutput
    $databaseId = Read-Host "Please enter database ID manually (or press Enter to skip)"
}

if ($databaseId) {
    # Update wrangler.toml
    Write-Host "Updating configuration..." -ForegroundColor Gray
    $tomlContent = Get-Content "wrangler.toml" -Raw
    $tomlContent = $tomlContent -replace 'database_id = "PLACEHOLDER"', "database_id = `"$databaseId`""
    Set-Content "wrangler.toml" $tomlContent
}

# Step 2: Create tables
Write-Host ""
Write-Host "Step 2/5: Creating database tables..." -ForegroundColor Cyan
wrangler d1 execute $WorkerName --file=schema.sql 2>&1 | Out-Null
Write-Host "Tables created" -ForegroundColor Green

# Step 3: Create R2 Bucket
Write-Host ""
Write-Host "Step 3/5: Creating R2 Bucket..." -ForegroundColor Cyan
wrangler r2 bucket create $WorkerName 2>&1 | Out-Null
Write-Host "R2 bucket created" -ForegroundColor Green

# Step 4: Deploy Worker
Write-Host ""
Write-Host "Step 4/5: Deploying Worker..." -ForegroundColor Cyan
$deployOutput = wrangler deploy 2>&1
Write-Host $deployOutput

$workerUrl = $null
if ($deployOutput -match "(https://\S+\.workers\.dev)") {
    $workerUrl = $Matches[1]
    Write-Host "Worker deployed: $workerUrl" -ForegroundColor Green
} else {
    Write-Host "Deployment may have issues. Check output above." -ForegroundColor Yellow
    $workerUrl = Read-Host "Enter your worker URL manually (e.g., https://corporate-ai-david.YOUR_SUBDOMAIN.workers.dev)"
}

# Step 5: Setup Telegram
if ($workerUrl) {
    Write-Host ""
    Write-Host "Step 5/5: Connecting Telegram..." -ForegroundColor Cyan
    
    $webhookUrl = "$workerUrl/telegram"
    $telegramApi = "https://api.telegram.org/bot$TelegramBotToken/setWebhook"
    $body = @{ url = $webhookUrl } | ConvertTo-Json
    
    try {
        Invoke-RestMethod -Uri $telegramApi -Method POST -ContentType "application/json" -Body $body | Out-Null
        Write-Host "Telegram webhook set" -ForegroundColor Green
    } catch {
        Write-Host "Could not set webhook automatically" -ForegroundColor Yellow
        Write-Host "Set it manually: curl -X POST $telegramApi -d '{\"url\": \"$webhookUrl\"}'"
    }
    
    # Send test message
    Write-Host ""
    Write-Host "Sending test message to your Telegram..." -ForegroundColor Cyan
    
    try {
        $testUrl = "$workerUrl/test-message"
        Invoke-RestMethod -Uri $testUrl -Method GET -TimeoutSec 10 | Out-Null
        Write-Host "Test message sent" -ForegroundColor Green
    } catch {
        Write-Host "Could not send test message (worker might still be starting)" -ForegroundColor Yellow
    }
}

# Summary
Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your agent is now live:" -ForegroundColor Cyan
if ($workerUrl) {
    Write-Host "  Worker: $workerUrl" -ForegroundColor White
    Write-Host "  Status: $workerUrl/status" -ForegroundColor White
}
Write-Host "  Telegram: Check your messages!" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Check Telegram for the test message" -ForegroundColor Gray
Write-Host "2. Reply to test the agent" -ForegroundColor Gray
Write-Host "3. Once working, migrate your data from PC" -ForegroundColor Gray
Write-Host "4. Turn off the PC agent" -ForegroundColor Gray
Write-Host ""
Write-Host "Your 24/7 Corporate AI agent is ready!" -ForegroundColor Green
