# ?? WORKFLOWS GITHUB ACTIONS - GUIA DEFINITIVO

## ?? SITUAÇÃO ATUAL

Você tem **5 workflows** no repositório:

| Workflow | Status | Uso | Ação |
|----------|--------|-----|------|
| **azure-deploy.yml** | ? **Ativo** | Deploy API .NET simples | **MANTER** |
| **deploy-complete.yml** | ? **Ativo** | Deploy completo (tudo) | **MANTER** |
| **api-ci.yml** | ? **Obsoleto** | Testes Node.js antigos | **DELETAR** |
| **ci.yml** | ? **Obsoleto** | CI Node.js duplicado | **DELETAR** |
| **unity-webgl.yml** | ?? **Redundante** | Unity build (já no deploy-complete) | **DELETAR** |

---

## ? WORKFLOWS CORRETOS (Manter)

### 1. **azure-deploy.yml** - Deploy Simples API

**Arquivo:** `.github/workflows/azure-deploy.yml`

**O que faz:**
1. ? Build da API .NET 9
2. ? Testes (se existirem)
3. ? Deploy para Azure App Service
4. ? Health check

**Quando executa:**
- Push para `main` com alterações em `src/**`
- Manualmente via GitHub Actions

**Por que manter:**
- ? Simples e rápido (~3-5 min)
- ? Foca apenas na API
- ? Não depende de Unity License
- ? Ideal para desenvolvimento rápido

**Status:** ? **FUNCIONANDO PERFEITAMENTE**

---

### 2. **deploy-complete.yml** - Deploy Completo

**Arquivo:** `.github/workflows/deploy-complete.yml`

**O que faz:**
1. ? Build & Deploy API .NET 9
2. ?? Build Unity WebGL
3. ?? Deploy Unity para Static Web App
4. ? Build & Deploy Azure Functions (opcional)
5. ?? Health checks completos
6. ?? Relatório detalhado

**Quando executa:**
- Push para `main` com alterações em `src/**`, `core/**`, `api-functions/**`
- Manualmente via GitHub Actions

**Por que manter:**
- ? Workflow completo e profissional
- ? Integra todos os componentes
- ? Deploy automático de tudo
- ? Ideal para releases

**Status:** ? **PRONTO** (requer Unity License para Unity build)

---

## ? WORKFLOWS OBSOLETOS (Deletar)

### 1. **api-ci.yml** - Node.js Antigo

**Arquivo:** `.github/workflows/api-ci.yml`

**Problema:**
```yaml
working-directory: api  # ? Pasta Node.js que NÃO EXISTE MAIS!
node-version: 20
npm ci
npm test
```

**Por que deletar:**
- ? Projeto migrou de Node.js para .NET 9
- ? Pasta `api/` contém código antigo não usado
- ? Workflow nunca vai executar com sucesso
- ? Confunde a visualização no GitHub Actions

---

### 2. **ci.yml** - Node.js Duplicado

**Arquivo:** `.github/workflows/ci.yml`

**Problema:**
```yaml
working-directory: api  # ? Mesma coisa!
npm install
npm test
```

**Por que deletar:**
- ? Duplicado do `api-ci.yml`
- ? Mesmo problema (Node.js antigo)
- ? Redundante e confuso

---

### 3. **unity-webgl.yml** - Consolidado

**Arquivo:** `.github/workflows/unity-webgl.yml`

**Problema:**
```yaml
# Faz build Unity WebGL
# MAS não faz deploy!
# Apenas cria artifact
```

**Por que deletar:**
- ?? Funcionalidade já está no `deploy-complete.yml`
- ?? Incompleto (não faz deploy)
- ?? Redundante

**Alternativa:**
- O `deploy-complete.yml` já faz build **E** deploy do Unity

---

## ?? QUAL USAR?

### **DESENVOLVIMENTO (Dia a dia)**

Use: **azure-deploy.yml**

```powershell
# Fazer alteração na API
git add src/
git commit -m "feat: Nova funcionalidade"
git push

# Workflow azure-deploy.yml executa automaticamente
# ~3-5 minutos para deploy
```

**Vantagens:**
- ? Rápido
- ? Não precisa Unity License
- ? Foca na API

---

### **RELEASE (Deploy completo)**

Use: **deploy-complete.yml**

**Opção A: Automático**
```powershell
# Alterar Unity ou API
git add core/ src/
git commit -m "release: v1.0.0"
git push

# Workflow deploy-complete.yml executa
# ~10-15 minutos para tudo
```

**Opção B: Manual**
```powershell
# GitHub ? Actions ? deploy-complete.yml ? Run workflow
```

**Requer:**
- `UNITY_LICENSE` secret
- `UNITY_EMAIL` secret
- `UNITY_PASSWORD` secret

---

## ?? COMO LIMPAR

### **Método 1: Script Automático (Recomendado)**

```powershell
# Executar script
.\cleanup-workflows.ps1

# Confirmar com "S"
# Commit e push
git push
```

### **Método 2: Manual**

```powershell
# Deletar workflows obsoletos
git rm .github/workflows/api-ci.yml
git rm .github/workflows/ci.yml
git rm .github/workflows/unity-webgl.yml

# Commit
git commit -m "chore: Remover workflows obsoletos Node.js"

# Push
git push
```

---

## ?? RESULTADO APÓS LIMPEZA

### **Antes (5 workflows):**
```
.github/workflows/
??? azure-deploy.yml      ? Ativo
??? deploy-complete.yml   ? Ativo
??? api-ci.yml    ? Obsoleto
??? ci.yml                ? Obsoleto
??? unity-webgl.yml    ?? Redundante
```

### **Depois (2 workflows):**
```
.github/workflows/
??? azure-deploy.yml   ? Deploy simples API
??? deploy-complete.yml   ? Deploy completo
```

**Benefícios:**
- ? Menos confusão
- ? Workflows organizados
- ? Histórico limpo no GitHub Actions
- ? Foco nos workflows corretos

---

## ?? QUANDO USAR CADA UM?

| Situação | Workflow | Tempo |
|----------|----------|-------|
| **Fix de bug na API** | azure-deploy.yml | ~3 min |
| **Nova feature na API** | azure-deploy.yml | ~3 min |
| **Atualização Unity** | deploy-complete.yml | ~10 min |
| **Release completa** | deploy-complete.yml | ~15 min |
| **Hotfix urgente** | azure-deploy.yml | ~3 min |

---

## ?? VERIFICAR WORKFLOWS ATIVOS

### **GitHub Interface:**

1. Ir para: https://github.com/avilaops/barbara/actions
2. Ver workflows na sidebar esquerda
3. **Após limpeza, verá apenas 2:**
   - ?? Deploy Bárbara MongoDB to Azure
   - ?? Deploy Completo - Bárbara E-commerce

### **Via CLI:**

```powershell
# Listar workflows
gh workflow list

# Ver runs recentes
gh run list --limit 10

# Ver status
gh run view
```

---

## ? CHECKLIST DE LIMPEZA

- [ ] Executar `cleanup-workflows.ps1`
- [ ] Confirmar deleção dos 3 workflows obsoletos
- [ ] Commit: `chore: Remover workflows obsoletos`
- [ ] Push para GitHub
- [ ] Verificar GitHub Actions (deve ter apenas 2 workflows)
- [ ] Testar `azure-deploy.yml` com um push
- [ ] Documentar no README

---

## ?? RESUMO EXECUTIVO

### **SITUAÇÃO:**
- 5 workflows (3 obsoletos, 2 ativos)
- Workflows Node.js não funcionam (projeto migrou para .NET)
- Unity build duplicado

### **AÇÃO:**
- ? Deletar 3 workflows obsoletos
- ? Manter 2 workflows ativos
- ? Limpar histórico

### **RESULTADO:**
- 2 workflows organizados
- Deploy simplificado
- Sem confusão

---

## ?? CONCLUSÃO

**Workflows corretos:**
1. ? `azure-deploy.yml` - Deploy rápido da API
2. ? `deploy-complete.yml` - Deploy completo

**Workflows para deletar:**
1. ? `api-ci.yml` - Node.js antigo
2. ? `ci.yml` - Node.js duplicado
3. ? `unity-webgl.yml` - Redundante

**Próxima ação:**
```powershell
.\cleanup-workflows.ps1
```

---

**Última atualização:** 2025-01-09 14:00 UTC
