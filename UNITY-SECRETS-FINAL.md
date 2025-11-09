# ?? CONFIGURAR UNITY SECRETS - PASSO FINAL

## ? UNITY LICENSE ENCONTRADA!

Você já tem o arquivo .ulf! Agora só precisa configurar os 3 secrets no GitHub.

---

## ?? PASSO A PASSO (5 minutos)

### **1. Abrir GitHub Secrets**

```powershell
Start-Process "https://github.com/avilaops/barbara/settings/secrets/actions/new"
```

---

### **2. Adicionar SECRET #1: UNITY_LICENSE**

**Name:** `UNITY_LICENSE`

**Secret:** Cole o XML completo abaixo ??

```xml
<?xml version="1.0" encoding="UTF-8"?><root><TimeStamp Value="JASS5XOYz+tIIg=="/> <License id="Terms"> <MachineBindings> <Binding Key="1" Value="00355-61999-95039-AAOEM"/> <Binding Key="4" Value="NjRNMFg2NA=="/> <Binding Key="5" Value="08:b4:d2:95:5c:63"/> </MachineBindings> <MachineID Value="ADMVH5A1WFZW4IBc0l1no39U8y8="/> <SerialHash Value="3e5035247dd2edbb83d47fc0d9a4fda1870a5214"/> <Features> <Feature Value="33"/> <Feature Value="1"/> <Feature Value="12"/> <Feature Value="2"/> <Feature Value="24"/> <Feature Value="3"/> <Feature Value="36"/> <Feature Value="17"/> <Feature Value="19"/> <Feature Value="62"/> </Features> <DeveloperData Value="AQAAAEY0LTc2VTMtNk1TQi1ISjhRLUU3R1AtV1Y3TQ=="/> <SerialMasked Value="F4-76U3-6MSB-HJ8Q-E7GP-XXXX"/> <StartDate Value="2025-11-07T00:00:00"/> <UpdateDate Value="2025-11-08T16:53:15"/> <InitialActivationDate Value="2025-11-07T15:05:33"/> <LicenseVersion Value="6.x"/> <ClientProvidedVersion Value="2017.2.0"/> <AlwaysOnline Value="false"/> <Entitlements> <Entitlement Ns="unity_editor" Tag="UnityPersonal" Type="EDITOR" ValidTo="9999-12-31T00:00:00"/> <Entitlement Ns="unity_editor" Tag="DarkSkin" Type="EDITOR_FEATURE" ValidTo="9999-12-31T00:00:00"/> </Entitlements> </License><Signature xmlns="http://www.w3.org/2000/09/xmldsig#"><SignedInfo><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315#WithComments"/><SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/><Reference URI="#Terms"><Transforms><Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/></Transforms><DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/><DigestValue>3XNRiadHZzt9BxgKANZnie/SicA=</DigestValue></Reference></SignedInfo><SignatureValue>Bq8JhTesUt5aeeDo2ZbgRZu2UlHBwUxnRtH0SQc9lvWu5gCZdDjMYl18H0A3ni0NazyW57hz/8nd xQnL8t32H/IjWZDCCu6ZImGCxuC3sGNtH8ktf2PzoqTtn+GWuj549/lHwwVdOKTVf5GauwXnKM6F O+SB96eIsC7riXMsosH14JBSmMV1mw8y0z/a8VZKcHJ1mwxhLLTL/AJ399O8TGQZr4yk10JIIZ2B KRQaWe6wSW92OjWUnGUnMaU0QEbm63HuWqInkaseu130cNpv4Pezb5Jlh7f8JSP4RBVOYeTJtK+m PLssKcS9pU4UvLwZHxuGU+9cwz1yQQKV7lQzBQ==</SignatureValue></Signature></root>
```

**Clicar:** Add secret

---

### **3. Adicionar SECRET #2: UNITY_EMAIL**

**Name:** `UNITY_EMAIL`

**Secret:** Seu email da conta Unity (ex: `seu-email@example.com`)

**Clicar:** Add secret

---

### **4. Adicionar SECRET #3: UNITY_PASSWORD**

**Name:** `UNITY_PASSWORD`

**Secret:** Sua senha da conta Unity

**Clicar:** Add secret

---

## ? VERIFICAR SECRETS CONFIGURADOS

Após adicionar os 3 secrets, você deve ter **5 secrets** no total:

```powershell
# Abrir lista de secrets
Start-Process "https://github.com/avilaops/barbara/settings/secrets/actions"
```

**Deve ver:**
- ? `AZURE_STATIC_WEB_APPS_API_TOKEN`
- ? `AZURE_WEBAPP_PUBLISH_PROFILE`
- ? `UNITY_LICENSE` ? **NOVO**
- ? `UNITY_EMAIL` ? **NOVO**
- ? `UNITY_PASSWORD` ? **NOVO**

---

## ?? TESTAR DEPLOY COMPLETO

### **Opção A: Manual (Recomendado para primeiro teste)**

```powershell
# 1. Ir para GitHub Actions
Start-Process "https://github.com/avilaops/barbara/actions"

# 2. Clicar em "Deploy Completo - Bárbara E-commerce"
# 3. Run workflow ? Branch: main ? Run workflow
# 4. Aguardar ~15 minutos
```

### **Opção B: Automático (Push)**

```powershell
# Fazer qualquer alteração
echo "# Test Unity build" >> README.md
git add README.md
git commit -m "test: Trigger deploy completo com Unity"
git push

# Acompanhar
Start-Process "https://github.com/avilaops/barbara/actions"
```

---

## ?? O QUE VAI ACONTECER

```
JOB 1: Build API (.NET 9)      ? ~3 min ?
JOB 2: Build Unity WebGL            ? ~8 min ?? ? NOVO!
JOB 3: Deploy Static Web App      ? ~2 min ?? ? NOVO!
JOB 4: Azure Functions (skip)       ? ~1 min ??
JOB 5: Health Checks        ? ~1 min ??
JOB 6: Notificação           ? ~1 min ??

TOTAL: ~15 minutos
```

---

## ?? RESULTADO FINAL

Após o deploy, você terá:

| Componente | URL | Status |
|------------|-----|--------|
| **Frontend (Unity WebGL)** | https://barbara.avila.inc | ? Live |
| **API Backend** | https://barbara-api.azurewebsites.net | ? Live |
| **Swagger** | https://barbara-api.azurewebsites.net/swagger | ? Live |
| **Health Check** | https://barbara-api.azurewebsites.net/health | ? Live |

---

## ?? CUSTO FINAL

| Recurso | Tier | Custo |
|---------|------|-------|
| MongoDB Atlas | M0 Free | USD 0/mês |
| App Service | F1 Free | USD 0/mês |
| Static Web App | Free | USD 0/mês |
| GitHub Actions | 2000 min/mês | USD 0/mês |
| **TOTAL** | | **USD 0/mês** ?? |

---

## ?? TROUBLESHOOTING

### ? Erro: "License verification failed"

**Solução:**
1. Verificar se colou XML completo (do `<?xml` até `</root>`)
2. Não pode ter espaços extras no início/fim
3. Copiar novamente e substituir secret

### ? Erro: "Unity version mismatch"

**Sua licença:** Unity 2017.2.0  
**Projeto:** Unity 2022.3.0f1

**Solução:**
A licença Unity Personal funciona em **qualquer versão**! Não deve dar erro.
Se der, atualizar `UNITY_VERSION` no workflow.

### ? Erro: Build timeout

**Solução:**
Build Unity pode demorar. Aguarde até 20 minutos na primeira vez (cache vazio).

---

## ? CHECKLIST FINAL

- [ ] Adicionar secret `UNITY_LICENSE` (XML completo)
- [ ] Adicionar secret `UNITY_EMAIL`
- [ ] Adicionar secret `UNITY_PASSWORD`
- [ ] Verificar 5 secrets no total
- [ ] Executar workflow manual
- [ ] Aguardar ~15 minutos
- [ ] Acessar https://barbara.avila.inc
- [ ] Testar Unity WebGL

---

## ?? ESTÁ PRONTO!

**Ação imediata:**

1. **Configurar os 3 secrets** (5 min)
2. **Executar workflow manual** (1 min)
3. **Aguardar deploy** (15 min)
4. **Acessar barbara.avila.inc** ??

---

**Próxima ação:** Configurar secrets no GitHub!

```powershell
Start-Process "https://github.com/avilaops/barbara/settings/secrets/actions/new"
```

---

**Última atualização:** 2025-01-09 15:30 UTC
