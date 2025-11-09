# ?? Setup Automático - Barbara E-commerce

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Barbara E-commerce - Setup Automático" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar pré-requisitos
Write-Host "[ 1/5 ] Verificando pré-requisitos..." -ForegroundColor Yellow

# Verificar .NET
try {
    $dotnetVersion = dotnet --version
    Write-Host "  ? .NET SDK encontrado: v$dotnetVersion" -ForegroundColor Green
} catch {
    Write-Host "  ? .NET 9 SDK não encontrado!" -ForegroundColor Red
    Write-Host "    Instale em: https://dotnet.microsoft.com/download" -ForegroundColor Yellow
    exit 1
}

# Verificar SQL Server
Write-Host "  Verificando SQL Server..." -ForegroundColor Gray
$sqlService = Get-Service -Name "MSSQLSERVER" -ErrorAction SilentlyContinue
if ($sqlService -and $sqlService.Status -eq "Running") {
    Write-Host "  ? SQL Server rodando" -ForegroundColor Green
} else {
    Write-Host "  ? SQL Server não encontrado ou parado" -ForegroundColor Yellow
 Write-Host "  Certifique-se que o SQL Server está instalado e rodando" -ForegroundColor Gray
}

Write-Host ""

# 2. Restaurar pacotes
Write-Host "[ 2/5 ] Restaurando pacotes NuGet..." -ForegroundColor Yellow
dotnet restore Barbara.sln
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ? Erro ao restaurar pacotes!" -ForegroundColor Red
    exit 1
}
Write-Host "? Pacotes restaurados" -ForegroundColor Green
Write-Host ""

# 3. Compilar solução
Write-Host "[ 3/5 ] Compilando solução..." -ForegroundColor Yellow
dotnet build Barbara.sln --no-restore
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ? Erro na compilação!" -ForegroundColor Red
    exit 1
}
Write-Host "  ? Compilação bem-sucedida" -ForegroundColor Green
Write-Host ""

# 4. Criar banco de dados
Write-Host "[ 4/5 ] Criando banco de dados..." -ForegroundColor Yellow
Write-Host "  Criando migrations..." -ForegroundColor Gray

Set-Location "src/Barbara.Infrastructure"

# Verificar se migration já existe
$migrationExists = dotnet ef migrations list --startup-project ../Barbara.API --no-build 2>&1 | Select-String "InitialCreate"

if (-not $migrationExists) {
    Write-Host "  Gerando migration inicial..." -ForegroundColor Gray
    dotnet ef migrations add InitialCreate --startup-project ../Barbara.API --no-build
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ? Erro ao criar migration!" -ForegroundColor Red
        Set-Location "../.."
        exit 1
    }
}

Write-Host "  Aplicando migrations no banco..." -ForegroundColor Gray
dotnet ef database update --startup-project ../Barbara.API --no-build
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ? Erro ao criar banco de dados!" -ForegroundColor Red
    Write-Host "    Verifique se o SQL Server está rodando" -ForegroundColor Yellow
    Write-Host "    Connection string: src/Barbara.API/appsettings.json" -ForegroundColor Yellow
    Set-Location "../.."
    exit 1
}

Set-Location "../.."
Write-Host "  ? Banco de dados criado: BarbaraDB_Dev" -ForegroundColor Green
Write-Host ""

# 5. Executar testes (se existirem)
if (Test-Path "tests") {
    Write-Host "[ 5/5 ] Executando testes..." -ForegroundColor Yellow
    dotnet test --no-build --verbosity quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ? Todos os testes passaram" -ForegroundColor Green
    } else {
        Write-Host "  ? Alguns testes falharam" -ForegroundColor Yellow
    }
} else {
    Write-Host "[ 5/5 ] Testes não encontrados (OK)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  ? Setup concluído com sucesso!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

Write-Host "Próximos passos:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Rodar a API:" -ForegroundColor White
Write-Host "     cd src/Barbara.API" -ForegroundColor Gray
Write-Host "     dotnet run" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Acessar Swagger:" -ForegroundColor White
Write-Host "     https://localhost:7001/swagger" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Próxima etapa:" -ForegroundColor White
Write-Host " Seguir GUIA-IMPLEMENTACAO-SEMANA1.md" -ForegroundColor Gray
Write-Host ""

Write-Host "Documentação completa:" -ForegroundColor Cyan
Write-Host "  - README-BARBARA.md" -ForegroundColor Gray
Write-Host "  - ROADMAP.md" -ForegroundColor Gray
Write-Host "  - ARQUITETURA.md" -ForegroundColor Gray
Write-Host "  - GUIA-IMPLEMENTACAO-SEMANA1.md" -ForegroundColor Gray
Write-Host ""
