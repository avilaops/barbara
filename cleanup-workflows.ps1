# ?? LIMPEZA DE WORKFLOWS OBSOLETOS

Write-Host "??????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?  ?? LIMPEZA DE WORKFLOWS OBSOLETOS      ?" -ForegroundColor Cyan
Write-Host "??????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

$workflowsObsoletos = @(
    ".github/workflows/api-ci.yml",      # Node.js antigo
    ".github/workflows/ci.yml", # Node.js antigo (duplicado)
    ".github/workflows/unity-webgl.yml"  # Consolidado no deploy-complete.yml
)

Write-Host "?? Workflows no projeto:" -ForegroundColor Yellow
Write-Host ""

Get-ChildItem .github/workflows/*.yml | ForEach-Object {
    $name = $_.Name
    $status = if ($workflowsObsoletos -contains $_.FullName.Replace("\", "/")) { "? Obsoleto" } else { "? Ativo" }
    Write-Host "  $status  $name" -ForegroundColor $(if ($status -match "Obsoleto") { "Red" } else { "Green" })
}

Write-Host ""
Write-Host "???????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

$resposta = Read-Host "Deseja deletar os workflows obsoletos? (S/N)"

if ($resposta -eq "S" -or $resposta -eq "s") {
    Write-Host ""
    Write-Host "???  Deletando workflows obsoletos..." -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($workflow in $workflowsObsoletos) {
        if (Test-Path $workflow) {
      $nome = Split-Path $workflow -Leaf
            Write-Host "  Deletando: $nome" -ForegroundColor Gray
            git rm $workflow
      }
    }
    
    Write-Host ""
    Write-Host "? Workflows obsoletos deletados!" -ForegroundColor Green
    Write-Host ""
    Write-Host "?? Próximos passos:" -ForegroundColor Cyan
    Write-Host "  1. git commit -m 'chore: Remover workflows obsoletos Node.js'" -ForegroundColor White
    Write-Host "  2. git push" -ForegroundColor White
    Write-Host ""
    Write-Host "?? Workflows mantidos:" -ForegroundColor Cyan
    Write-Host "  ? azure-deploy.yml     - Deploy API .NET (simples)" -ForegroundColor Green
    Write-Host "  ? deploy-complete.yml  - Deploy completo (API + Unity + Functions)" -ForegroundColor Green
    Write-Host ""
    
} else {
    Write-Host ""
    Write-Host "? Operação cancelada. Nenhum arquivo foi deletado." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "???????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""
Write-Host "?? Documentação: GUIA-GITHUB-ACTIONS.md" -ForegroundColor Cyan
Write-Host ""
