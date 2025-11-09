# ?? TESTE COMPLETO DA API AZURE - Barbara E-commerce

param(
    [string]$BaseUrl = "https://barbara-api.azurewebsites.net"
)

$ErrorActionPreference = "Continue"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  TESTE DA API AZURE" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "URL Base: $BaseUrl" -ForegroundColor Gray
Write-Host ""

# Função helper para fazer requests
function Invoke-ApiTest {
    param(
        [string]$Name,
        [string]$Method,
      [string]$Endpoint,
        [object]$Body = $null
    )
    
    Write-Host "[ $Name ]" -ForegroundColor Yellow
    
    try {
        $uri = "$BaseUrl$Endpoint"
  $params = @{
      Uri = $uri
 Method = $Method
            ContentType = "application/json"
            TimeoutSec = 30
        }
    
   if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
 }

        $response = Invoke-RestMethod @params
        Write-Host "  ? Sucesso!" -ForegroundColor Green
        
  if ($response) {
            $json = $response | ConvertTo-Json -Depth 3
       Write-Host "  Resposta:" -ForegroundColor Gray
  Write-Host $json -ForegroundColor DarkGray
  }
   
  return $response
    }
    catch {
        Write-Host "  ? Erro: $($_.Exception.Message)" -ForegroundColor Red
  if ($_.ErrorDetails.Message) {
            Write-Host "  Detalhes: $($_.ErrorDetails.Message)" -ForegroundColor DarkRed
        }
        return $null
    }
    
    Write-Host ""
}

# 1. Verificar se API está online
Write-Host "[ 1. Health Check ]" -ForegroundColor Yellow
try {
    $health = Invoke-WebRequest -Uri "$BaseUrl/swagger/index.html" -UseBasicParsing -TimeoutSec 10
    if ($health.StatusCode -eq 200) {
        Write-Host "  ? API está online!" -ForegroundColor Green
    }
}
catch {
    Write-Host "  ? API não está acessível" -ForegroundColor Red
    Write-Host "  Certifique-se de que o deploy foi concluído" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# 2. Testar Categorias
$categoria = Invoke-ApiTest -Name "2. Criar Categoria" -Method POST -Endpoint "/api/categorias" -Body @{
    nome = "Vestidos"
    descricao = "Vestidos femininos elegantes"
    ativa = $true
}

Start-Sleep -Seconds 1

$categorias = Invoke-ApiTest -Name "3. Listar Categorias" -Method GET -Endpoint "/api/categorias"

if ($categoria) {
    $categoriaId = $categoria.id
 
    Start-Sleep -Seconds 1
    
    Invoke-ApiTest -Name "4. Buscar Categoria por ID" -Method GET -Endpoint "/api/categorias/$categoriaId"
    
Start-Sleep -Seconds 1
    
    Invoke-ApiTest -Name "5. Atualizar Categoria" -Method PUT -Endpoint "/api/categorias/$categoriaId" -Body @{
        id = $categoriaId
        nome = "Vestidos Premium"
    descricao = "Vestidos femininos de alta qualidade"
        ativa = $true
    }
}

# 6. Testar Clientes
Start-Sleep -Seconds 1

$cliente = Invoke-ApiTest -Name "6. Criar Cliente" -Method POST -Endpoint "/api/clientes" -Body @{
    nome = "Maria Silva"
    email = "maria.silva@email.com"
    telefone = "(11) 98765-4321"
    cpf = "123.456.789-00"
    dataNascimento = "1990-05-15"
    endereco = @{
        logradouro = "Rua das Flores"
        numero = "123"
     complemento = "Apto 45"
      bairro = "Centro"
        cidade = "São Paulo"
        estado = "SP"
    cep = "01234-567"
    }
}

Start-Sleep -Seconds 1

$clientes = Invoke-ApiTest -Name "7. Listar Clientes" -Method GET -Endpoint "/api/clientes"

# 8. Testar Produtos
if ($categoria) {
    Start-Sleep -Seconds 1
    
    $produto = Invoke-ApiTest -Name "8. Criar Produto" -Method POST -Endpoint "/api/produtos" -Body @{
        nome = "Vestido Floral"
        descricao = "Vestido floral elegante"
   sku = "VEST-001"
        preco = 299.90
        categoriaId = $categoriaId
  estoque = 10
        ativo = $true
        destaque = $true
        tamanhos = @("P", "M", "G")
        cores = @("Azul", "Rosa")
    }
    
    Start-Sleep -Seconds 1
    
    $produtos = Invoke-ApiTest -Name "9. Listar Produtos" -Method GET -Endpoint "/api/produtos"
    
    if ($produto) {
      Start-Sleep -Seconds 1
        
        Invoke-ApiTest -Name "10. Buscar Produto por ID" -Method GET -Endpoint "/api/produtos/$($produto.id)"
        
        Start-Sleep -Seconds 1
    
      Invoke-ApiTest -Name "11. Produtos em Destaque" -Method GET -Endpoint "/api/produtos/destaques"
    
        Start-Sleep -Seconds 1
        
        Invoke-ApiTest -Name "12. Produtos por Categoria" -Method GET -Endpoint "/api/produtos/categoria/$categoriaId"
    }
}

# 13. Testar Pedidos
if ($cliente -and $produto) {
    Start-Sleep -Seconds 1
    
    $pedido = Invoke-ApiTest -Name "13. Criar Pedido" -Method POST -Endpoint "/api/pedidos" -Body @{
        clienteId = $cliente.id
        itens = @(
  @{
    produtoId = $produto.id
       quantidade = 2
    precoUnitario = $produto.preco
          tamanho = "M"
     cor = "Azul"
    }
 )
        enderecoEntrega = @{
        logradouro = "Rua das Flores"
            numero = "123"
       complemento = "Apto 45"
         bairro = "Centro"
   cidade = "São Paulo"
            estado = "SP"
        cep = "01234-567"
        }
    }

    Start-Sleep -Seconds 1
    
    $pedidos = Invoke-ApiTest -Name "14. Listar Pedidos" -Method GET -Endpoint "/api/pedidos"
    
    if ($pedido) {
        Start-Sleep -Seconds 1
        
      Invoke-ApiTest -Name "15. Buscar Pedido por ID" -Method GET -Endpoint "/api/pedidos/$($pedido.id)"
        
     Start-Sleep -Seconds 1
        
        Invoke-ApiTest -Name "16. Pedidos por Cliente" -Method GET -Endpoint "/api/pedidos/cliente/$($cliente.id)"
    }
}

# Resumo
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  TESTE CONCLUÍDO!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Acesse o Swagger para mais testes:" -ForegroundColor Yellow
Write-Host "  $BaseUrl/swagger" -ForegroundColor White
Write-Host ""
