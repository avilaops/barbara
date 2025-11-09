# ?? VERIFICAR RECURSOS AZURE - Barbara E-commerce

param(
    [string]$ResourceGroup = "barbara-rg",
    [string]$SqlServerName = "barbara-sql-server",
[string]$DatabaseName = "BarbaraDB",
    [string]$WebAppName = "barbara-api"
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  VERIFICAÇÃO DE RECURSOS AZURE" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Verificar login
Write-Host "[ Azure Account ]" -ForegroundColor Yellow
try {
    $account = az account show | ConvertFrom-Json
    Write-Host "  ? Logado como: $($account.user.name)" -ForegroundColor Green
    Write-Host "  ? Subscription: $($account.name)" -ForegroundColor Green
}
catch {
    Write-Host "? Não logado. Execute: az login" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Verificar Resource Group
Write-Host "[ Resource Group ]" -ForegroundColor Yellow
$rgExists = az group exists --name $ResourceGroup
if ($rgExists -eq "true") {
  Write-Host "  ? $ResourceGroup existe" -ForegroundColor Green
    $rg = az group show --name $ResourceGroup | ConvertFrom-Json
    Write-Host "    Location: $($rg.location)" -ForegroundColor Gray
} else {
    Write-Host "  ? $ResourceGroup NÃO existe" -ForegroundColor Red
}

Write-Host ""

# Verificar SQL Server
Write-Host "[ SQL Server ]" -ForegroundColor Yellow
$sqlServer = az sql server list --resource-group $ResourceGroup --query "[?name=='$SqlServerName']" | ConvertFrom-Json
if ($sqlServer) {
  Write-Host "  ? $SqlServerName existe" -ForegroundColor Green
    Write-Host "    FQDN: $($sqlServer[0].fullyQualifiedDomainName)" -ForegroundColor Gray
    
    # Verificar firewall rules
    $firewallRules = az sql server firewall-rule list --resource-group $ResourceGroup --server $SqlServerName | ConvertFrom-Json
    Write-Host "    Firewall Rules: $($firewallRules.Count)" -ForegroundColor Gray
  foreach ($rule in $firewallRules) {
        Write-Host "      - $($rule.name): $($rule.startIpAddress) - $($rule.endIpAddress)" -ForegroundColor DarkGray
    }
} else {
  Write-Host "  ? $SqlServerName NÃO existe" -ForegroundColor Red
}

Write-Host ""

# Verificar Database
Write-Host "[ SQL Database ]" -ForegroundColor Yellow
if ($sqlServer) {
    $database = az sql db list --resource-group $ResourceGroup --server $SqlServerName --query "[?name=='$DatabaseName']" | ConvertFrom-Json
    if ($database) {
        Write-Host "  ? $DatabaseName existe" -ForegroundColor Green
Write-Host "    Tier: $($database[0].sku.tier)" -ForegroundColor Gray
        Write-Host "    Status: $($database[0].status)" -ForegroundColor Gray
    } else {
        Write-Host "  ? $DatabaseName NÃO existe" -ForegroundColor Red
    }
} else {
    Write-Host "  ? Pulado (SQL Server não existe)" -ForegroundColor Yellow
}

Write-Host ""

# Verificar App Service
Write-Host "[ App Service ]" -ForegroundColor Yellow
$webapp = az webapp list --resource-group $ResourceGroup --query "[?name=='$WebAppName']" | ConvertFrom-Json
if ($webapp) {
    Write-Host "  ? $WebAppName existe" -ForegroundColor Green
    Write-Host "    URL: https://$($webapp[0].defaultHostName)" -ForegroundColor Gray
    Write-Host "    Runtime: $($webapp[0].kind)" -ForegroundColor Gray
    Write-Host "    Estado: $($webapp[0].state)" -ForegroundColor Gray
    
    # Verificar connection strings
    $connStrings = az webapp config connection-string list --resource-group $ResourceGroup --name $WebAppName | ConvertFrom-Json
    if ($connStrings.PSObject.Properties.Name -contains 'DefaultConnection') {
        Write-Host "    ? Connection String configurada" -ForegroundColor Green
    } else {
     Write-Host "    ? Connection String NÃO configurada" -ForegroundColor Red
    }
} else {
    Write-Host "  ? $WebAppName NÃO existe" -ForegroundColor Red
}

Write-Host ""

# Testar API
if ($webapp -and $webapp[0].state -eq "Running") {
    Write-Host "[ Teste de API ]" -ForegroundColor Yellow
    $apiUrl = "https://$($webapp[0].defaultHostName)"
    
  try {
        Write-Host "  Testando $apiUrl..." -ForegroundColor Gray
        $response = Invoke-WebRequest -Uri "$apiUrl/swagger/index.html" -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
Write-Host "  ? Swagger acessível!" -ForegroundColor Green
        }
    }
    catch {
 Write-Host "  ? API não está acessível" -ForegroundColor Red
        Write-Host "    Erro: $($_.Exception.Message)" -ForegroundColor DarkRed
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  VERIFICAÇÃO CONCLUÍDA" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Resumo
$totalResources = 0
$createdResources = 0

if ($rgExists -eq "true") { $totalResources++; $createdResources++ }
if ($sqlServer) { $totalResources++; $createdResources++ }
if ($database) { $totalResources++; $createdResources++ }
if ($webapp) { $totalResources++; $createdResources++ }

$percentage = if ($totalResources -gt 0) { [math]::Round(($createdResources / 4) * 100) } else { 0 }

Write-Host "Progresso: $createdResources/4 recursos criados ($percentage%)" -ForegroundColor Cyan
Write-Host ""

if ($createdResources -eq 4) {
    Write-Host "? Todos os recursos estão criados!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximos passos:" -ForegroundColor Yellow
    Write-Host "  1. Aplicar migrations: .\deploy-azure.ps1" -ForegroundColor White
  Write-Host "  2. Testar API: https://$($webapp[0].defaultHostName)/swagger" -ForegroundColor White
} else {
    Write-Host "? Alguns recursos estão faltando" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Execute o deploy completo:" -ForegroundColor Yellow
    Write-Host "  .\deploy-azure.ps1" -ForegroundColor White
}
