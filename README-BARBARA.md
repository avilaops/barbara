# ?? Barbara - E-commerce com Provador Virtual 3D e IA

**Status:** ? Fundação (30%) | ? MVP em desenvolvimento  
**Tech Stack:** ASP.NET Core 9 + Python AI + Next.js + Babylon.js  
**Diferencial:** Avatar fotorrealista + Precisão 90%+ tamanho = -70% devoluções

---

## ? Quick Start (5 minutos)

```bash
# 1. Criar banco de dados
cd src/Barbara.Infrastructure
dotnet ef database update --startup-project ../Barbara.API

# 2. Rodar API
cd ../Barbara.API
dotnet run

# 3. Testar
# Abrir: https://localhost:7001/swagger
```

**? Pronto!** API rodando com 4 controllers + Swagger interativo

---

## ?? Status Atual

### ? **Implementado**
- Estrutura Clean Architecture
- 12 entidades (Cliente, Produto, Pedido, Pagamento, NFe, Envio)
- 4 Controllers REST completos
- EF Core + SQL Server
- Swagger/OpenAPI

### ? **Em Desenvolvimento (Semana 1-3)**
- AI Service (YOLO + avatar generation)
- Frontend Next.js
- Provador virtual 3D
- ML para tamanho

---

## ?? API Endpoints

```http
# Produtos
GET/POST/PUT/DELETE /api/produtos

# Categorias  
GET/POST /api/categorias

# Clientes
GET/POST/PUT /api/clientes
GET/PUT /api/clientes/{id}/medidas

# Carrinho
GET/POST/PUT/DELETE /api/carrinho/*
```

**Docs:** https://localhost:7001/swagger

---

## ?? Estrutura

```
src/
??? Barbara.Domain/ # Entidades
??? Barbara.Infrastructure/  # EF Core + DB
??? Barbara.API/  # Controllers + DTOs
??? Barbara.Web/  # UI (futuro)

ai-services/    # Python + YOLO (Semana 1)
web-app/        # Next.js (Semana 1)
```

---

## ?? Documentação

- **[ROADMAP.md](./ROADMAP.md)** - Roadmap completo (6 meses)
- **[ARQUITETURA.md](./ARQUITETURA.md)** - Stack técnica
- **[GUIA-IMPLEMENTACAO-SEMANA1.md](./GUIA-IMPLEMENTACAO-SEMANA1.md)** - Tutorial IA

---

## ?? Próximos Passos

1. ? Setup do banco ? FEITO
2. ? Implementar AI Service (Python)
3. ? Gerar avatar 3D
4. ? Renderizador WebGPU

**Siga:** [GUIA-IMPLEMENTACAO-SEMANA1.md](./GUIA-IMPLEMENTACAO-SEMANA1.md)

---

**Barbara E-commerce** © 2025 | Ribeirão Preto, SP
