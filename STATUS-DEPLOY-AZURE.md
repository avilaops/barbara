# ? STATUS DO DEPLOY AZURE - Barbara E-commerce

**Data:** 2025-01-09  
**Domínio Alvo:** https://barbara.avila.inc  
**Status:** ?? Infraestrutura OK | ?? Aguardando Publish da Aplicação

---

## ? COMANDOS RÁPIDOS

```powershell
# 1. APLICAR MIGRATIONS (Execute primeiro!)
.\apply-migrations-azure.ps1

# 2. VERIFICAR RECURSOS
.\check-azure-resources.ps1

# 3. TESTAR API (após publish)
.\test-azure-api.ps1 -BaseUrl "https://barbara-api.azurewebsites.net"

# 4. DEPLOY COMPLETO (com domínio customizado)
.\deploy-azure-complete.ps1
```

---

## ?? RECURSOS CRIADOS COM SUCESSO

### ? 1. SQL Server
- **Nome:** barbara-sql-srv
- **FQDN:** barbara-sql-srv.database.windows.net
- **Região:** East US 2
- **Admin:** barbaraadmin
- **Password:** Barbara@2025!Secure
- **Status:** ? Operacional

### ? 2. SQL Database
- **Nome:** BarbaraDB
- **Tier:** Basic (5 DTUs)
- **Status:** ? Online
- **Custo:** ~USD 5/mês

### ? 3. Firewall SQL
- **Regra 1:** AllowAzureServices (0.0.0.0)
- **Regra 2:** ClientIP (152.254.233.137)
- **Status:** ? Configurado

### ? 4. App Service Plan
- **Nome:** barbara-plan
- **Região:** Brazil South
- **Tier:** Free F1 (Linux)
- **Custo:** Gratuito
- **Status:** ? Pronto

### ? 5. Web App
- **Nome:** barbara-api
- **URL Padrão:** https://barbara-api.azurewebsites.net
- **Runtime:** .NET Core 9.0
- **Status:** ? Criado

### ? 6. Connection String
- **Nome:** DefaultConnection
- **Tipo:** SQLAzure
- **Status:** ? Configurada

---

## ?? PENDÊNCIAS

### ?? CRÍTICO - Deploy da Aplicação

**Status:** ? Não concluído  
**Motivo:** Erro no upload via Azure CLI no tier Free

**SOLUÇÃO:**  
Use o **Visual Studio 2022** para fazer o publish:

```
1. Abra Visual Studio 2022
2. Botão direito em 'Barbara.API'
3. Publish ? Azure ? Azure App Service (Linux)
4. Login: contato@mrgcaixastermicas.com.br
5. Selecione: barbara-api
6. Publish
```

**Arquivos prontos:**
- ? Build Release: `src/Barbara.API/publish/`
- ? ZIP criado: `src/Barbara.API/barbara-api.zip` (7.1 MB)

---

### ?? IMPORTANTE - Migrations

**Status:** ?? Não aplicadas

**SOLUÇÃO:**

```powershell
cd C:\Users\nicol\source\repos\avilaops\barbara\src\Barbara.Infrastructure

$connectionString = "Server=tcp:barbara-sql-srv.database.windows.net,1433;Database=BarbaraDB;User Id=barbaraadmin;Password=Barbara@2025!Secure;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

dotnet ef database update --startup-project ../Barbara.API --connection $connectionString
```

**OU** execute o script:
```powershell
.\deploy-azure-complete.ps1
```

---

### ?? OPCIONAL - Domínio Customizado

**Domínio:** barbara.avila.inc  
**Status:** ?? Não configurado

**PASSO A PASSO COMPLETO:** Ver arquivo `SETUP-DOMINIO-CUSTOMIZADO.md`

**Resumo rápido:**

1. **Obter Verification ID:**
   ```powershell
   az webapp show --resource-group barbara-rg --name barbara-api --query customDomainVerificationId -o tsv
   ```

2. **Configurar DNS** (no provedor de avila.inc):
   ```
   Tipo: CNAME
   Nome: barbara
   Valor: barbara-api.azurewebsites.net
   TTL: 3600
   ```

3. **Aguardar propagação:** 5 min a 48h

4. **Adicionar no Azure:**
   ```powershell
   az webapp config hostname add --resource-group barbara-rg --webapp-name barbara-api --hostname barbara.avila.inc
   ```

5. **Habilitar HTTPS:**
   ```powershell
   az webapp config ssl bind --resource-group barbara-rg --name barbara-api --certificate-thumbprint auto --ssl-type SNI --hostname barbara.avila.inc
   ```

---

## ?? CHECKLIST DE DEPLOY

- [x] Resource Group criado
- [x] SQL Server criado
- [x] SQL Database criado
- [x] Firewall SQL configurado
- [ ] **Migrations aplicadas** ? FAZER AGORA
- [x] App Service Plan criado
- [x] Web App criado
- [x] Connection String configurada
- [ ] **Aplicação publicada** ? FAZER AGORA
- [ ] Swagger acessível
- [ ] Teste de endpoints OK
- [ ] Domínio customizado configurado
- [ ] SSL/TLS configurado

**Progresso:** 8/14 (57%)

---

## ?? PRÓXIMOS PASSOS (EM ORDEM)

### 1?? Deploy da Aplicação (AGORA)

**Opção A - Visual Studio (Recomendado):**
```
1. Abra Barbara.sln no Visual Studio
2. Botão direito em Barbara.API ? Publish
3. Siga o wizard de publicação
```

**Opção B - Azure CLI (pode falhar no Free tier):**
```powershell
cd src\Barbara.API
az webapp deploy --resource-group barbara-rg --name barbara-api --src-path barbara-api.zip --type zip
```

**Opção C - FTP Manual:**
```powershell
# Obter credenciais FTP
az webapp deployment list-publishing-profiles --resource-group barbara-rg --name barbara-api

# Fazer upload via FTP client (FileZilla, WinSCP)
```

---

### 2?? Aplicar Migrations (DEPOIS DO DEPLOY)

```powershell
cd src\Barbara.Infrastructure
dotnet ef database update --startup-project ../Barbara.API --connection "Server=tcp:barbara-sql-srv.database.windows.net,1433;Database=BarbaraDB;User Id=barbaraadmin;Password=Barbara@2025!Secure;Encrypt=True;TrustServerCertificate=False;"
```

---

### 3?? Testar API

```powershell
# Teste básico
Invoke-WebRequest -Uri "https://barbara-api.azurewebsites.net/swagger" -UseBasicParsing

# Teste completo
.\test-azure-api.ps1 -BaseUrl "https://barbara-api.azurewebsites.net"
```

---

### 4?? Configurar Domínio Customizado (OPCIONAL)

Siga o guia: `SETUP-DOMINIO-CUSTOMIZADO.md`

---

### 5?? Configurar CI/CD (FUTURO)

- GitHub Actions para deploy automático
- Ou Azure DevOps Pipeline

---

## ?? CUSTO ATUAL

| Recurso | Tier | Custo/mês |
|---------|------|-----------|
| SQL Database | Basic (5 DTU) | ~USD 5 |
| App Service | Free F1 | USD 0 |
| **TOTAL** | | **~USD 5/mês** |

**Observação:** Para produção, considere upgrade para:
- App Service: B1 (USD 13/mês) - Mais estável
- SQL Database: S0 (USD 15/mês) - Melhor performance

---

## ?? INFORMAÇÕES DE CONEXÃO

### SQL Server
```
Server: barbara-sql-srv.database.windows.net,1433
Database: BarbaraDB
User: barbaraadmin
Password: Barbara@2025!Secure
```

### Connection String
```
Server=tcp:barbara-sql-srv.database.windows.net,1433;Database=BarbaraDB;User Id=barbaraadmin;Password=Barbara@2025!Secure;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
```

### URLs
- **Padrão:** https://barbara-api.azurewebsites.net
- **Swagger:** https://barbara-api.azurewebsites.net/swagger
- **Custom (futuro):** https://barbara.avila.inc

---

## ?? SCRIPTS CRIADOS

| Script | Descrição |
|--------|-----------|
| `deploy-azure.ps1` | Deploy automatizado (versão original) |
| `deploy-azure-complete.ps1` | Deploy completo com domínio customizado |
| `check-azure-resources.ps1` | Verificar recursos existentes |
| `test-azure-api.ps1` | Teste completo da API |
| `SETUP-DOMINIO-CUSTOMIZADO.md` | Guia de configuração do domínio |

---

## ?? DOCUMENTAÇÃO

- **README-BARBARA.md** - Guia principal do projeto
- **DEPLOY-MANUAL-AZURE.md** - Deploy manual via Portal
- **SETUP-DOMINIO-CUSTOMIZADO.md** - Configuração de domínio
- **ARQUITETURA.md** - Arquitetura do sistema
- **GUIA-IMPLEMENTACAO-SEMANA1.md** - Próximas features

---

## ? AÇÃO REQUERIDA

**AGORA:**
1. Faça o **publish via Visual Studio** (3-5 minutos)
2. Aplique as **migrations** (1 minuto)
3. Teste a **API no Swagger** (https://barbara-api.azurewebsites.net/swagger)

**DEPOIS (OPCIONAL):**
4. Configure o **domínio customizado** barbara.avila.inc
5. Configure **CI/CD** para deploys automáticos

---

**Status Geral:** ? Infraestrutura OK | ?? Aguardando Deploy da Aplicação

---

**Última atualização:** 2025-01-09 09:00 UTC
