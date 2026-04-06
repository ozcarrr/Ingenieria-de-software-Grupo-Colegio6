# Kairos

Red social para estudiantes técnico-profesionales. Conecta alumnos con oportunidades laborales, prácticas profesionales y comunidades de su área.

---

## Stack tecnológico

| Capa | Tecnología |
|---|---|
| Frontend | Flutter (web + mobile) |
| Backend | .NET 8 — Clean Architecture |
| Base de datos | MySQL 8.0 via Pomelo EF Core |
| Almacenamiento | Azure Blob Storage + Azure CDN |
| Tiempo real | ASP.NET Core SignalR |
| Generación PDF | QuestPDF |
| Autenticación | JWT Bearer (HS256) |

---

## Estructura del repositorio

```
/
├── backend/
│   ├── Kairos.sln
│   └── src/
│       ├── Kairos.Domain/          # Entidades de dominio
│       ├── Kairos.Application/     # Casos de uso (CQRS + MediatR)
│       ├── Kairos.Infrastructure/  # DB, Storage, PDF, JWT
│       └── Kairos.API/             # Controllers, SignalR Hub, Middleware
└── frontend/
    └── lib/
        ├── core/
        │   ├── api/                # ApiClient (Dio)
        │   ├── services/           # SocialHubService (SignalR)
        │   └── theme/              # AppColors
        └── features/
            ├── auth/               # Login
            ├── home/               # Feed + widgets
            ├── profile/            # Perfil de usuario
            ├── jobs/               # Ofertas laborales
            ├── network/            # Red de contactos
            └── chat/               # Mensajería
```

---

## Backend — Estado actual

### Dominio (`Kairos.Domain`) 

Hay que modificar las entidades en base a lo que usemos para la base dedatos en MySQL

| Entidad | Campos clave |
|---|---|
| `User` | Id, Username, Email, PasswordHash, FullName, Bio, ProfilePictureUrl, Institution |
| `Post` | Id, Content, Type (Regular/Event), ImageUrl, EventDate, LikesCount, CommentsCount, AuthorId |
| `UserActivity` | Id, UserId, ActivityType, Description, CreatedAt |

### Application — CQRS handlers implementados

| Feature | Comando / Query |
|---|---|
| Auth | `LoginCommand`, `RegisterCommand` (con FluentValidation) |
| Feed | `GetFeedQuery` (paginación por offset), `CreatePostCommand` |
| Storage | `UploadFileCommand` → delega a `IStorageService` |

#### Todo
| Curriculum | `GenerateCurriculumCommand` → agrega actividades y delega a `ICurriculumGeneratorService` |

### Infrastructure — Servicios implementados

| Servicio | Descripción |
|---|---|
| `ApplicationDbContext` | EF Core + Pomelo MySQL. Configuraciones de índices, longitudes y cascadas. |
| `StorageService` | Sube archivos a Azure Blob Storage y retorna la URL del CDN. |
| `JwtService` | Emite tokens JWT HS256 con claims de userId, email y fullName. |

#### Todo
| `CurriculumGenerator` | Estructura creada con QuestPDF. **Implementación pendiente.** |

### API — Endpoints disponibles

| Método | Ruta | Descripción |
|---|---|---|
| POST | `/api/auth/register` | Registro de usuario |
| POST | `/api/auth/login` | Login → retorna JWT |
| GET | `/api/posts/feed` | Feed paginado (`?page=1&pageSize=20`) |
| POST | `/api/posts` | Crear publicación |
| POST | `/api/storage/upload` | Subir imagen/video a Azure Blob (max 50 MB) |

#### Todo
| GET | `/api/curriculum/me` | Descargar curriculum PDF |

### SignalR Hub — `/hubs/social`

| Método (cliente → servidor) | Descripción |
|---|---|
| `JoinPostComments(postId)` | Unirse al grupo de comentarios de un post |
| `LeavePostComments(postId)` | Salir del grupo |
| `SendComment(postId, content)` | Enviar comentario en tiempo real |
| `SendTyping(postId)` | Indicador "está escribiendo..." |

| Evento (servidor → cliente) | Descripción |
|---|---|
| `ReceiveLike` | Notificación de like en una publicación propia |
| `ReceiveFollow` | Notificación de nuevo seguidor |
| `ReceiveComment` | Nuevo comentario en un post que se está viendo |
| `UserTyping` | Alguien está escribiendo en los comentarios |

---

## Frontend — Estado actual

### Pantallas implementadas

| Pantalla | Archivo | Estado |
|---|---|---|
| Login | `auth/presentation/pages/login_page.dart` | UI completa. Navegación mock (TODO: conectar a `ApiClient`). |
| Home / Feed | `home/presentation/pages/home_page.dart` | UI con datos mock. Banner de notificaciones en tiempo real (SignalR). `_connectHub(jwt)` listo para llamar post-login. |
| Perfil | `profile/presentation/pages/profile_page.dart` | Edición de datos. Subida de avatar a Azure Blob via `ApiClient`. Botón de descarga de reporte PDF. |
| Red | `network/presentation/pages/network_page.dart` | UI con datos mock. |
| Empleos | `jobs/presentation/pages/jobs_page.dart` | UI con datos mock. |
| Chats | `chat/presentation/pages/chats_page.dart` | UI con datos mock. |

### Servicios core

| Servicio | Archivo | Descripción |
|---|---|---|
| `ApiClient` | `core/api/api_client.dart` | Cliente Dio con interceptor JWT (token guardado en `FlutterSecureStorage`). Métodos para auth, feed, storage y reportes. |
| `SocialHubService` | `core/services/social_hub_service.dart` | Conexión SignalR con política de reconexión automática. Expone `Stream` para likes, follows, comentarios y typing. |

### Dependencias Flutter (`pubspec.yaml`)

```
dio, signalr_netcore, image_picker, file_picker,
flutter_pdfview, flutter_riverpod, flutter_secure_storage, path_provider
```

---

## Configuración — Lo que falta para levantar el proyecto

### 1. Base de datos MySQL

Crear la base de datos y ejecutar las migraciones una vez instalado .NET 8:

```bash
cd backend
dotnet ef migrations add Init --project src/Kairos.Infrastructure --startup-project src/Kairos.API
dotnet ef database update --startup-project src/Kairos.API
```

### 2. `appsettings.json`

Completar los valores reales en `backend/src/Kairos.API/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=...;Database=kairos;User=...;Password=...;"
  },
  "Jwt": {
    "SecretKey": "mínimo 32 caracteres aleatorios"
  },
  "AzureBlob": {
    "ConnectionString": "DefaultEndpointsProtocol=https;AccountName=...;AccountKey=...;",
    "ContainerName": "kairos-media",
    "CdnBaseUrl": "https://TU_ENDPOINT.azureedge.net/kairos-media"
  }
}
```

Para desarrollo local con Azurite (emulador de Blob): `appsettings.Development.json` ya tiene `UseDevelopmentStorage=true`.

### 3. Frontend — URL del API

Cambiar la URL base en `frontend/lib/core/api/api_client.dart`:

```dart
static const _baseUrl = 'https://TU_API.azurewebsites.net/api';
```

---

## Pendiente

- [ ] Implementar el cuerpo de `CurriculumGenerator` (generador de CV en PDF con QuestPDF)
- [ ] Conectar `LoginPage` al `ApiClient` y llamar a `_connectHub(jwt)` tras login exitoso
- [ ] Reemplazar datos mock del Feed, Jobs, Network y Chats con llamadas reales a la API
- [ ] Integrar Riverpod como state management (providers para auth, feed, perfil)
- [ ] Implementar vista de previsualización PDF con `flutter_pdfview`
- [ ] Crear migración inicial de EF Core y aplicarla a MySQL
- [ ] Configurar Azure CDN (Front Door recomendado para escala global + WAF)

---

## Nota sobre CDN

Para producción se recomienda **Azure Front Door** sobre Azure CDN estándar: ofrece SSL offloading, WAF integrado y mejor rendimiento global para assets de alta demanda (imágenes y videos del feed).
