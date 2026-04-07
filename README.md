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

### Base de datos

La base de datos relacional esta definida bajo los siguientes campos:
_
| **Entidad**        | **Campos Clave**                                 | **Importancia en Kairos**                                                                                                                |
| ------------------ | ------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| **User**           | `Id`, `Role`, `Institution`, `PasswordHash`      | El corazón del sistema. Maneja tres perfiles (estudiante, empresa, backoffice) bajo una misma estructura, permitiendo una red unificada. |
| **Post**           | `Content`, `Type`, `LikesCount`, `CommentsCount` | Motor de interacción social. Permite a los estudiantes mostrar sus proyectos y a los liceos publicar eventos técnicos.                   |
| **JobPosting**     | `Title`, `Location`, `Status`, `CompanyId`       | Representa las ofertas de práctica o empleo. Es el puente directo entre la necesidad de la empresa y el talento técnico.                 |
| **JobApplication** | `Status`, `CvUrl`, `JobId`, `ApplicantId`        | Gestiona el proceso de postulación. Almacena el link al CV generado automáticamente, facilitando la revisión para la empresa.            |
| **UserActivity**   | `ActivityType`, `Description`, `UserId`          | **Diferenciador clave:** Registra acciones (como "Post creado" o "Práctica aplicada") para alimentar el generador de CV automático.      |
| **Follow**         | `FollowerId`, `FollowedId`                       | Habilita la red de contactos, permitiendo que estudiantes sigan a empresas de su interés y viceversa.                                    |
| **Comment / Like** | `Content`, `PostId`, `AuthorId`                  | Fomentan el engagement y la validación social de los proyectos publicados por los alumnos.                                               |
##### ¿Por qué no normalizamos al 100%?

Con 600 usuarios, la diferencia de performance entre 3FN estricta
y lo que tenemos es imperceptible. Lo que sí hicimos:

- **Contadores desnormalizados** (`LikesCount`, `CommentsCount` en Post):
  evitan un `COUNT(*)` en cada carga del feed.
- **Enums como string** en la BD: más fácil de leer en MySQL Workbench
  y de debuggear cuando algo falla.
- **Índices compuestos** en las columnas que se usan juntas en las queries
  más frecuentes (feed, actividades de usuario, postulaciones por oferta).

##### ¿Por qué clave compuesta en Like y Follow?

La BD garantiza a nivel de constraint que un usuario no puede
dar like dos veces o seguirse a sí mismo. No depende de que
el código lo valide correctamente — MySQL lo rechaza directamente.

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
## Logic Diagram

<img width="1440" height="1016" alt="imagen" src="https://github.com/user-attachments/assets/6a28e10a-7f14-403d-bc21-bc9acdae0733" />

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
