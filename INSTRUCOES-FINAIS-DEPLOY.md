# ?? DEPLOY FINAL - Barbara E-commerce

## ? O QUE JÁ ESTÁ PRONTO

? Resource Group: `barbara-rg`  
? SQL Server: `barbara-sql-srv.database.windows.net`  
? Database: `BarbaraDB` (Basic tier)  
? Firewall configurado  
? App Service Plan: `barbara-plan` (Free F1)  
? Web App: `barbara-api.azurewebsites.net`  
? Connection String configurada  

**Custo:** ~USD 5/mês (apenas SQL Database)

---

## ?? FALTA FAZER (2 PASSOS)

### ? PASSO 1: Aplicar Migrations

```powershell
.\apply-migrations-azure.ps1
```

**Tempo:** ~1 minuto  
**Isso vai:** Criar as tabelas no banco Azure

---

### ? PASSO 2: Publicar Aplicação

**MELHOR OPÇÃO - Visual Studio:**

1. Abra `Barbara.sln` no Visual Studio 2022
2. Botão direito em `Barbara.API` ? **Publish**
3. Target: **Azure**
4. Specific: **Azure App Service (Linux)**
5. Login: `contato@mrgcaixastermicas.com.br`
6. Subscription: **Padrão**
7. Selecione: **barbara-api**
8. Clique em **Publish**
9. Aguarde ~3-5 minutos

**ALTERNATIVA - PowerShell (pode falhar no tier Free):**

```powershell
cd src\Barbara.API

# O ZIP já está pronto!
az webapp deploy --resource-group barbara-rg --name barbara-api --src-path barbara-api.zip --type zip
```

---

## ?? PASSO 3: Testar

```powershell
# Teste básico
Start-Process "https://barbara-api.azurewebsites.net/swagger"

# Teste completo
.\test-azure-api.ps1 -BaseUrl "https://barbara-api.azurewebsites.net"
```

---

## ?? PASSO 4 (OPCIONAL): Domínio Customizado

### Configurar DNS

No provedor de `avila.inc`, adicione:

```
Tipo: CNAME
Nome: barbara
Valor: barbara-api.azurewebsites.net
TTL: 3600
```

### Adicionar no Azure

```powershell
# 1. Aguarde DNS propagar (5 min a 48h)
nslookup barbara.avila.inc

# 2. Adicione o domínio
az webapp config hostname add --resource-group barbara-rg --webapp-name barbara-api --hostname barbara.avila.inc

# 3. Ative HTTPS
az webapp config ssl bind --resource-group barbara-rg --name barbara-api --certificate-thumbprint auto --ssl-type SNI --hostname barbara.avila.inc
```

**Guia completo:** `SETUP-DOMINIO-CUSTOMIZADO.md`

---

## ?? RESULTADO FINAL

Depois dos 4 passos, você terá:

? API rodando no Azure  
? Database configurado  
? Swagger acessível  
? HTTPS automático  
? (Opcional) Domínio customizado  

**URLs:**
- Padrão: https://barbara-api.azurewebsites.net
- Swagger: https://barbara-api.azurewebsites.net/swagger
- Custom: https://barbara.avila.inc (se configurado)

---

## ?? TROUBLESHOOTING

### Erro: "Cannot connect to SQL Server"

```powershell
# Adicione seu IP ao firewall
$myIp = (Invoke-RestMethod -Uri "https://api.ipify.org").Trim()
az sql server firewall-rule create --resource-group barbara-rg --server barbara-sql-srv --name MyIP --start-ip-address $myIp --end-ip-address $myIp
```

### Erro: "500 Internal Server Error"

```powershell
# Veja os logs
az webapp log tail --resource-group barbara-rg --name barbara-api
```

### App não inicia

```powershell
# Verifique configuração
az webapp config show --resource-group barbara-rg --name barbara-api

# Reinicie
az webapp restart --resource-group barbara-rg --name barbara-api
```

---

## ?? ARQUIVOS DE REFERÊNCIA

| Arquivo | Descrição |
|---------|-----------|
| `STATUS-DEPLOY-AZURE.md` | Status detalhado do deploy |
| `SETUP-DOMINIO-CUSTOMIZADO.md` | Guia de domínio customizado |
| `apply-migrations-azure.ps1` | Script para migrations |
| `check-azure-resources.ps1` | Verificar recursos |
| `test-azure-api.ps1` | Testar API completa |
| `deploy-azure-complete.ps1` | Deploy automatizado completo |

---

## ?? DICAS

1. **Performance:** Considere upgrade para App Service B1 em produção
2. **Monitoramento:** Configure Application Insights
3. **CI/CD:** Configure GitHub Actions para deploy automático
4. **Backup:** SQL Database tem backup automático (7 dias)
5. **Custos:** Monitore no Azure Cost Management

---

## ?? PRONTO!

Agora é só:

1. ? Rodar `.\apply-migrations-azure.ps1`
2. ? Fazer publish no Visual Studio
3. ? Testar no Swagger
4. ? (Opcional) Configurar domínio customizado

**Boa sorte! ??**

---

**Precisa de ajuda?** Veja os arquivos de documentação ou execute:
```powershell
.\check-azure-resources.ps1  # Para ver status atual
```
