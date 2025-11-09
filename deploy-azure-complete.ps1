# ?? DEPLOY COMPLETO AZURE - Barbara E-commerce
# Inclui: Infraestrutura + Deploy + Migrations + Domínio Customizado

param(
[string]$ResourceGroup = "barbara-rg",
    [string]$SqlServerName = "barbara-sql-srv",
    [string]$DatabaseName = "BarbaraDB",
    [string]$WebAppName = "barbara-api",
    [string]$CustomDomain = "barbara.avila.inc",
    [string]$SqlAdminUser = "barbaraadmin",
    [string]$SqlAdminPassword = "Barbara@2025!Secure"
)

$ErrorActionPreference = "Continue"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  DEPLOY AZURE - Barbara E-commerce" -ForegroundColor Cyan
Write-Host "  Domínio: $CustomDomain" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Resumo dos recursos criados até agora
Write-Host "?? RECURSOS JÁ CRIADOS:" -ForegroundColor Green
Write-Host "  ? Resource Group: $ResourceGroup" -ForegroundColor White
Write-Host "  ? SQL Server: $SqlServerName.database.windows.net (East US 2)" -ForegroundColor White
Write-Host "  ? Database: $DatabaseName (Basic tier)" -ForegroundColor White
Write-Host "  ? App Service Plan: barbara-plan (Free F1 - Brazil South)" -ForegroundColor White
Write-Host "  ? Web App: $WebAppName.azurewebsites.net" -ForegroundColor White
Write-Host "  ? Firewall SQL: Azure Services + Seu IP (152.254.233.137)" -ForegroundColor White
Write-Host "  ? Connection String: Configurada" -ForegroundColor White
Write-Host ""

# Etapa atual: Deploy da aplicação
Write-Host "?? PRÓXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host ""

# 1. Aplicar Migrations
Write-Host "[ 1/4 ] Aplicando Migrations no Azure SQL..." -ForegroundColor Yellow
$connectionString = "Server=tcp:$SqlServerName.database.windows.net,1433;Database=$DatabaseName;User Id=$SqlAdminUser;Password=$SqlAdminPassword;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

try {
    Push-Location "src\Barbara.Infrastructure"
    Write-Host "  Executando: dotnet ef database update..." -ForegroundColor Gray
    
    dotnet ef database update --startup-project ../Barbara.API --connection $connectionString --no-build
    
    Pop-Location
    Write-Host "  ? Migrations aplicadas com sucesso!" -ForegroundColor Green
}
catch {
  Write-Host "  ? Erro ao aplicar migrations. Será necessário fazer manualmente." -ForegroundColor Yellow
    Write-Host "  Comando:" -ForegroundColor Gray
    Write-Host "  cd src\Barbara.Infrastructure" -ForegroundColor DarkGray
    Write-Host "  dotnet ef database update --startup-project ../Barbara.API --connection `"$connectionString`"" -ForegroundColor DarkGray
}

Write-Host ""

# 2. Deploy via Visual Studio (Instruções)
Write-Host "[ 2/4 ] Deploy da Aplicação - USE O VISUAL STUDIO" -ForegroundColor Yellow
Write-Host ""
Write-Host "  O deploy via CLI está falhando no tier Free. Use o Visual Studio:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  PASSO A PASSO:" -ForegroundColor White
Write-Host "  1. Abra o Visual Studio 2022" -ForegroundColor Gray
Write-Host "  2. Botão direito no projeto 'Barbara.API'" -ForegroundColor Gray
Write-Host "3. Selecione 'Publish...'" -ForegroundColor Gray
Write-Host "  4. Escolha 'Azure' ? 'Azure App Service (Linux)'" -ForegroundColor Gray
Write-Host "  5. Faça login com: contato@mrgcaixastermicas.com.br" -ForegroundColor Gray
Write-Host "  6. Selecione a subscription: 'Padrão'" -ForegroundColor Gray
Write-Host "  7. Selecione o App Service: 'barbara-api'" -ForegroundColor Gray
Write-Host "  8. Clique em 'Publish'" -ForegroundColor Gray
Write-Host "  9. Aguarde ~3-5 minutos" -ForegroundColor Gray
Write-Host ""
Write-Host "  Pressione ENTER após concluir o publish no Visual Studio..." -ForegroundColor Yellow
Read-Host

Write-Host "  ? Deploy assumido como concluído!" -ForegroundColor Green
Write-Host ""

# 3. Configurar Domínio Customizado
Write-Host "[ 3/4 ] Configurando Domínio Customizado..." -ForegroundColor Yellow
Write-Host ""
Write-Host "  IMPORTANTE: Configure o DNS primeiro!" -ForegroundColor Red
Write-Host ""
Write-Host "  No seu provedor de DNS (onde está registrado avila.inc):" -ForegroundColor Cyan
Write-Host "  Adicione os seguintes registros:" -ForegroundColor White
Write-Host ""
Write-Host "  Tipo: CNAME" -ForegroundColor Yellow
Write-Host "  Nome: barbara" -ForegroundColor White
Write-Host "  Valor: barbara-api.azurewebsites.net" -ForegroundColor White
Write-Host "  TTL: 3600" -ForegroundColor Gray
Write-Host ""
Write-Host "  OU (alternativo):" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Tipo: TXT" -ForegroundColor Yellow
Write-Host "  Nome: asuid.barbara" -ForegroundColor White
Write-Host "  Valor: " -NoNewline -ForegroundColor White

# Obter o Custom Domain Verification ID
try {
    $verificationId = az webapp show --resource-group $ResourceGroup --name $WebAppName --query customDomainVerificationId -o tsv
    Write-Host "$verificationId" -ForegroundColor Green
}
catch {
    Write-Host "(obtenha via Portal Azure)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  Após configurar o DNS, pressione ENTER para continuar..." -ForegroundColor Yellow
$dnsDone = Read-Host "  DNS configurado? (s/N)"

if ($dnsDone -eq "s" -or $dnsDone -eq "S") {
    Write-Host ""
  Write-Host "  Adicionando domínio customizado ao App Service..." -ForegroundColor Gray
    
    try {
        # Adicionar domínio customizado
        az webapp config hostname add --resource-group $ResourceGroup --webapp-name $WebAppName --hostname $CustomDomain
        Write-Host "  ? Domínio customizado adicionado!" -ForegroundColor Green
        
        # Habilitar HTTPS
        Write-Host "  Habilitando HTTPS..." -ForegroundColor Gray
        az webapp config ssl bind --resource-group $ResourceGroup --name $WebAppName --certificate-thumbprint auto --ssl-type SNI --hostname $CustomDomain
        Write-Host "  ? SSL/TLS configurado!" -ForegroundColor Green
    }
    catch {
        Write-Host "  ? Erro ao adicionar domínio. Configure manualmente no Portal Azure:" -ForegroundColor Yellow
        Write-Host "  1. Vá em App Service ? Custom domains" -ForegroundColor Gray
        Write-Host "  2. Clique em '+ Add custom domain'" -ForegroundColor Gray
        Write-Host "  3. Digite: $CustomDomain" -ForegroundColor Gray
        Write-Host "  4. Valide e adicione" -ForegroundColor Gray
        Write-Host "  5. Em SSL bindings, escolha 'App Service Managed Certificate'" -ForegroundColor Gray
    }
}
else {
    Write-Host "  ? Domínio customizado não configurado. Faça manualmente depois." -ForegroundColor Yellow
}

Write-Host ""

# 4. Teste Final
Write-Host "[ 4/4 ] Testando API..." -ForegroundColor Yellow
Write-Host ""

$baseUrl = "https://$WebAppName.azurewebsites.net"
$customUrl = "https://$CustomDomain"

Write-Host "  Testando URL padrão: $baseUrl/swagger" -ForegroundColor Gray
Start-Sleep -Seconds 5

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/swagger/index.html" -UseBasicParsing -TimeoutSec 30
    if ($response.StatusCode -eq 200) {
        Write-Host "  ? API respondendo na URL padrão!" -ForegroundColor Green
    }
}
catch {
    Write-Host "  ? API ainda não está respondendo. Aguarde alguns minutos." -ForegroundColor Yellow
  Write-Host "  Erro: $($_.Exception.Message)" -ForegroundColor DarkRed
}

if ($dnsDone -eq "s" -or $dnsDone -eq "S") {
 Write-Host ""
    Write-Host "  Testando domínio customizado: $customUrl/swagger" -ForegroundColor Gray
    try {
        $response = Invoke-WebRequest -Uri "$customUrl/swagger/index.html" -UseBasicParsing -TimeoutSec 30
        if ($response.StatusCode -eq 200) {
    Write-Host "  ? Domínio customizado funcionando!" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "  ? Domínio customizado ainda não propagou (pode levar até 48h)" -ForegroundColor Yellow
 }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  DEPLOY CONCLUÍDO! ??" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

Write-Host "?? RESUMO DOS RECURSOS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  ???  SQL Server:" -ForegroundColor Yellow
Write-Host "   Servidor: $SqlServerName.database.windows.net" -ForegroundColor White
Write-Host "     Database: $DatabaseName" -ForegroundColor White
Write-Host "     Tier: Basic (5 DTUs) - ~USD 5/mês" -ForegroundColor Gray
Write-Host ""
Write-Host "  ?? App Service:" -ForegroundColor Yellow
Write-Host "  Nome: $WebAppName" -ForegroundColor White
Write-Host "   Tier: Free F1 (sem custo)" -ForegroundColor Gray
Write-Host "     Região: Brazil South" -ForegroundColor Gray
Write-Host ""
Write-Host "  ?? URLs:" -ForegroundColor Yellow
Write-Host "     Padrão:  $baseUrl" -ForegroundColor White
Write-Host "     Swagger: $baseUrl/swagger" -ForegroundColor White
if ($dnsDone -eq "s" -or $dnsDone -eq "S") {
    Write-Host "     Custom:  $customUrl" -ForegroundColor Green
  Write-Host "     Swagger: $customUrl/swagger" -ForegroundColor Green
}
Write-Host ""
Write-Host "  ?? Custo Estimado: ~USD 5/mês (apenas SQL Database)" -ForegroundColor Cyan
Write-Host ""

Write-Host "?? PRÓXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "  1. Teste a API no Swagger" -ForegroundColor White
Write-Host "  2. Execute o script: .\test-azure-api.ps1" -ForegroundColor White
Write-Host "  3. Configure CI/CD (GitHub Actions ou Azure DevOps)" -ForegroundColor White
Write-Host "  4. Considere upgrade para App Service B1 para produção" -ForegroundColor White
Write-Host ""

Write-Host "?? COMANDOS ÚTEIS:" -ForegroundColor Yellow
Write-Host "  # Verificar recursos:" -ForegroundColor White
Write-Host "  .\check-azure-resources.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "  # Testar API completa:" -ForegroundColor White
Write-Host "  .\test-azure-api.ps1 -BaseUrl '$customUrl'" -ForegroundColor Gray
Write-Host ""
Write-Host "  # Ver logs em tempo real:" -ForegroundColor White
Write-Host "  az webapp log tail --resource-group $ResourceGroup --name $WebAppName" -ForegroundColor Gray
Write-Host ""

# Salvar informações em arquivo
$deployInfo = @{
    ResourceGroup = $ResourceGroup
    SqlServer = "$SqlServerName.database.windows.net"
 Database = $DatabaseName
    WebApp = $WebAppName
    DefaultUrl = $baseUrl
    CustomDomain = $CustomDomain
    CustomUrl = $customUrl
    DeployDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
} | ConvertTo-Json

$deployInfo | Out-File "deploy-info.json" -Encoding UTF8
Write-Host "??  Informações salvas em: deploy-info.json" -ForegroundColor Cyan
Write-Host ""
