# GEMA - Sistema de Gestión de Mantenimientos

Este proyecto está compuesto por dos partes principales:
- **BackEnd**: API REST construida con Node.js, Express, TypeScript y Drizzle ORM para la gestión de base de datos PostgreSQL.
- **FrontEnd**: Aplicación multiplataforma desarrollada en Flutter.

---

## Distribución de Carpetas

```
GEMA-Frontend/
│
├── BackEnd/           # API REST y lógica de negocio
│   ├── src/
│   │   ├── controllers/   # Controladores para cada entidad
│   │   ├── routes/        # Definición de rutas/endpoints
│   │   ├── db/            # Conexión, esquemas y validaciones de base de datos
│   │   ├── utils/         # Utilidades (ej. mailer)
│   │   └── app.ts, index.ts
│   ├── supabase/          # Migraciones y snapshots de la base de datos
│   ├── package.json       # Dependencias y scripts
│   └── drizzle.config.ts  # Configuración de Drizzle ORM
│
├── FrontEnd/          # Aplicación Flutter
│   ├── lib/
│   │   ├── Components/    # Widgets reutilizables
│   │   ├── Modals/        # Modales de UI
│   │   ├── Models/        # Modelos de datos
│   │   ├── Pages/         # Páginas agrupadas por dominio
│   │   ├── Screens/       # Pantallas principales
│   │   └── Services/      # Servicios para comunicación con backend
│   ├── assets/            # Imágenes y recursos
│   ├── android/, ios/, web/, windows/, macos/, linux/   # Plataformas soportadas
│   ├── pubspec.yaml       # Dependencias y configuración Flutter
│   └── README.md
└── docs/              # Documentación adicional
```

---

## Dependencias Principales

### Backend (Node.js + TypeScript)
- express
- drizzle-orm
- postgres
- zod
- cors
- dotenv
- nodemailer
- ts-node-dev (desarrollo)
- typescript (desarrollo)

Instalación:
```bash
cd BackEnd
npm install
```

### Frontend (Flutter)
- flutter
- graphview
- http
- supabase_flutter
- flutter_dotenv
- uuid

Instalación:
```bash
cd FrontEnd
flutter pub get
```

---

## Comandos para Ejecutar el Proyecto

### Backend
1. Copia el archivo `.env` con las variables necesarias (ejemplo: `DATABASE_URL` y `PORT`).
2. Ejecuta el servidor en modo desarrollo:
   ```bash
   npm run dev
   ```
   El backend correrá por defecto en el puerto 3000 o el especificado en `.env`.

### Frontend
1. Asegúrate de tener Flutter instalado y configurado.
2. Copia el archivo `.env` con las variables de Supabase (`SUPABASE_URL`, `SUPABASE_ANON_KEY`).
3. Ejecuta la app en el dispositivo o emulador deseado:
   ```bash
   flutter run
   ```
   Puedes especificar la plataforma con los flags de Flutter (`-d chrome`, `-d windows`, etc).

---

## Migraciones y Base de Datos
- Las migraciones SQL se encuentran en `BackEnd/supabase/migrations/`.
- El esquema y validaciones están en `BackEnd/src/db/schema/`.
- Para generar nuevas migraciones, consulta la configuración en `drizzle.config.ts`.

---

## Notas Adicionales
- El backend utiliza Drizzle ORM para la gestión de la base de datos PostgreSQL.
- El frontend utiliza Supabase para autenticación y persistencia.
- Los servicios en `FrontEnd/lib/Services/` gestionan la comunicación con la API REST.
- Los controladores y rutas del backend están organizados por entidad para facilitar la escalabilidad.

---

¿Dudas? Consultar con la carpeta de drive que contiene los documentos adicionales de iteraciones anteriores del proyecto, o en su defecto con los docentes responsables.
