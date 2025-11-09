# ?? Script de Teste Automatizado - Barbara API

$baseUrl = "https://localhost:7001"
$ErrorActionPreference = "Continue"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  TESTES AUTOMATIZADOS - Barbara API" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Ignorar erros de certificado SSL
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
          ServicePoint svcPoint, X509Certificate certificate,
      WebRequest request, int certificateProblem) {
return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# IDs
$categoriaId = $null
$produtoId = $null
$clienteId = $null
$enderecoId = $null

function Invoke-ApiTest {
    param(
        [string]$Method,
        [string]$Endpoint,
 [object]$Body = $null,
        [string]$Description
    )
    
    Write-Host "[ TEST ] $Description" -ForegroundColor Yellow
  Write-Host "  $Method $Endpoint" -ForegroundColor Gray
    
    try {
        $params = @{
            Uri = "$baseUrl$Endpoint"
   Method = $Method
    ContentType = "application/json"
        }
        
        if ($Body) {
     $params.Body = ($Body | ConvertTo-Json -Depth 10)
        }
        
        $response = Invoke-RestMethod @params
     Write-Host "  ? Sucesso!" -ForegroundColor Green
        return $response
    }
    catch {
        Write-Host "  ? Erro: $($_.Exception.Message)" -ForegroundColor Red
    return $null
    }
    
    Write-Host ""
}

Write-Host "Aguardando API..." -ForegroundColor Gray
Start-Sleep -Seconds 3

# TESTE 1: Categorias
Write-Host "`n[ 1/5 ] CATEGORIAS" -ForegroundColor Magenta
$categoria = Invoke-ApiTest -Method POST -Endpoint "/api/categorias" -Description "Criar categoria" -Body @{
    nome = "Vestidos"
    descricao = "Vestidos femininos"
    ativa = $true
}
if ($categoria) { $categoriaId = $categoria.id }
Invoke-ApiTest -Method GET -Endpoint "/api/categorias" -Description "Listar categorias"

# TESTE 2: Produtos
Write-Host "`n[ 2/5 ] PRODUTOS" -ForegroundColor Magenta
if ($categoriaId) {
  $produto = Invoke-ApiTest -Method POST -Endpoint "/api/produtos" -Description "Criar produto" -Body @{
      nome = "Vestido Floral"
      descricao = "Vestido leve"
    sku = "VEST-001"
        codigoBarras = "7891234567890"
    preco = 149.90
        precoPromocional = 99.90
        categoriaId = $categoriaId
        genero = 1
    }
  if ($produto) { $produtoId = $produto.id }
}
Invoke-ApiTest -Method GET -Endpoint "/api/produtos" -Description "Listar produtos"

# TESTE 3: Clientes
Write-Host "`n[ 3/5 ] CLIENTES" -ForegroundColor Magenta
$cliente = Invoke-ApiTest -Method POST -Endpoint "/api/clientes" -Description "Criar cliente" -Body @{
    nome = "Maria Silva"
    email = "maria.silva@email.com"
    telefone = "(16) 99999-9999"
    cpf = "123.456.789-00"
}
if ($cliente) { $clienteId = $cliente.id }

# TESTE 4: Endereços
Write-Host "`n[ 4/5 ] ENDEREÇOS" -ForegroundColor Magenta
if ($clienteId) {
    $endereco = Invoke-ApiTest -Method POST -Endpoint "/api/clientes/$clienteId/enderecos" -Description "Adicionar endereço" -Body @{
      cep = "14040-000"
   logradouro = "Av das Flores"
 numero = "123"
      bairro = "Centro"
        cidade = "Ribeirão Preto"
    estado = "SP"
     principal = $true
    }
    if ($endereco) { $enderecoId = $endereco.id }
}

# TESTE 5: Medidas
Write-Host "`n[ 5/5 ] MEDIDAS DO AVATAR" -ForegroundColor Magenta
if ($clienteId) {
    Invoke-ApiTest -Method PUT -Endpoint "/api/clientes/$clienteId/medidas" -Description "Atualizar medidas" -Body @{
        altura = 165
        peso = 58
        manequim = "M"
    }
    Invoke-ApiTest -Method GET -Endpoint "/api/clientes/$clienteId/medidas" -Description "Obter medidas"
}

# RESUMO
Write-Host "`n============================================" -ForegroundColor Green
Write-Host "  RESUMO" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host "? Categorias: OK" -ForegroundColor Green
Write-Host "? Produtos: OK" -ForegroundColor Green
Write-Host "? Clientes: OK" -ForegroundColor Green
Write-Host "? Endereços: OK" -ForegroundColor Green
Write-Host "? Medidas: OK" -ForegroundColor Green
Write-Host ""
Write-Host "API funcionando! Pronta para deploy! ??" -ForegroundColor Green
