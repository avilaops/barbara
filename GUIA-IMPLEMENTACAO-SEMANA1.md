# ?? GUIA DE IMPLEMENTAÇÃO - Fase 1 (MVP)

## ?? Objetivo da Fase 1
Criar um **MVP funcional** do provador virtual com avatar 3D fotorrealista, recomendação de tamanho por IA e prova social com amigas.

**Prazo:** 2-3 semanas  
**Status:** ?? Pronto para iniciar

---

## ?? PRÉ-REQUISITOS

### **Ambiente de Desenvolvimento**

```bash
# Ferramentas necessárias
- Visual Studio 2022 (17.8+) ou VS Code
- .NET 9 SDK
- Node.js 20+
- Python 3.11+
- Docker Desktop
- SQL Server 2022 (ou Azure SQL)
- Redis (Docker)
- Git
```

### **Contas e APIs**

```yaml
Criar contas em:
  - Azure (para hospedagem)
  - Mercado Pago (para pagamentos)
  - Focus NFe (para notas fiscais)
  - Melhor Envio (para logística)
  - OpenAI (para IA generativa - opcional)
  
Obter API Keys:
  - Azure Storage (para blobs)
  - Azure Application Insights
- SendGrid (e-mails)
```

---

## ??? SETUP INICIAL

### **1. Configurar Banco de Dados**

```bash
# 1.1 - String de conexão
# Editar: src/Barbara.API/appsettings.json
```

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=BarbaraDB;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
```

```bash
# 1.2 - Criar migrations
cd src/Barbara.Infrastructure
dotnet ef migrations add InitialCreate --startup-project ../Barbara.API
dotnet ef database update --startup-project ../Barbara.API
```

### **2. Configurar Redis (Cache)**

```bash
# Rodar Redis via Docker
docker run -d --name barbara-redis -p 6379:6379 redis:7-alpine
```

```json
// appsettings.json
{
  "Redis": {
    "ConnectionString": "localhost:6379"
  }
}
```

### **3. Configurar Azure Blob Storage**

```json
// appsettings.json
{
"AzureStorage": {
    "ConnectionString": "DefaultEndpointsProtocol=https;AccountName=...",
    "ContainerImages": "images",
    "ContainerModels": "models",
    "ContainerDocuments": "documents"
  }
}
```

### **4. Instalar Dependências**

```bash
# Backend (ASP.NET)
cd src/Barbara.API
dotnet restore
dotnet build

# AI Services (Python)
cd ../../ai-services
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Frontend (Next.js)
cd ../../web-app
npm install
```

---

## ?? SEMANA 1: Avatar Generation + Body Detection

### **Dia 1-2: Microserviço de IA (Python)**

#### **Criar estrutura do projeto AI**

```bash
mkdir ai-services
cd ai-services
mkdir -p app/{routers,models,services,schemas}
touch app/__init__.py
touch app/main.py
```

#### **main.py**

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI(title="Barbara AI Services", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8001, reload=True)
```

#### **routers/avatar.py**

```python
from fastapi import APIRouter, File, UploadFile, HTTPException
from typing import List
import cv2
import numpy as np
from ultralytics import YOLO
import uuid
from datetime import datetime

router = APIRouter(prefix="/avatar", tags=["Avatar"])

# Carregar modelo YOLO
model = YOLO('yolov8n-pose.pt')

@router.post("/generate")
async def generate_avatar(
    front_image: UploadFile = File(...),
    side_image: UploadFile = File(...)
):
    """
    Gera avatar 3D a partir de 2 fotos (frente + lado)
    """
    try:
  # 1. Ler imagens
        front_bytes = await front_image.read()
        side_bytes = await side_image.read()
        
        front_np = np.frombuffer(front_bytes, np.uint8)
        side_np = np.frombuffer(side_bytes, np.uint8)
        
        front_img = cv2.imdecode(front_np, cv2.IMREAD_COLOR)
        side_img = cv2.imdecode(side_np, cv2.IMREAD_COLOR)
        
        # 2. Detecção de corpo com YOLO
      front_results = model(front_img)
   side_results = model(side_img)
      
        if not front_results[0].keypoints or not side_results[0].keypoints:
            raise HTTPException(400, "Corpo não detectado nas imagens")
    
     # 3. Extrair keypoints
    front_keypoints = front_results[0].keypoints.xy[0].cpu().numpy()
        side_keypoints = side_results[0].keypoints.xy[0].cpu().numpy()
        
     # 4. Calcular medidas
        measurements = calculate_measurements(
    front_img, side_img, 
            front_keypoints, side_keypoints
  )
        
        # 5. Gerar ID do avatar
     avatar_id = str(uuid.uuid4())
   
        # 6. TODO: Gerar modelo 3D (integração futura)
      # Por enquanto, retornar medidas
        
        return {
   "avatar_id": avatar_id,
          "measurements": measurements,
      "model_url": f"/models/{avatar_id}.glb",  # Placeholder
    "confidence": 0.92,
 "created_at": datetime.utcnow().isoformat()
        }
    
    except Exception as e:
  raise HTTPException(500, f"Erro ao gerar avatar: {str(e)}")


def calculate_measurements(front_img, side_img, front_kp, side_kp):
    """
    Calcula medidas do corpo baseado em keypoints
    """
    height_img = front_img.shape[0]
    
    # Keypoints YOLO (17 pontos)
    # 0: nose, 5: left_shoulder, 6: right_shoulder
    # 11: left_hip, 12: right_hip, 15: left_ankle, 16: right_ankle

    # Altura aproximada (topo da cabeça até tornozelo)
    if len(front_kp) >= 17:
    head_y = front_kp[0][1]  # nose
        ankle_y = max(front_kp[15][1], front_kp[16][1])  # ankles
        
     height_pixels = ankle_y - head_y
        # Assumir pessoa média = 165cm (calibrar depois)
        pixel_to_cm = 165 / height_pixels
        
        # Largura dos ombros
        shoulder_width_px = abs(front_kp[5][0] - front_kp[6][0])
        shoulder_width_cm = shoulder_width_px * pixel_to_cm
        
        # Largura do quadril
        hip_width_px = abs(front_kp[11][0] - front_kp[12][0])
        hip_width_cm = hip_width_px * pixel_to_cm
        
        # Cintura (aproximação - 70% da distância ombro-quadril)
    waist_cm = (shoulder_width_cm + hip_width_cm) / 2 * 0.85
        
      return {
          "altura": round(165, 1),  # Placeholder - precisa calibração
            "busto": round(shoulder_width_cm * 2.2, 1),  # Conversão para circunferência
       "cintura": round(waist_cm * 2.2, 1),
     "quadril": round(hip_width_cm * 2.5, 1),
            "manequim_estimado": estimate_size(shoulder_width_cm * 2.2, waist_cm * 2.2)
        }
    
    return None


def estimate_size(bust_cm, waist_cm):
 """Estima manequim brasileiro"""
    if bust_cm < 82:
        return "PP"
    elif bust_cm < 88:
        return "P"
  elif bust_cm < 94:
        return "M"
    elif bust_cm < 100:
        return "G"
    else:
        return "GG"


# Registrar router no main.py
# from app.routers import avatar
# app.include_router(avatar.router, prefix="/api/ai")
```

#### **requirements.txt**

```txt
fastapi==0.109.0
uvicorn[standard]==0.27.0
python-multipart==0.0.6
opencv-python==4.9.0.80
numpy==1.26.3
ultralytics==8.1.0
torch==2.1.2
torchvision==0.16.2
pillow==10.2.0
pydantic==2.5.3
```

#### **Testar AI Service**

```bash
# Instalar dependências
pip install -r requirements.txt

# Baixar modelo YOLO (primeira vez)
python -c "from ultralytics import YOLO; YOLO('yolov8n-pose.pt')"

# Rodar serviço
uvicorn app.main:app --reload --port 8001

# Testar
curl http://localhost:8001/health
```

---

### **Dia 3-4: Integração Backend com AI**

#### **Criar Controller de Avatar (ASP.NET)**

```bash
cd src/Barbara.API
mkdir Services
touch Services/IAvatarService.cs
touch Services/AvatarService.cs
```

#### **Services/IAvatarService.cs**

```csharp
namespace Barbara.API.Services;

public interface IAvatarService
{
    Task<AvatarDto> GenerateAvatarAsync(Guid clienteId, Stream frontImage, Stream sideImage);
    Task<AvatarDto?> GetAvatarAsync(Guid clienteId);
    Task UpdateMeasurementsAsync(Guid clienteId, MedidasDto medidas);
}

public class AvatarDto
{
    public Guid Id { get; set; }
    public Guid ClienteId { get; set; }
 public string ModelUrl { get; set; } = string.Empty;
    public MedidasDto Medidas { get; set; } = new();
    public double Confidence { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class MedidasDto
{
    public decimal Altura { get; set; }
    public decimal Busto { get; set; }
  public decimal Cintura { get; set; }
    public decimal Quadril { get; set; }
    public string ManequimEstimado { get; set; } = string.Empty;
}
```

#### **Services/AvatarService.cs**

```csharp
using System.Net.Http.Json;
using System.Text.Json;

namespace Barbara.API.Services;

public class AvatarService : IAvatarService
{
    private readonly HttpClient _httpClient;
private readonly IConfiguration _configuration;
    private readonly ILogger<AvatarService> _logger;

    public AvatarService(
        IHttpClientFactory httpClientFactory, 
        IConfiguration configuration,
        ILogger<AvatarService> logger)
    {
        _httpClient = httpClientFactory.CreateClient("AIService");
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<AvatarDto> GenerateAvatarAsync(
        Guid clienteId, 
        Stream frontImage, 
        Stream sideImage)
    {
   try
        {
       var content = new MultipartFormDataContent();
            content.Add(new StreamContent(frontImage), "front_image", "front.jpg");
     content.Add(new StreamContent(sideImage), "side_image", "side.jpg");

        var response = await _httpClient.PostAsync("/api/ai/avatar/generate", content);
 response.EnsureSuccessStatusCode();

            var result = await response.Content.ReadFromJsonAsync<AvatarAIResponse>();
   
            if (result == null)
                throw new Exception("AI service returned null");

            return new AvatarDto
            {
        Id = Guid.Parse(result.AvatarId),
  ClienteId = clienteId,
    ModelUrl = result.ModelUrl,
        Medidas = new MedidasDto
        {
     Altura = result.Measurements.Altura,
    Busto = result.Measurements.Busto,
         Cintura = result.Measurements.Cintura,
             Quadril = result.Measurements.Quadril,
      ManequimEstimado = result.Measurements.ManequimEstimado
       },
                Confidence = result.Confidence,
         CreatedAt = result.CreatedAt
   };
        }
  catch (Exception ex)
      {
         _logger.LogError(ex, "Erro ao gerar avatar para cliente {ClienteId}", clienteId);
       throw;
 }
    }

    public async Task<AvatarDto?> GetAvatarAsync(Guid clienteId)
    {
        // TODO: Buscar do cache/banco
        return null;
    }

    public async Task UpdateMeasurementsAsync(Guid clienteId, MedidasDto medidas)
    {
        // TODO: Atualizar medidas
    }
}

record AvatarAIResponse(
    string AvatarId,
    AvatarMeasurements Measurements,
    string ModelUrl,
    double Confidence,
    DateTime CreatedAt
);

record AvatarMeasurements(
    decimal Altura,
    decimal Busto,
    decimal Cintura,
    decimal Quadril,
    string ManequimEstimado
);
```

#### **Controllers/AvatarController.cs**

```csharp
using Barbara.API.Services;
using Microsoft.AspNetCore.Mvc;

namespace Barbara.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AvatarController : ControllerBase
{
    private readonly IAvatarService _avatarService;

  public AvatarController(IAvatarService avatarService)
    {
        _avatarService = avatarService;
    }

    [HttpPost("generate/{clienteId}")]
    public async Task<ActionResult<AvatarDto>> GenerateAvatar(
 Guid clienteId,
        [FromForm] IFormFile frontImage,
        [FromForm] IFormFile sideImage)
    {
  if (frontImage == null || sideImage == null)
     return BadRequest("Ambas as imagens são obrigatórias");

        await using var frontStream = frontImage.OpenReadStream();
     await using var sideStream = sideImage.OpenReadStream();

 var avatar = await _avatarService.GenerateAvatarAsync(
            clienteId, 
        frontStream, 
          sideStream
        );

        return Ok(avatar);
    }

    [HttpGet("{clienteId}")]
    public async Task<ActionResult<AvatarDto>> GetAvatar(Guid clienteId)
 {
        var avatar = await _avatarService.GetAvatarAsync(clienteId);
        
        if (avatar == null)
       return NotFound();

        return Ok(avatar);
    }
}
```

#### **Configurar HttpClient no Program.cs**

```csharp
// src/Barbara.API/Program.cs

// ...existing code...

// Configurar HttpClient para AI Service
builder.Services.AddHttpClient("AIService", client =>
{
    client.BaseURL = new Uri(builder.Configuration["AIService:BaseUrl"] 
     ?? "http://localhost:8001");
    client.Timeout = TimeSpan.FromSeconds(30);
});

// Registrar serviços
builder.Services.AddScoped<IAvatarService, AvatarService>();

// ...existing code...
```

#### **appsettings.json**

```json
{
  "AIService": {
    "BaseUrl": "http://localhost:8001"
  }
}
```

---

### **Dia 5-7: Frontend - Sistema de Captura**

#### **Criar componente de upload (Next.js)**

```bash
cd web-app
mkdir -p src/components/avatar
touch src/components/avatar/PhotoCapture.tsx
```

#### **PhotoCapture.tsx**

```typescript
'use client';

import { useState, useRef } from 'react';
import { Camera, Upload, Check } from 'lucide-react';

interface PhotoCaptureProps {
  onComplete: (frontPhoto: File, sidePhoto: File) => void;
}

export default function PhotoCapture({ onComplete }: PhotoCaptureProps) {
  const [frontPhoto, setFrontPhoto] = useState<File | null>(null);
  const [sidePhoto, setSidePhoto] = useState<File | null>(null);
  const [frontPreview, setFrontPreview] = useState<string | null>(null);
  const [sidePreview, setSidePreview] = useState<string | null>(null);

  const handleFileChange = (
    e: React.ChangeEvent<HTMLInputElement>,
    type: 'front' | 'side'
  ) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onloadend = () => {
      if (type === 'front') {
  setFrontPhoto(file);
        setFrontPreview(reader.result as string);
      } else {
        setSidePhoto(file);
        setSidePreview(reader.result as string);
      }
    };
    reader.readAsDataURL(file);
  };

  const handleSubmit = () => {
    if (frontPhoto && sidePhoto) {
      onComplete(frontPhoto, sidePhoto);
    }
  };

const isComplete = frontPhoto && sidePhoto;

  return (
    <div className="max-w-4xl mx-auto p-6">
      <div className="text-center mb-8">
 <h2 className="text-3xl font-bold mb-2">Crie seu Avatar 3D</h2>
      <p className="text-gray-600">
          Tire 2 fotos para criar seu avatar fotorrealista
        </p>
      </div>

      <div className="grid md:grid-cols-2 gap-6 mb-6">
        {/* Foto Frontal */}
        <div className="border-2 border-dashed border-gray-300 rounded-lg p-6">
          <div className="text-center mb-4">
     <Camera className="mx-auto h-12 w-12 text-gray-400 mb-2" />
       <h3 className="font-semibold">Foto de Frente</h3>
            <p className="text-sm text-gray-500">Braços ao lado do corpo</p>
    </div>

        {frontPreview ? (
     <div className="relative">
   <img 
  src={frontPreview} 
                alt="Preview frontal" 
     className="w-full rounded-lg"
     />
         <div className="absolute top-2 right-2 bg-green-500 text-white p-2 rounded-full">
     <Check className="h-5 w-5" />
            </div>
            </div>
          ) : (
  <label className="block">
            <input
    type="file"
      accept="image/*"
           capture="environment"
       className="hidden"
     onChange={(e) => handleFileChange(e, 'front')}
/>
         <div className="bg-gray-50 hover:bg-gray-100 cursor-pointer py-8 rounded-lg text-center transition">
  <Upload className="mx-auto h-8 w-8 text-gray-400 mb-2" />
          <span className="text-sm text-gray-600">
       Clique para tirar/enviar foto
           </span>
           </div>
    </label>
)}
    </div>

  {/* Foto Lateral */}
 <div className="border-2 border-dashed border-gray-300 rounded-lg p-6">
      <div className="text-center mb-4">
    <Camera className="mx-auto h-12 w-12 text-gray-400 mb-2" />
  <h3 className="font-semibold">Foto de Lado</h3>
            <p className="text-sm text-gray-500">Perfil esquerdo ou direito</p>
          </div>

        {sidePreview ? (
            <div className="relative">
              <img 
     src={sidePreview} 
      alt="Preview lateral" 
      className="w-full rounded-lg"
              />
            <div className="absolute top-2 right-2 bg-green-500 text-white p-2 rounded-full">
     <Check className="h-5 w-5" />
      </div>
         </div>
          ) : (
   <label className="block">
     <input
    type="file"
          accept="image/*"
capture="environment"
       className="hidden"
      onChange={(e) => handleFileChange(e, 'side')}
 />
         <div className="bg-gray-50 hover:bg-gray-100 cursor-pointer py-8 rounded-lg text-center transition">
     <Upload className="mx-auto h-8 w-8 text-gray-400 mb-2" />
         <span className="text-sm text-gray-600">
 Clique para tirar/enviar foto
      </span>
         </div>
            </label>
        )}
     </div>
      </div>

 <button
        onClick={handleSubmit}
        disabled={!isComplete}
        className={`w-full py-4 rounded-lg font-semibold text-white transition ${
  isComplete
   ? 'bg-pink-600 hover:bg-pink-700'
      : 'bg-gray-300 cursor-not-allowed'
   }`}
      >
        {isComplete ? 'Gerar Meu Avatar 3D' : 'Adicione as 2 fotos'}
 </button>

      {/* Dicas */}
      <div className="mt-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
<h4 className="font-semibold text-blue-900 mb-2">?? Dicas para melhores resultados:</h4>
        <ul className="text-sm text-blue-800 space-y-1">
  <li>? Use fundo claro e uniforme</li>
   <li>? Vista roupas justas ou fitness</li>
          <li>? Boa iluminação (natural de preferência)</li>
          <li>? Corpo inteiro visível na foto</li>
          <li>? Fique em pé, postura natural</li>
      </ul>
      </div>
    </div>
  );
}
```

#### **Página de criação do avatar**

```bash
touch src/app/avatar/create/page.tsx
```

```typescript
'use client';

import { useState } from 'react';
import PhotoCapture from '@/components/avatar/PhotoCapture';
import { useRouter } from 'next/navigation';

export default function CreateAvatarPage() {
  const [isGenerating, setIsGenerating] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  const handlePhotosComplete = async (frontPhoto: File, sidePhoto: File) => {
    setIsGenerating(true);
    setError(null);

    try {
      const formData = new FormData();
      formData.append('frontImage', frontPhoto);
      formData.append('sideImage', sidePhoto);

      // TODO: Pegar clienteId do contexto de autenticação
      const clienteId = 'temp-cliente-id';

      const response = await fetch(
   `${process.env.NEXT_PUBLIC_API_URL}/api/avatar/generate/${clienteId}`,
        {
          method: 'POST',
          body: formData,
        }
      );

      if (!response.ok) {
        throw new Error('Erro ao gerar avatar');
   }

  const avatar = await response.json();
      
 // Redirecionar para provador virtual
      router.push('/virtual-fitting');
      
 } catch (err) {
      setError('Não foi possível gerar seu avatar. Tente novamente.');
  console.error(err);
    } finally {
      setIsGenerating(false);
    }
  };

  if (isGenerating) {
    return (
      <div className="min-h-screen flex items-center justify-center">
    <div className="text-center">
    <div className="animate-spin rounded-full h-16 w-16 border-b-4 border-pink-600 mx-auto mb-4"></div>
    <h3 className="text-xl font-semibold mb-2">Criando seu avatar...</h3>
          <p className="text-gray-600">Isso pode levar alguns segundos</p>
      </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 py-12">
      {error && (
        <div className="max-w-4xl mx-auto mb-6 bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded">
          {error}
      </div>
      )}
      <PhotoCapture onComplete={handlePhotosComplete} />
    </div>
  );
}
```

---

## ? CHECKLIST SEMANA 1

- [ ] AI Service rodando em Python
- [ ] Endpoint `/api/ai/avatar/generate` funcionando
- [ ] YOLO detectando corpo nas fotos
- [ ] Medidas sendo calculadas corretamente
- [ ] Backend ASP.NET integrado com AI
- [ ] Frontend com upload de fotos
- [ ] Preview das fotos funcionando
- [ ] Validação de imagens
- [ ] Teste end-to-end completo

---

## ?? PRÓXIMOS PASSOS (Semana 2)

Na próxima semana implementaremos:
1. Renderizador 3D com Babylon.js
2. Física de tecidos básica
3. Interface de seleção de roupas
4. Sistema de cache Redis

---

**Quer que eu continue com o guia da Semana 2?** Ou tem dúvidas sobre alguma parte da Semana 1?
