# 🚀 GUIA DE DEPLOY MANUAL - Azure Portal

## ✅ VOCÊ JÁ TEM:
- Resource Group: `barbara-rg` (East US)
## 📋 PASSOS PARA DEPLOY
### **PASSO 1: Criar SQL Database**
1. No Portal Azure, vá em **SQL databases**
2. Clique em **+ Create**
3. Configurações:
   - **Resource group:** barbara-rg
   - **Database name:** BarbaraDB
   - **Server:** Criar novo
     - **Server name:** barbara-sql-server (ou similar disponível)
     - **Location:** East US
     - **Authentication:** SQL authentication
     - **Admin login:** barbaraadmin
 - **Password:** Barbara@2025!Secure
   - **Compute + storage:** Basic (5 DTUs) - mais barato para começar
4. **Review + create** → **Create**
5. Aguarde ~5 minutos
### **PASSO 2: Configurar Firewall do SQL**
1. Vá no SQL Server criado (barbara-sql-server)
2. **Security** → **Networking**
3. **Firewall rules:**
   - Marque **Allow Azure services**
   - Adicione sua regra:
     - **Rule name:** MyIP
     - Clique em **Add client IP**
4. **Save**
### **PASSO 3: Aplicar Migrations**
No seu computador local:
```powershell
# 1. Copiar connection string do Azure
$connectionString = "Server=tcp:barbara-sql-server.database.windows.net,1433;Database=BarbaraDB;User Id=barbaraadmin;Password=Barbara@2025!Secure;Encrypt=True;TrustServerCertificate=False;"

# 2. Aplicar migrations
cd C:\Users\nicol\source\repos\avilaops\barbara\src\Barbara.Infrastructure
dotnet ef database update --startup-project ../Barbara.API --connection $connectionString
```

### **PASSO 4: Criar App Service**

1. No Portal Azure, vá em **App Services**
2. Clique em **+ Create**
3. **Basics:**
   - **Resource group:** barbara-rg
   - **Name:** barbara-api (ou similar disponível)
   - **Publish:** Code
   - **Runtime stack:** .NET 9 (STS)
   - **Operating System:** Linux
   - **Region:** East US
4. **Pricing:**
   - **Pricing plan:** Basic B1 (~$13/mês)
   - Ou **Free F1** para teste (limitado)
5. **Review + create** → **Create**
6. Aguarde ~2 minutos

### **PASSO 5: Configurar Connection String**

1. Vá no App Service criado (barbara-api)
2. **Settings** → **Configuration**
3. **Connection strings** → **+ New connection string**
   - **Name:** DefaultConnection
   - **Value:** (cole a connection string do SQL)
   - **Type:** SQLAzure
4. **Save**

### **PASSO 6: Publicar Aplicação**

No Visual Studio:

1. **Botão direito** no projeto `Barbara.API`
2. **Publish**
3. **Target:** Azure
4. **Specific target:** Azure App Service (Linux)
5. **Sign in** com sua conta Azure
6. Selecione **barbara-api**
7. **Publish**
8. Aguarde ~5 minutos

**OU via PowerShell:**

```powershell
cd C:\Users\nicol\source\repos\avilaops\barbara\src\Barbara.API

# Compilar
dotnet publish -c Release -o ./publish

# Criar ZIP
Compress-Archive -Path ./publish/* -DestinationPath ./barbara-api.zip -Force

# Upload (precisa Azure CLI instalado)
az webapp deployment source config-zip `
  --resource-group barbara-rg `
  --name barbara-api `
  --src ./barbara-api.zip
```

### **PASSO 7: Testar API**

1. Vá em **Overview** do App Service
2. Copie a **URL**: `https://barbara-api.azurewebsites.net`
3. Acesse: `https://barbara-api.azurewebsites.net/swagger`

---

## 🧪 TESTE RÁPIDO

```powershell
$baseUrl = "https://barbara-api.azurewebsites.net"

# Criar categoria
Invoke-RestMethod -Uri "$baseUrl/api/categorias" -Method POST -ContentType "application/json" -Body (@{
  nome = "Vestidos"
  descricao = "Vestidos femininos"
  ativa = $true
} | ConvertTo-Json)

# Listar categorias
Invoke-RestMethod -Uri "$baseUrl/api/categorias" -Method GET
```

---

## 💰 CUSTOS ESTIMADOS

| Recurso | Tier | Custo/mês (USD) |
|---------|------|-----------------|
| SQL Database | Basic (5 DTU) | ~$5 |
| App Service | B1 (1 core, 1.75GB) | ~$13 |
| **TOTAL** | | **~$18/mês** |

**Opção GRATUITA:**
- SQL Database: Compartilhado (~$0 primeiros 12 meses)
- App Service: F1 Free (limitado)

---

## 🔧 TROUBLESHOOTING

### **Erro: Cannot connect to SQL Server**
- Verifique firewall do SQL Server
- Adicione sua IP
- Marque "Allow Azure services"

### **Erro: 500 Internal Server Error**
- Verifique logs no App Service → **Monitoring** → **Log stream**
- Connection string está correta?
- Migrations foram aplicadas?

### **Erro: Application failed to start**
- Vá em **Configuration** → **General settings**
- **Stack:** .NET
- **Version:** 9
- **Startup Command:** (deixe vazio)

---

## 📊 MONITORAMENTO

### **Logs em Tempo Real:**
1. App Service → **Monitoring** → **Log stream**

### **Métricas:**
1. App Service → **Monitoring** → **Metrics**
2. Ver: Requests, Response Time, CPU, Memory

### **Application Insights (Opcional):**
1. Criar Application Insights
2. Conectar ao App Service
3. Logs avançados + alertas

---

## 🎯 PRÓXIMOS PASSOS

Após deploy:

1. **Domínio Customizado:**
   - App Service → **Custom domains**
   - Adicionar: `api.barbara.com.br`

2. **SSL/TLS:**
   - Automático com domínio custom
   - Ou use App Service Managed Certificate

3. **CI/CD:**
   - GitHub Actions para deploy automático
   - Azure DevOps Pipeline

4. **Backup:**
   - SQL Database → Automated backups (já incluso)
   - App Service → Backups (configurar)

---

## ✅ CHECKLIST DE DEPLOY

- [ ] SQL Server criado
- [ ] SQL Database criado
- [ ] Firewall configurado
- [ ] Migrations aplicadas
- [ ] App Service criado
- [ ] Connection string configurada
- [ ] Aplicação publicada
- [ ] Swagger acessível
- [ ] Teste de endpoints OK

---

**🎉 DEPLOY CONCLUÍDO!**

Sua API estará disponível em:
```
https://barbara-api.azurewebsites.net/swagger
```
