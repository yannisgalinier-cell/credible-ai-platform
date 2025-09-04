# Conversation Vault v3.0 - Local Staging Deployment
# ===================================================

Write-Host "🚀 DEPLOYING CONVERSATION VAULT v3.0 TO LOCAL STAGING" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green

# Set staging environment variables
$env:NODE_ENV = "staging"
$env:PORT = "8080"
$env:DATABASE_URL = "file:./prisma/staging.db"
$env:MCP_SERVER_TOKEN = "staging-vault-token-v3-2025-secure"
$env:MCP_SCOPES = "vault:read,vault:write,vault:verify,vault:search,vault:stream,bridge:register,bridge:await,bridge:push,debate:ask,debate:submit,debate:status"
$env:OBJECT_STORE = "local"
$env:OBJECT_STORE_DIR = ".data/staging-objects"
$env:ENABLE_STREAMING = "true"
$env:ENABLE_DEBATE_MODE = "true"
$env:ENABLE_HTML_REPORTS = "true"
$env:ENABLE_WEBSOCKET = "true"
$env:WS_PORT = "8081"
$env:REPORT_OUTPUT_DIR = "./out"

Write-Host "📦 Building application..." -ForegroundColor Yellow
try {
    pnpm build
    Write-Host "✅ Build successful" -ForegroundColor Green
} catch {
    Write-Host "❌ Build failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host "🗄️  Setting up staging database..." -ForegroundColor Yellow
try {
    # Create staging database
    if (Test-Path "prisma/staging.db") {
        Write-Host "📋 Staging database exists, backing up..."
        Copy-Item "prisma/staging.db" "prisma/staging.db.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    }
    
    # Run migrations
    npx prisma db push --schema prisma/schema.prisma
    Write-Host "✅ Database setup complete" -ForegroundColor Green
} catch {
    Write-Host "❌ Database setup failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host "🌱 Seeding staging database..." -ForegroundColor Yellow
try {
    npx tsx prisma/seed.ts
    Write-Host "✅ Database seeded" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Seeding skipped (may already exist)" -ForegroundColor Yellow
}

Write-Host "🔧 Creating staging directories..." -ForegroundColor Yellow
if (!(Test-Path ".data/staging-objects")) {
    New-Item -Path ".data/staging-objects" -ItemType Directory -Force
}
if (!(Test-Path "out")) {
    New-Item -Path "out" -ItemType Directory -Force
}

Write-Host "🚀 Starting Conversation Vault v3.0 in staging mode..." -ForegroundColor Green
Write-Host ""
Write-Host "🌐 STAGING ENDPOINTS:" -ForegroundColor Cyan
Write-Host "  Health:    http://localhost:8080/healthz" -ForegroundColor White
Write-Host "  Vault API: http://localhost:8080/rpc/vault" -ForegroundColor White  
Write-Host "  Bridge API:http://localhost:8080/rpc/bridge" -ForegroundColor White
Write-Host "  WebSocket: ws://localhost:8080" -ForegroundColor White
Write-Host ""
Write-Host "🔑 STAGING CREDENTIALS:" -ForegroundColor Cyan
Write-Host "  Token: staging-vault-token-v3-2025-secure" -ForegroundColor White
Write-Host ""
Write-Host "📊 Starting server..." -ForegroundColor Yellow

# Start the server
pnpm dev
