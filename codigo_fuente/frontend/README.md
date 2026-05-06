# Kairos — Frontend (Flutter)

Aplicación web/desktop construida en **Flutter (Material 3)** para la plataforma social **Kairos**, orientada a estudiantes técnicos, egresados, empresas y docentes.

---

## Tabla de contenidos

1. [Requisitos](#requisitos)
2. [Instalación](#instalación)
3. [Ejecutar la app](#ejecutar-la-app)
4. [Estructura del proyecto](#estructura-del-proyecto)
5. [Pantallas](#pantallas)
6. [Sistema de roles](#sistema-de-roles)
7. [Tema y diseño](#tema-y-diseño)
8. [API Client](#api-client)
9. [Chat en tiempo real (SignalR)](#chat-en-tiempo-real-signalr)
10. [Dependencias principales](#dependencias-principales)

---

## Requisitos

| Herramienta | Versión mínima |
|---|---|
| Flutter SDK | 3.11.4 |
| Dart SDK | 3.x |
| Navegador | Firefox, Chrome, Edge |

> No se requiere Xcode ni Android Studio para correr en web o desktop Linux.

---

## Instalación

```bash
# 1. Clonar el repositorio y entrar a la carpeta
cd frontend

# 2. Instalar dependencias
flutter pub get
```

---

## Ejecutar la app

### Web (cualquier navegador)
```bash
flutter run -d web-server --web-port 8080
```
Luego abrir `http://localhost:8080` en el navegador.

### Desktop Linux
```bash
flutter run -d linux
```

### Web con hot-reload
```bash
flutter run -d chrome
# o con Firefox vía web-server como se indica arriba
```

---

## Estructura del proyecto

```
lib/
├── main.dart                        # Punto de entrada, routing y AppShell
│
├── core/
│   ├── api/
│   │   └── api_client.dart          # Cliente HTTP (Dio) con JWT interceptor
│   ├── data/
│   │   └── mock_data.dart           # Datos de prueba (usuarios, posts, jobs, chats)
│   ├── models/
│   │   └── user_profile.dart        # UserProfile, UserRole, SoftSkill, SocioemotionalTest
│   ├── services/
│   │   ├── chat_hub_service.dart    # SignalR — mensajes en tiempo real
│   │   └── social_hub_service.dart  # SignalR — notificaciones sociales (legado)
│   ├── state/
│   │   └── user_role_controller.dart # ChangeNotifier para cambio de rol demo
│   ├── theme/
│   │   ├── kairos_palette.dart      # Colores del sistema de diseño
│   │   ├── app_theme.dart           # ThemeData Material 3 (Manrope, rounded)
│   │   └── app_colors.dart          # Alias de KairosPalette (compatibilidad)
│   └── widgets/
│       ├── app_shell.dart           # Navegación responsive (top nav / bottom nav)
│       ├── k_card.dart              # Tarjeta base del sistema de diseño
│       └── post_card.dart           # Tarjeta de publicación con like toggle
│
└── features/
    ├── auth/
    │   └── presentation/pages/
    │       └── login_page.dart      # Pantalla de inicio de sesión
    ├── home/
    │   ├── data/models/
    │   │   └── post_model.dart      # PostModel
    │   └── presentation/
    │       ├── pages/home_page.dart # Feed principal (3 columnas en desktop)
    │       └── widgets/             # ProfileCard, PostCreatorCard, FeedPostCard, etc.
    ├── jobs/
    │   ├── data/models/
    │   │   └── job_model.dart       # JobModel, OpportunityType
    │   └── presentation/pages/
    │       └── jobs_page.dart       # Bolsa de trabajo con filtros
    ├── network/
    │   └── presentation/pages/
    │       └── network_page.dart    # Red de contactos
    ├── chat/
    │   ├── data/models/
    │   │   └── chat_model.dart      # ChatPreview, ChatMessage
    │   └── presentation/pages/
    │       └── chats_page.dart      # Mensajería en tiempo real vía SignalR
    └── profile/
        └── presentation/pages/
            └── profile_page.dart    # Perfil, test socioemocional, proyectos, reporte PDF
```

---

## Pantallas

### Home — Feed principal
- Layout de 3 columnas en desktop (perfil resumen | feed | sugerencias).
- Creador de publicaciones con selector de tipo (post normal u oferta laboral para empresas).
- Feed de posts con like toggle, contadores y cabecera de evento.
- Sección de habilidades en tendencia y oficios destacados en la columna derecha.

### Jobs — Bolsa de trabajo
- Filtros por tipo (`Práctica` / `Trabajo`) y especialización.
- Tarjetas de estadísticas (total de ofertas, prácticas disponibles, etc.).
- Lista de ofertas con botones Guardar / Postular.
- Banner "Automatiza tu CV" para generación PDF.

### Network — Red de contactos
- Buscador de personas.
- Grid responsive de tarjetas con Conectar / Desconectar.
- Estadísticas de conexiones.

### Chat — Mensajería
- Lista de conversaciones con buscador y punto de no leído.
- Panel de chat con historial de mensajes (burbujas isMine/peer).
- Integración SignalR: mensajes y tipeo en tiempo real.
- Indicador de escritura animado (`"X está escribiendo..."`).
- Indicador de estado online cuando el hub está conectado.

### Profile — Perfil
- Header con banner degradado, avatar con carga a Azure Blob.
- Contadores (conexiones, visitas, publicaciones).
- Sección de evaluación socioemocional con barras de progreso y badges.
- Habilidades técnicas, experiencia, certificaciones y grid de proyectos destacados.
- Descarga de reporte PDF mensual (`GET /api/reports/me`).

---

## Sistema de roles

La app incluye un selector de rol para demostración, accesible desde el menú del avatar en `AppShell`.

| Rol | Valor | Diferencias de UI |
|---|---|---|
| Estudiante | `student` | Vista estándar del feed |
| Egresado | `alumni` | Mismo feed, badge diferente |
| Docente / Staff | `staff` | Acceso a funciones educativas |
| Empresa | `company` | Botón "Oferta laboral" en feed, pestaña Jobs con modo empleador |

El cambio de rol reconstruye toda la UI vía `UserRoleController extends ChangeNotifier` + `AnimatedBuilder` en `main.dart`.

---

## Tema y diseño

### KairosPalette

| Token | Color | Uso |
|---|---|---|
| `primary` | `#0F766E` | Botones principales, acentos |
| `accent` | `#00B5AD` | Hover, badges, chips |
| `background` | `#F8FAFC` | Fondo de página |
| `border` | `#E2E8F0` | Bordes de tarjetas |
| `muted` | `#E8F3EF` | Fondos secundarios |
| `foreground` | `#1E293B` | Texto principal |
| `secondary` | `#64748B` | Texto secundario |

### Tipografía
Fuente **Manrope** (Google Fonts) con pesos 400–900.

### KCard
Componente base de tarjeta con sombra, borde, radio de 18px y soporte para gradiente opcional. Todos los módulos lo usan como contenedor principal.

---

## API Client

`lib/core/api/api_client.dart` usa **Dio** con:
- Token JWT leído de `FlutterSecureStorage` e inyectado en cada request.
- Base URL configurable (default: `http://localhost:5000`).

| Método | Endpoint | Descripción |
|---|---|---|
| `login(email, password)` | `POST /api/auth/login` | Autenticación, devuelve JWT |
| `register(...)` | `POST /api/auth/register` | Registro de usuario |
| `getFeed(page)` | `GET /api/posts/feed` | Feed paginado |
| `createPost(content)` | `POST /api/posts` | Nueva publicación |
| `uploadFile(path, mime)` | `POST /api/storage/upload` | Sube imagen a Azure Blob |
| `downloadReport(month, year)` | `GET /api/reports/me` | Descarga reporte PDF |

---

## Chat en tiempo real (SignalR)

`lib/core/services/chat_hub_service.dart` conecta al hub `ChatHub` del backend en `/hubs/chat`.

### Ciclo de vida de una conversación

```
1. connect()                          → conectar al hub
2. joinConversation(myId, peerId)     → entrar al grupo de conversación
3. onMessage.listen(...)              → escuchar mensajes entrantes
4. sendMessage(myId, peerId, texto)   → enviar mensaje (el hub hace echo a ambos)
5. sendTyping(myId, peerId)           → notificar que se está escribiendo
6. leaveConversation(myId, peerId)    → salir del grupo al cambiar de chat
7. dispose()                          → cerrar conexión
```

### Eventos del servidor

| Evento | Payload | Descripción |
|---|---|---|
| `ReceiveMessage` | `{ senderId, content, timestamp }` | Mensaje nuevo |
| `UserTyping` | `{ senderId }` | El peer está escribiendo |

### Reconexión automática
Política de reintentos: `[2 s, 5 s, 10 s, 30 s]`. Si el backend no está disponible al iniciar, el chat funciona en modo offline (mensajes locales).

---

## Dependencias principales

| Paquete | Uso |
|---|---|
| `google_fonts` | Tipografía Manrope |
| `dio` | Cliente HTTP con interceptores |
| `signalr_netcore` | Cliente SignalR para el ChatHub |
| `image_picker` | Selección de avatar desde galería |
| `file_picker` | Selección de archivos genéricos |
| `flutter_pdfview` | Previsualización de PDF |
| `flutter_riverpod` | State management (disponible, aún no usado globalmente) |
| `flutter_secure_storage` | Persistencia segura del JWT |
| `path_provider` | Rutas del sistema de archivos |
