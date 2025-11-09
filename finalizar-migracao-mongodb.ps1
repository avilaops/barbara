# ?? FINALIZAR MIGRAÇÃO MONGODB - Script Automatizado

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  FINALIZAR MIGRAÇÃO MONGODB" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 1. Atualizar entidades restantes com atributos MongoDB
Write-Host "[ 1/5 ] Atualizando entidades com atributos MongoDB..." -ForegroundColor Yellow

$entidades = @(
    "Categoria",
    "Produto",
    "Pedido",
    "ItemPedido",
    "Pagamento",
    "NotaFiscal",
    "Envio",
    "Configuracao",
    "ImagemProduto",
    "EstoqueProduto"
)

foreach ($entidade in $entidades) {
    $arquivo = "src\Barbara.Domain\Entities\$entidade.cs"
    
    if (Test-Path $arquivo) {
  $conteudo = Get-Content $arquivo -Raw
        
   # Já tem MongoDB attributes?
        if ($conteudo -notmatch "using MongoDB.Bson") {
          Write-Host "  Pulando $entidade.cs (precisa ser atualizado manualmente)" -ForegroundColor Gray
  }
        else {
Write-Host "  ? $entidade.cs já atualizado" -ForegroundColor Green
        }
  }
}

Write-Host ""

# 2. Atualizar PedidosController e CarrinhoController
Write-Host "[ 2/5 ] Simplificando controllers restantes..." -ForegroundColor Yellow

# Backup dos controllers antigos
$controllers = @("PedidosController.cs", "CarrinhoController.cs")

foreach ($controller in $controllers) {
    $path = "src\Barbara.API\Controllers\$controller"
    if (Test-Path $path) {
        $backup = "$path.old"
        if (-not (Test-Path $backup)) {
      Copy-Item $path $backup
     Write-Host "  Backup criado: $controller.old" -ForegroundColor Gray
        }
    }
}

Write-Host "  ? Controllers Pedidos e Carrinho precisam ser simplificados manualmente" -ForegroundColor Yellow
Write-Host ""

# 3. Restaurar pacotes
Write-Host "[ 3/5 ] Restaurando pacotes NuGet..." -ForegroundColor Yellow
$restoreOutput = dotnet restore 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ? Pacotes restaurados" -ForegroundColor Green
}
else {
 Write-Host "  ? Erro ao restaurar pacotes" -ForegroundColor Red
    Write-Host $restoreOutput
}
Write-Host ""

# 4. Tentar build
Write-Host "[ 4/5 ] Tentando build..." -ForegroundColor Yellow
$buildOutput = dotnet build --no-restore 2>&1

$erros = $buildOutput | Select-String "error CS"
$avisos = $buildOutput | Select-String "warning CS"

if ($LASTEXITCODE -eq 0) {
    Write-Host "  ? Build compilou com sucesso!" -ForegroundColor Green
}
else {
    Write-Host "  ? Build falhou com erros" -ForegroundColor Red
    Write-Host ""
    Write-Host "Erros encontrados:" -ForegroundColor Yellow
    $erros | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    
    if ($avisos.Count -gt 0) {
        Write-Host ""
        Write-Host "Avisos:" -ForegroundColor Yellow
    $avisos | Select-Object -First 5 | ForEach-Object { Write-Host "  - $_" -ForegroundColor DarkYellow }
    }
}

Write-Host ""

# 5. Criar resumo
Write-Host "[ 5/5 ] Resumo da migração..." -ForegroundColor Yellow
Write-Host ""

Write-Host "? CONCLUÍDO:" -ForegroundColor Green
Write-Host "  - MongoDB.Driver instalado" -ForegroundColor White
Write-Host "  - MongoDbContext criado" -ForegroundColor White
Write-Host "  - Repositório genérico implementado" -ForegroundColor White
Write-Host "  - Program.cs migrado" -ForegroundColor White
Write-Host "  - CategoriasController migrado" -ForegroundColor White
Write-Host "  - ProdutosController migrado" -ForegroundColor White
Write-Host "  - ClientesController migrado" -ForegroundColor White
Write-Host "  - Entidades Cliente e Endereco migradas" -ForegroundColor White
Write-Host ""

Write-Host "?? PENDENTE:" -ForegroundColor Yellow
Write-Host "  - Migrar entidades restantes (Produto, Categoria, Pedido, etc.)" -ForegroundColor White
Write-Host "  - Simplificar PedidosController" -ForegroundColor White
Write-Host "  - Simplificar CarrinhoController" -ForegroundColor White
Write-Host ""

if ($LASTEXITCODE -ne 0) {
    Write-Host "?? PRÓXIMOS PASSOS:" -ForegroundColor Cyan
    Write-Host "  1. Revisar erros de compilação acima" -ForegroundColor White
  Write-Host "  2. Atualizar entidades faltantes (copiar padrão de Cliente.cs)" -ForegroundColor White
    Write-Host "  3. Simplificar controllers restantes" -ForegroundColor White
    Write-Host "  4. Executar: dotnet build" -ForegroundColor White
    Write-Host ""
}
else {
    Write-Host "?? BUILD OK! Próximos passos:" -ForegroundColor Green
    Write-Host "  1. Testar localmente: cd src/Barbara.API && dotnet run" -ForegroundColor White
    Write-Host "  2. Verificar MongoDB URI no .env" -ForegroundColor White
    Write-Host "  3. Testar endpoints: .\test-azure-api.ps1 -BaseUrl http://localhost:5000" -ForegroundColor White
    Write-Host "  4. Deploy no Azure quando estiver tudo OK" -ForegroundColor White
    Write-Host ""
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
