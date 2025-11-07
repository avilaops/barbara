# Script de Deploy Barbara - Azure

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   Deploy Barbara - Azure Container Registry   " -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Erro: Docker nao encontrado!" -ForegroundColor Red
    Write-Host "Instale o Docker Desktop em: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Carregar variáveis do .env
if (Test-Path .env) {
    Get-Content .env | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]*)\s*=\s*(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
    Write-Host "Variaveis carregadas do .env" -ForegroundColor Green
}

$ACR_NAME = "shancrysacrdevhp7owg"
$ACR_USERNAME = $env:ACR_USERNAME
$ACR_PASSWORD = $env:ACR_PASSWORD
$IMAGE_NAME = "barbara-api"
$IMAGE_TAG = "latest"

Write-Host ""
Write-Host "Configuracao:" -ForegroundColor Cyan
Write-Host "  Registry: $ACR_NAME.azurecr.io" -ForegroundColor White
Write-Host "  Image: $IMAGE_NAME`:$IMAGE_TAG" -ForegroundColor White
Write-Host ""

# Login no ACR
Write-Host "1. Login no Azure Container Registry..." -ForegroundColor Yellow
docker login "$ACR_NAME.azurecr.io" --username $ACR_USERNAME --password $ACR_PASSWORD

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro no login do ACR!" -ForegroundColor Red
    exit 1
}

Write-Host "Login realizado com sucesso!" -ForegroundColor Green
Write-Host ""

# Build da imagem
Write-Host "2. Construindo imagem Docker..." -ForegroundColor Yellow
docker build -t "$ACR_NAME.azurecr.io/$IMAGE_NAME`:$IMAGE_TAG" ./api

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro ao construir imagem!" -ForegroundColor Red
    exit 1
}

Write-Host "Imagem construida com sucesso!" -ForegroundColor Green
Write-Host ""

# Push para ACR
Write-Host "3. Enviando imagem para Azure..." -ForegroundColor Yellow
docker push "$ACR_NAME.azurecr.io/$IMAGE_NAME`:$IMAGE_TAG"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro ao enviar imagem!" -ForegroundColor Red
    exit 1
}

Write-Host "Imagem enviada com sucesso!" -ForegroundColor Green
Write-Host ""

# Verificar imagens no ACR
Write-Host "4. Verificando imagens no registro..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Imagens disponiveis em: https://portal.azure.com" -ForegroundColor Cyan
Write-Host "Registry: $ACR_NAME.azurecr.io/$IMAGE_NAME`:$IMAGE_TAG" -ForegroundColor White
Write-Host ""

Write-Host "================================================" -ForegroundColor Green
Write-Host "          Deploy Concluido com Sucesso!        " -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Proximos passos:" -ForegroundColor Cyan
Write-Host "1. Acesse o Azure Portal" -ForegroundColor White
Write-Host "2. Crie ou atualize um Container App / Web App" -ForegroundColor White
Write-Host "3. Use a imagem: $ACR_NAME.azurecr.io/$IMAGE_NAME`:$IMAGE_TAG" -ForegroundColor White
Write-Host ""
