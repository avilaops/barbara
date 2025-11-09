# ?? GUIA COMPLETO - CONFIGURAÇÃO GITHUB ACTIONS + AZURE

## ?? RESUMO DA CONFIGURAÇÃO

Você configurou:
- ? Azure Static Web App: `barbara-web-app`
- ? Domínio: `barbara.avila.inc` ? `thankful-rock-090169c0f.3.azurestaticapps.net`
- ? Secret GitHub: `AZURE_STATIC_WEB_APPS_API_TOKEN`
- ? Azure Function (em criação)

---

## ?? ARQUITETURA FINAL

```
???????????????????????????????????????????????????????????????
?  FRONTEND (Unity WebGL)  ?
?  https://barbara.avila.inc       ?
?  Azure Static Web App      ?
???????????????????????????????????????????????????????????????
         ?
 ??????????????????????????
           ?          ?
???????????????????????  ??????????????????????
?  API BACKEND?  ?  AZURE FUNCTIONS ?
?  .NET 9 + MongoDB   ?  ?  Serverless        ?
?  barbara-api        ?  ?  barbara-functions ?
???????????????????????  ??????????????????????
           ?
???????????????????????
?  MONGODB ATLAS      ?
?  Free M0 Tier       ?
???????????????????????
```

---

## ?? SECRETS NECESSÁRIOS NO GITHUB

Acesse: https://github.com/avilaops/barbara/settings/secrets/actions

### ? Já Configurados

| Secret | Uso | Status |
|--------|-----|--------|
| `AZURE_STATIC_WEB_APPS_API_TOKEN` | Deploy Static Web App | ? OK |
| `AZURE_WEBAPP_PUBLISH_PROFILE` | Deploy API Backend | ? OK |

### ?? A Configurar

| Secret | Como Obter | Quando Usar |
|--------|------------|-------------|
| `AZURE_FUNCTIONAPP_PUBLISH_PROFILE` | Azure Portal ? Function App ? Get publish profile | Quando criar Functions |
| `UNITY_LICENSE` | Unity Hub ? License file (.ulf) | Build Unity WebGL |
| `UNITY_EMAIL` | Email da conta Unity | Build Unity WebGL |
| `UNITY_PASSWORD` | Senha da conta Unity | Build Unity WebGL |

---

## ?? ESTRUTURA DO REPOSITÓRIO

```
barbara/
??? .github/
?   ??? workflows/
?       ??? azure-deploy.yml           # ? API Backend (simples)
?       ??? deploy-complete.yml        # ?? Deploy completo (tudo)
??? src/
?   ??? Barbara.API/         # Backend .NET 9
?   ??? Barbara.Domain/
?   ??? Barbara.Infrastructure/
??? core/     # Unity WebGL
?   ??? Assets/
?   ??? Packages/
??? api-functions/             # Azure Functions (criar)
?   ??? (arquivos .cs de functions)
??? README.md
```

---

## ?? WORKFLOWS DISPONÍVEIS

### 1?? **azure-deploy.yml** (Simples - Apenas API)

**Quando é executado:**
- Push para `main` com alterações em `src/**`
- Manualmente via GitHub Actions

**O que faz:**
1. Build da API .NET 9
2. Testes (se existirem)
3. Deploy para Azure App Service
4. Health check

**Status:** ? **Funcionando**

### 2?? **deploy-complete.yml** (Completo - Tudo)

**Quando é executado:**
- Push para `main` com alterações em `src/**`, `core/**`, `api-functions/**`
- Manualmente via GitHub Actions

**O que faz:**
1. ? Build & Deploy API Backend (.NET 9)
2. ?? Build Unity WebGL
3. ?? Deploy Unity para Static Web App
4. ? Build & Deploy Azure Functions (se existir)
5. ?? Health checks de tudo
6. ?? Relatório completo

**Status:** ? **Pronto para usar** (requer secrets Unity)

---

## ?? PASSO A PASSO - ATIVAR DEPLOY COMPLETO

### **OPÇÃO A: Usar Deploy Simples (Recomendado agora)**

? **Já está funcionando!**

O arquivo `azure-deploy.yml` já faz deploy da API automaticamente.

**Teste:**
```powershell
# Fazer qualquer alteração em src/
git add .
git commit -m "test: Testar deploy automático"
git push

# Acompanhar em:
Start-Process "https://github.com/avilaops/barbara/actions"
```

### **OPÇÃO B: Ativar Deploy Completo (Unity + API + Functions)**

#### **1. Obter Unity License**

```powershell
# No Unity Editor
# Help ? Manage License ? Manual Activation
# Salvar o arquivo .alf

# Ativar em: https://license.unity3d.com/manual
# Fazer upload do .alf
# Baixar o arquivo .ulf (license file)

# Copiar conteúdo do .ulf
Get-Content unity-license.ulf -Raw | Set-Clipboard

# Adicionar como secret:
# GitHub ? Settings ? Secrets ? Actions ? New secret
# Name: UNITY_LICENSE
# Value: (colar)
```

#### **2. Adicionar Secrets Unity**

```
UNITY_EMAIL=seu-email@example.com
UNITY_PASSWORD=sua-senha-unity
```

#### **3. Criar Pasta de Functions (opcional)**

```powershell
# Criar projeto Azure Functions
mkdir api-functions
cd api-functions
dotnet new func --name BarbaraFunctions

# Criar uma function exemplo
dotnet new function --name HelloFunction --template HttpTrigger
```

#### **4. Habilitar Workflow Completo**

```powershell
# Renomear/desabilitar o simples
git mv .github/workflows/azure-deploy.yml .github/workflows/azure-deploy.yml.disabled

# Renomear o completo
git mv .github/workflows/deploy-complete.yml .github/workflows/deploy.yml

git add .
git commit -m "feat: Ativar deploy completo com Unity WebGL"
git push
```

---

## ?? TESTAR WORKFLOWS

### **Teste Manual (Sem Push)**

```powershell
# 1. Ir para GitHub Actions
Start-Process "https://github.com/avilaops/barbara/actions"

# 2. Selecionar workflow
# 3. Clicar em "Run workflow"
# 4. Escolher branch: main
# 5. Run workflow
```

### **Teste Automático (Com Push)**

```powershell
# Fazer alteração qualquer
echo "# Test" >> README.md
git add README.md
git commit -m "test: Trigger workflow"
git push

# Acompanhar deploy
Start-Process "https://github.com/avilaops/barbara/actions"
```

---

## ?? TROUBLESHOOTING

### ? **Erro: Unity License inválida**

**Solução:**
1. Verificar se copiou o arquivo `.ulf` completo
2. Renovar licença em: https://id.unity.com/
3. Gerar novo arquivo .ulf

### ? **Erro: Publish Profile not found**

**Solução:**
```powershell
# Obter novo publish profile
az webapp deployment list-publishing-profiles `
  --resource-group barbara-rg `
  --name barbara-api `
  --xml > publish-profile.xml

# Copiar e adicionar no GitHub Secrets
Get-Content publish-profile.xml -Raw | Set-Clipboard
```

### ? **Erro: Static Web App deploy failed**

**Solução:**
1. Verificar secret `AZURE_STATIC_WEB_APPS_API_TOKEN`
2. Regenerar token no Azure Portal
3. Atualizar secret no GitHub

### ? **Erro: Unity build timeout**

**Solução:**
```yaml
# Aumentar timeout no workflow
- name: ?? Build Unity Project
  timeout-minutes: 60  # Adicionar esta linha
  uses: game-ci/unity-builder@v4
```

---

## ?? MONITORAMENTO

### **Acompanhar Deploys**

```powershell
# GitHub Actions
Start-Process "https://github.com/avilaops/barbara/actions"

# Azure Portal - API
Start-Process "https://portal.azure.com/#view/Microsoft_Azure_WApp/WebAppsMenu/~/overview/resourceId/%2Fsubscriptions%2F3b49f371-dd88-46c7-ba30-aeb54bd5c2f6%2FresourceGroups%2Fbarbara-rg%2Fproviders%2FMicrosoft.Web%2Fsites%2Fbarbara-api"

# Azure Portal - Static Web App
Start-Process "https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/Microsoft.Web%2FStaticSites"
```

### **Logs de Deploy**

```powershell
# API Logs
az webapp log tail --resource-group barbara-rg --name barbara-api

# Static Web App Logs
az staticwebapp show --name barbara-web-app --resource-group barbara-rg
```

---

## ?? PRÓXIMOS PASSOS

### **Agora (Deploy Básico)**
1. ? Workflow `azure-deploy.yml` ? Deploy automático da API
2. ? Secret `AZURE_WEBAPP_PUBLISH_PROFILE` ? Configurado
3. ? Fazer push ? Testar deploy

### **Em Breve (Deploy Completo)**
1. ? Obter Unity License
2. ? Configurar secrets Unity
3. ? Criar Azure Functions (opcional)
4. ? Ativar workflow completo

### **Futuro (Melhorias)**
1. ?? Adicionar testes automatizados
2. ?? Configurar ambientes (dev/staging/prod)
3. ?? Adicionar notificações (Discord/Slack)
4. ?? Implementar rollback automático

---

## ?? DOCUMENTAÇÃO ÚTIL

- **GitHub Actions:** https://docs.github.com/actions
- **Azure Static Web Apps:** https://docs.microsoft.com/azure/static-web-apps/
- **Unity Game CI:** https://game.ci/docs
- **Azure Functions:** https://docs.microsoft.com/azure/azure-functions/

---

## ? CHECKLIST FINAL

- [x] Repositório GitHub: avilaops/barbara
- [x] Azure Static Web App criado
- [x] Domínio configurado: barbara.avila.inc
- [x] Secret AZURE_STATIC_WEB_APPS_API_TOKEN
- [x] Secret AZURE_WEBAPP_PUBLISH_PROFILE
- [x] Workflow azure-deploy.yml (API simples)
- [x] Workflow deploy-complete.yml (completo)
- [ ] Unity License (para build WebGL)
- [ ] Azure Functions (opcional)
- [ ] Teste de deploy completo

---

**?? TUDO CONFIGURADO!**

**Próxima ação:** Fazer push e ver o deploy automático acontecer!

```powershell
git push
# Acompanhar em: https://github.com/avilaops/barbara/actions
```

---

**Última atualização:** 2025-01-09 13:00 UTC
