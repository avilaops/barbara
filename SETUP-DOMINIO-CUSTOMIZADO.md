# ?? CONFIGURAR DOMÍNIO CUSTOMIZADO - barbara.avila.inc

## ? RECURSOS JÁ CRIADOS

- ? SQL Server: `barbara-sql-srv.database.windows.net`
- ? Database: `BarbaraDB`
- ? App Service: `barbara-api.azurewebsites.net`
- ? Resource Group: `barbara-rg`

---

## ?? PASSO A PASSO

### **PASSO 1: Obter Verification ID**

No PowerShell:

```powershell
az webapp show --resource-group barbara-rg --name barbara-api --query customDomainVerificationId -o tsv
```

**OU** no Portal Azure:
1. Vá em **App Service** ? `barbara-api`
2. **Custom domains**
3. Copie o **Custom Domain Verification ID**

---

### **PASSO 2: Configurar DNS**

No seu provedor de DNS onde está registrado `avila.inc`:

#### **Opção A: CNAME (Recomendado)**

| Tipo  | Nome     | Valor        | TTL  |
|-------|----------|---------------------------------|------|
| CNAME | barbara  | barbara-api.azurewebsites.net   | 3600 |

#### **Opção B: A Record + TXT (Se CNAME não funcionar)**

**Passo 1:** Obter IP do App Service:
```powershell
nslookup barbara-api.azurewebsites.net
```

**Passo 2:** Adicionar registros:

| Tipo | Nome        | Valor         | TTL  |
|------|----------------|----------------------------------------------|------|
| A    | barbara        | [IP obtido acima]         | 3600 |
| TXT  | asuid.barbara  | [Custom Domain Verification ID do Passo 1]   | 3600 |

---

### **PASSO 3: Aguardar Propagação DNS**

Verificar se DNS propagou (pode levar de 5 min a 48h):

```powershell
nslookup barbara.avila.inc
```

Deve retornar o IP ou CNAME do Azure.

---

### **PASSO 4: Adicionar Domínio no Azure**

#### **Via Azure CLI:**

```powershell
# 1. Adicionar domínio
az webapp config hostname add `
  --resource-group barbara-rg `
  --webapp-name barbara-api `
  --hostname barbara.avila.inc

# 2. Habilitar HTTPS com certificado gerenciado
az webapp config ssl bind `
  --resource-group barbara-rg `
  --name barbara-api `
  --certificate-thumbprint auto `
  --ssl-type SNI `
  --hostname barbara.avila.inc
```

#### **Via Portal Azure:**

1. Vá em **App Service** ? `barbara-api`
2. **Custom domains** ? **+ Add custom domain**
3. Digite: `barbara.avila.inc`
4. Clique em **Validate**
5. Se validar ?, clique em **Add**
6. Aguarde adição (~2 min)
7. Vá em **TLS/SSL settings** ? **Private Key Certificates (.pfx)**
8. **+ Create App Service Managed Certificate**
9. Selecione: `barbara.avila.inc`
10. Clique em **Create**
11. Aguarde criação (~3 min)
12. Volte em **Custom domains**
13. Clique em **Add binding** ao lado de `barbara.avila.inc`
14. Selecione o certificado criado
15. **TLS/SSL type:** SNI SSL
16. Clique em **Add binding**

---

### **PASSO 5: Forçar HTTPS (Opcional)**

```powershell
az webapp update `
  --resource-group barbara-rg `
  --name barbara-api `
  --set httpsOnly=true
```

**OU** no Portal:
1. **App Service** ? `barbara-api`
2. **Configuration** ? **General settings**
3. **HTTPS Only:** On
4. **Save**

---

### **PASSO 6: Testar**

```powershell
# Teste HTTP (deve redirecionar para HTTPS)
Invoke-WebRequest -Uri "http://barbara.avila.inc" -UseBasicParsing

# Teste HTTPS
Invoke-WebRequest -Uri "https://barbara.avila.inc/swagger" -UseBasicParsing

# Teste API
Invoke-RestMethod -Uri "https://barbara.avila.inc/api/categorias" -Method GET
```

---

## ?? TROUBLESHOOTING

### **Erro: "Unable to verify domain ownership"**

**Causa:** DNS ainda não propagou ou registro TXT faltando.

**Solução:**
```powershell
# Verificar DNS
nslookup barbara.avila.inc

# Verificar registro TXT
nslookup -type=TXT asuid.barbara.avila.inc
```

Aguarde propagação (até 48h) ou verifique se os registros estão corretos.

---

### **Erro: "Hostname already exists"**

**Causa:** Domínio já associado a outro App Service.

**Solução:**
```powershell
# Remover domínio do outro App Service
az webapp config hostname delete `
  --resource-group [outro-rg] `
  --webapp-name [outro-app] `
  --hostname barbara.avila.inc

# Tentar adicionar novamente
az webapp config hostname add `
  --resource-group barbara-rg `
  --webapp-name barbara-api `
  --hostname barbara.avila.inc
```

---

### **Erro: SSL/TLS não funciona**

**Causa:** Certificado não foi criado ou binding não foi feito.

**Solução:**
1. Vá no Portal Azure ? **App Service** ? `barbara-api`
2. **TLS/SSL settings** ? **Private Key Certificates**
3. Verifique se existe certificado para `barbara.avila.inc`
4. Se não, crie um novo (passo 4 acima)
5. Verifique **Custom domains** ? deve ter ícone de cadeado ??

---

## ?? VALIDAÇÃO FINAL

### Checklist:

- [ ] DNS configurado (CNAME ou A + TXT)
- [ ] DNS propagou (nslookup funciona)
- [ ] Domínio adicionado no Azure
- [ ] Certificado SSL criado
- [ ] SSL binding configurado
- [ ] HTTPS Only habilitado
- [ ] https://barbara.avila.inc/swagger acessível
- [ ] API respondendo em https://barbara.avila.inc/api/categorias

---

## ?? PRÓXIMOS PASSOS

Após configurar domínio:

1. **Atualizar documentação:**
   - Atualizar README.md com nova URL
   - Atualizar links em scripts de teste

2. **Configurar CORS (se necessário):**
   ```powershell
   az webapp cors add `
     --resource-group barbara-rg `
     --name barbara-api `
     --allowed-origins "https://barbara.avila.inc"
   ```

3. **Configurar Redirect:**
   - Redirecionar `barbara-api.azurewebsites.net` para `barbara.avila.inc`

4. **Monitoramento:**
   - Configurar alertas para expiração de certificado
   - Monitorar disponibilidade do domínio

---

## ?? EXEMPLO COMPLETO

```powershell
# 1. Obter Verification ID
$verificationId = az webapp show --resource-group barbara-rg --name barbara-api --query customDomainVerificationId -o tsv
Write-Host "Verification ID: $verificationId"

# 2. Configure DNS no seu provedor
# CNAME: barbara ? barbara-api.azurewebsites.net

# 3. Aguarde propagação
Write-Host "Aguardando DNS propagar..."
Start-Sleep -Seconds 300 # 5 minutos

# 4. Verificar DNS
nslookup barbara.avila.inc

# 5. Adicionar domínio
az webapp config hostname add --resource-group barbara-rg --webapp-name barbara-api --hostname barbara.avila.inc

# 6. Criar certificado SSL
az webapp config ssl create --resource-group barbara-rg --name barbara-api --hostname barbara.avila.inc

# 7. Forçar HTTPS
az webapp update --resource-group barbara-rg --name barbara-api --set httpsOnly=true

# 8. Testar
Invoke-WebRequest -Uri "https://barbara.avila.inc/swagger" -UseBasicParsing
```

---

**?? DOMÍNIO CUSTOMIZADO CONFIGURADO!**

Sua API estará disponível em:
- https://barbara.avila.inc
- https://barbara.avila.inc/swagger
