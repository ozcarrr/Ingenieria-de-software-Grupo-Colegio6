- LLenar appsettings.json con la conección de Axure Blol + URL del CDN y crear el esquema de MySQL

- Crear el servicio de generador de curriculum

- Solucionar error: "Solicitud de origen cruzado bloqueada: La misma política de origen no permite la lectura de recursos remotos en http://localhost:5001/api/auth/register. (Razón: Solicitud CORS no exitosa). Código de estado: (null)." 

- Posts will either be "general" (everyone can post it, it's just either text, date and/or an image/video), "event" (also text, image/video and date of event) which only organizations and schools can post, "job" (also text and image/video) which only organizations can post. We have to implement tha backend of things (both for "posting" and for the feed)