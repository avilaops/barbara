# ?? DEPLOY AZURE - Barbara E-commerce
# Deploy completo da API no Azure App Service

param(
    [string]$ResourceGroup = "barbara-rg",
    [string]$Location = "eastus",
    [string]$AppServicePlan = "barbara-plan",
    [string]$WebAppName = "barbara-api",
    [string]$SqlServerName = "barbara-sql-server",
[string]$DatabaseName = "BarbaraDB",
    [string]$SqlAdminUser = "barbaraadmin",
    [string]$SqlAdminPassword = "Barbara@2025!Secure",
    [switch]$SkipMigrations
)

$ErrorActionPreference = "Stop"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  DEPLOY AZURE - Barbara E-commerce" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar Azure CLI
Write-Host "[ 1/11 ] Verificando Azure CLI..." -ForegroundColor Yellow
try {
    az version | Out-Null
    Write-Host "  ? Azure CLI instalado" -ForegroundColor Green
} catch {
    Write-Host "  ? Azure CLI não encontrado!" -ForegroundColor Red
    Write-Host "  Instale em: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
    exit 1
}

# 2. Login no Azure
Write-Host "`n[ 2/11 ] Fazendo login no Azure..." -ForegroundColor Yellow
$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Host "  Fazendo login..." -ForegroundColor Gray
    az login
    $account = az account show | ConvertFrom-Json
} else {
    Write-Host "  ? Já logado como: $($account.user.name)" -ForegroundColor Green
}

# 3. Criar Resource Group (se não existir)
Write-Host "`n[ 3/11 ] Verificando Resource Group..." -ForegroundColor Yellow
$rgExists = az group exists --name $ResourceGroup
if ($rgExists -eq "false") {
    Write-Host "  Criando Resource Group: $ResourceGroup" -ForegroundColor Gray
    az group create --name $ResourceGroup --location $Location | Out-Null
    Write-Host "  ? Resource Group criado" -ForegroundColor Green
} else {
  Write-Host "  ? Resource Group já existe" -ForegroundColor Green
}

# 4. Criar SQL Server
Write-Host "`n[ 4/11 ] Criando Azure SQL Server..." -ForegroundColor Yellow
$sqlServerExists = az sql server list --resource-group $ResourceGroup --query "[?name=='$SqlServerName']" | ConvertFrom-Json
if (-not $sqlServerExists) {
    Write-Host "  Criando SQL Server: $SqlServerName" -ForegroundColor Gray
    az sql server create `
        --resource-group $ResourceGroup `
      --name $SqlServerName `
        --location $Location `
        --admin-user $SqlAdminUser `
      --admin-password $SqlAdminPassword | Out-Null
    
    Write-Host "  ? SQL Server criado" -ForegroundColor Green
} else {
    Write-Host "  ? SQL Server já existe" -ForegroundColor Green
}

# 5. Configurar Firewall SQL
Write-Host "`n[ 5/11 ] Configurando Firewall SQL..." -ForegroundColor Yellow

# Permitir serviços Azure
Write-Host "  Permitindo serviços Azure..." -ForegroundColor Gray
az sql server firewall-rule create `
    --resource-group $ResourceGroup `
    --server $SqlServerName `
    --name AllowAzureServices `
    --start-ip-address 0.0.0.0 `
    --end-ip-address 0.0.0.0 2>$null | Out-Null

# Adicionar IP local
Write-Host "  Obtendo seu IP público..." -ForegroundColor Gray
$myIp = (Invoke-RestMethod -Uri "https://api.ipify.org").Trim()
Write-Host "  Seu IP: $myIp" -ForegroundColor Gray

az sql server firewall-rule create `
    --resource-group $ResourceGroup `
    --server $SqlServerName `
    --name ClientIP `
    --start-ip-address $myIp `
    --end-ip-address $myIp 2>$null | Out-Null

Write-Host "  ? Firewall configurado" -ForegroundColor Green

# 6. Criar Database
Write-Host "`n[ 6/11 ] Criando Azure SQL Database..." -ForegroundColor Yellow
$dbExists = az sql db list --resource-group $ResourceGroup --server $SqlServerName --query "[?name=='$DatabaseName']" | ConvertFrom-Json
if (-not $dbExists) {
    Write-Host "  Criando Database: $DatabaseName (pode levar ~3 min)" -ForegroundColor Gray
    az sql db create `
        --resource-group $ResourceGroup `
        --server $SqlServerName `
        --name $DatabaseName `
        --service-objective Basic `
        --backup-storage-redundancy Local | Out-Null
    
    Write-Host "  ? Database criado" -ForegroundColor Green
} else {
  Write-Host "  ? Database já existe" -ForegroundColor Green
}

# 7. Criar App Service Plan
Write-Host "`n[ 7/11 ] Criando App Service Plan..." -ForegroundColor Yellow
$planExists = az appservice plan list --resource-group $ResourceGroup --query "[?name=='$AppServicePlan']" | ConvertFrom-Json
if (-not $planExists) {
    Write-Host "  Criando App Service Plan: $AppServicePlan" -ForegroundColor Gray
    az appservice plan create `
        --resource-group $ResourceGroup `
   --name $AppServicePlan `
      --location $Location `
  --sku B1 `
        --is-linux | Out-Null

    Write-Host "  ? App Service Plan criado" -ForegroundColor Green
} else {
    Write-Host "  ? App Service Plan já existe" -ForegroundColor Green
}

# 8. Criar Web App
Write-Host "`n[ 8/11 ] Criando Web App..." -ForegroundColor Yellow
$webAppExists = az webapp list --resource-group $ResourceGroup --query "[?name=='$WebAppName']" | ConvertFrom-Json
if (-not $webAppExists) {
    Write-Host "  Criando Web App: $WebAppName" -ForegroundColor Gray
    az webapp create `
        --resource-group $ResourceGroup `
        --plan $AppServicePlan `
    --name $WebAppName `
        --runtime "DOTNET|9.0" | Out-Null
    
    Write-Host "  ? Web App criado" -ForegroundColor Green
} else {
    Write-Host "  ? Web App já existe" -ForegroundColor Green
}

# 9. Configurar Connection String
Write-Host "`n[ 9/11 ] Configurando Connection String..." -ForegroundColor Yellow
$connectionString = "Server=tcp:$SqlServerName.database.windows.net,1433;Database=$DatabaseName;User Id=$SqlAdminUser;Password=$SqlAdminPassword;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

az webapp config connection-string set `
    --resource-group $ResourceGroup `
    --name $WebAppName `
    --connection-string-type SQLAzure `
    --settings DefaultConnection="$connectionString" | Out-Null

Write-Host "  ? Connection String configurada" -ForegroundColor Green

# 10. Publicar aplicação
Write-Host "`n[ 10/11 ] Publicando aplicação..." -ForegroundColor Yellow
Write-Host "  Compilando projeto..." -ForegroundColor Gray

$apiPath = "src/Barbara.API"
if (-not (Test-Path $apiPath)) {
    Write-Host "  ? Projeto não encontrado em: $apiPath" -ForegroundColor Red
    exit 1
}

Push-Location $apiPath

try {
    dotnet publish -c Release -o ./publish --nologo -v q
    
    Write-Host "  Criando pacote ZIP..." -ForegroundColor Gray
    if (Test-Path ./barbara-api.zip) {
      Remove-Item ./barbara-api.zip -Force
    }
Compress-Archive -Path ./publish/* -DestinationPath ./barbara-api.zip -Force
    
    Write-Host "  Fazendo upload para Azure (pode levar ~2 min)..." -ForegroundColor Gray
    az webapp deployment source config-zip `
        --resource-group $ResourceGroup `
    --name $WebAppName `
        --src ./barbara-api.zip | Out-Null
 
    # Limpar
    Remove-Item ./barbara-api.zip -Force
    Remove-Item ./publish -Recurse -Force
    
    Write-Host "  ? Aplicação publicada" -ForegroundColor Green
}
finally {
 Pop-Location
}

# 11. Aplicar Migrations
if (-not $SkipMigrations) {
    Write-Host "`n[ 11/11 ] Aplicando Migrations..." -ForegroundColor Yellow
    Write-Host "  Aguardando app iniciar (30s)..." -ForegroundColor Gray
    Start-Sleep -Seconds 30
    
    $infraPath = "src/Barbara.Infrastructure"
    if (Test-Path $infraPath) {
        try {
            Write-Host "  Executando migrations..." -ForegroundColor Gray
 Push-Location $infraPath
     
 dotnet ef database update `
--startup-project ../Barbara.API `
            --connection $connectionString `
        --no-build 2>&1 | Out-Null
            
   Pop-Location
  Write-Host "  ? Migrations aplicadas" -ForegroundColor Green
        }
        catch {
 Write-Host "  ? Erro ao aplicar migrations automaticamente" -ForegroundColor Yellow
            Write-Host "  Execute manualmente:" -ForegroundColor Yellow
            Write-Host "  cd $infraPath" -ForegroundColor Gray
            Write-Host "  dotnet ef database update --startup-project ../Barbara.API --connection `"$connectionString`"" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "`n[ 11/11 ] Migrations puladas (use -SkipMigrations `$false para aplicar)" -ForegroundColor Yellow
}

# Validar Deploy
Write-Host "`n[ Validando ] Testando API..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

$apiUrl = "https://$WebAppName.azurewebsites.net"
try {
    $response = Invoke-WebRequest -Uri "$apiUrl/swagger/index.html" -UseBasicParsing -TimeoutSec 30
    if ($response.StatusCode -eq 200) {
        Write-Host "  ? API está respondendo!" -ForegroundColor Green
    }
}
catch {
    Write-Host "  ? API ainda não está acessível (pode levar alguns minutos)" -ForegroundColor Yellow
}

# Resumo
Write-Host "`n============================================" -ForegroundColor Green
Write-Host "  DEPLOY CONCLUÍDO! ??" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "URLs:" -ForegroundColor Cyan
Write-Host "  API:     $apiUrl" -ForegroundColor White
Write-Host "  Swagger: $apiUrl/swagger" -ForegroundColor White
Write-Host ""
Write-Host "Recursos Criados:" -ForegroundColor Cyan
Write-Host "  Resource Group: $ResourceGroup" -ForegroundColor White
Write-Host "  SQL Server:     $SqlServerName.database.windows.net" -ForegroundColor White
Write-Host "  Database:       $DatabaseName" -ForegroundColor White
Write-Host "  App Service:    $WebAppName" -ForegroundColor White
Write-Host ""
Write-Host "Credenciais SQL:" -ForegroundColor Cyan
Write-Host "  Usuário: $SqlAdminUser" -ForegroundColor White
Write-Host "  Senha:   $SqlAdminPassword" -ForegroundColor White
Write-Host ""
Write-Host "Teste rápido:" -ForegroundColor Yellow
Write-Host "  Invoke-RestMethod -Uri '$apiUrl/api/categorias' -Method GET" -ForegroundColor Gray
Write-Host ""
Write-Host "Próximos passos:" -ForegroundColor Yellow
Write-Host "  1. Acesse: $apiUrl/swagger" -ForegroundColor White
Write-Host "  2. Teste os endpoints" -ForegroundColor White
Write-Host "  3. Configure domínio customizado (opcional)" -ForegroundColor White
Write-Host "  4. Configure CI/CD com GitHub Actions" -ForegroundColor White
Write-Host ""
