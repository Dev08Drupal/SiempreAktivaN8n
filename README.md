# n8n — Local (Docker) + Deploy en Render

## Prerequisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado
- Cuenta en [Render](https://render.com) (gratis)
- Cuenta en [Nhost](https://nhost.io) para la base de datos en producción (gratis)

---

## 🚀 Inicio rápido (local)

```bash
# 1. Configura tus variables de entorno
make setup

# 2. Edita el .env con tus valores
#    Al menos cambia: POSTGRES_PASSWORD y N8N_ENCRYPTION_KEY

# 3. Levanta los servicios
make up

# 4. Abre n8n en el navegador
open http://localhost:5678
```

### Comandos disponibles

```bash
make help        # Ver todos los comandos
make up          # Levantar servicios
make down        # Detener servicios
make logs        # Ver logs en tiempo real
make logs-n8n    # Logs solo de n8n
make restart     # Reiniciar servicios
make shell       # Entrar al contenedor de n8n
make shell-db    # Entrar a PostgreSQL (psql)
make update      # Actualizar n8n a la última versión
make nuke        # Borrar TODO (¡cuidado!)
```

---

## ☁️ Deploy en Render (producción)

### Paso 1 — Base de datos en Nhost

1. Ve a [nhost.io](https://nhost.io) y crea una cuenta
2. Crea un nuevo proyecto
3. En **Settings → Database**, activa **Public Access**
4. Guarda: `host`, `port`, `user`, `password`, `database`

### Paso 2 — Crear servicio en Render

1. Ve a [render.com](https://render.com) → **New → Web Service**
2. Elige **Deploy an existing image from a registry**
3. Imagen: `docker.n8n.io/n8nio/n8n:latest`
4. Plan: **Free**
5. En **Environment Variables**, agrega:

| Variable | Valor |
|---|---|
| `DB_TYPE` | `postgresdb` |
| `DB_POSTGRESDB_HOST` | `<host de Nhost>` |
| `DB_POSTGRESDB_PORT` | `5432` |
| `DB_POSTGRESDB_DATABASE` | `<db de Nhost>` |
| `DB_POSTGRESDB_USER` | `<user de Nhost>` |
| `DB_POSTGRESDB_PASSWORD` | `<password de Nhost>` |
| `N8N_HOST` | `<tu-app>.onrender.com` |
| `N8N_PROTOCOL` | `https` |
| `WEBHOOK_URL` | `https://<tu-app>.onrender.com` |
| `N8N_ENCRYPTION_KEY` | `<misma clave que en .env local>` |
| `GENERIC_TIMEZONE` | `America/Bogota` |

6. **Deploy** 🎉

> ⚠️ **Importante**: usa la **misma `N8N_ENCRYPTION_KEY`** en local y producción.
> Si la cambias, perderás acceso a las credenciales guardadas.

### Paso 3 — Acceder a n8n en producción

Una vez desplegado, abre `https://<tu-app>.onrender.com` y crea tu cuenta de administrador.

---

## 📁 Estructura del proyecto

```
.
├── docker-compose.yml   # Entorno local (n8n + PostgreSQL)
├── .env.example         # Variables de entorno de ejemplo
├── .env                 # Variables de entorno reales (NO subir a git)
├── Makefile             # Comandos cortos
└── README.md            # Esta guía
```

---

## 🔒 Seguridad

- Nunca subas `.env` a git — agrégalo a `.gitignore`
- Genera una clave segura: `openssl rand -hex 16`
- En Render, usa siempre las variables de entorno del dashboard, no hardcodees credenciales
