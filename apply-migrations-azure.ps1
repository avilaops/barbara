# ??? APLICAR MIGRATIONS NO AZURE SQL

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  APLICAR MIGRATIONS - Azure SQL" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$connectionString = "Server=tcp:barbara-sql-srv.database.windows.net,1433;Database=BarbaraDB;User Id=barbaraadmin;Password=Barbara@2025!Secure;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

Write-Host "?? Informações:" -ForegroundColor Yellow
Write-Host "  SQL Server: barbara-sql-srv.database.windows.net" -ForegroundColor White
Write-Host "  Database: BarbaraDB" -ForegroundColor White
Write-Host "  User: barbaraadmin" -ForegroundColor White
Write-Host ""

Write-Host "?? Executando migrations..." -ForegroundColor Yellow
Write-Host ""

try {
    Push-Location "src\Barbara.Infrastructure"
    
    Write-Host "  Comando: dotnet ef database update --startup-project ../Barbara.API --connection [...]" -ForegroundColor Gray
    Write-Host ""
    
    dotnet ef database update --startup-project ../Barbara.API --connection $connectionString
    
    Pop-Location
    
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  ? MIGRATIONS APLICADAS COM SUCESSO!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "?? Próximos passos:" -ForegroundColor Yellow
    Write-Host "  1. Faça o publish da aplicação (Visual Studio)" -ForegroundColor White
    Write-Host "  2. Teste a API: https://barbara-api.azurewebsites.net/swagger" -ForegroundColor White
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Red
  Write-Host "  ? ERRO AO APLICAR MIGRATIONS" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
    Write-Host ""
  Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possíveis causas:" -ForegroundColor Yellow
    Write-Host "  1. Firewall do SQL Server bloqueando seu IP" -ForegroundColor White
    Write-Host "  2. Credenciais incorretas" -ForegroundColor White
    Write-Host "  3. Database não existe" -ForegroundColor White
    Write-Host ""
    Write-Host "Soluções:" -ForegroundColor Yellow
    Write-Host "  1. Verifique se seu IP está no firewall:" -ForegroundColor White
    Write-Host "     az sql server firewall-rule list --resource-group barbara-rg --server barbara-sql-srv" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. Adicione seu IP atual:" -ForegroundColor White
    Write-Host "     az sql server firewall-rule create --resource-group barbara-rg --server barbara-sql-srv --name MyCurrentIP --start-ip-address [SEU-IP] --end-ip-address [SEU-IP]" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  3. Teste conexão:" -ForegroundColor White
    Write-Host "     Test-NetConnection -ComputerName barbara-sql-srv.database.windows.net -Port 1433" -ForegroundColor Gray
    Write-Host ""
}
