.PHONY: help setup up down restart logs shell ps clean nuke

# ─── Colores ───────────────────────────────────────────────────────────────────
GREEN  := \033[0;32m
YELLOW := \033[0;33m
CYAN   := \033[0;36m
RESET  := \033[0m

help: ## 📋 Muestra esta ayuda
	@echo ""
	@echo "$(CYAN)n8n Local + Render — Comandos disponibles$(RESET)"
	@echo "─────────────────────────────────────────────"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-15s$(RESET) %s\n", $$1, $$2}'
	@echo ""

# ─── Setup ─────────────────────────────────────────────────────────────────────
setup: ## 🔧 Copia .env.example a .env (solo la primera vez)
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "$(GREEN)✔ .env creado. Edítalo con tus valores antes de continuar.$(RESET)"; \
	else \
		echo "$(YELLOW)⚠ .env ya existe, no se sobreescribió.$(RESET)"; \
	fi

# ─── Ciclo de vida ─────────────────────────────────────────────────────────────
up: ## 🚀 Levanta n8n + PostgreSQL en background
	@echo "$(CYAN)Iniciando servicios...$(RESET)"
	docker compose up -d
	@echo "$(GREEN)✔ n8n disponible en http://localhost:5678$(RESET)"

down: ## 🛑 Detiene los contenedores (datos persistidos)
	docker compose down

restart: ## 🔄 Reinicia todos los servicios
	docker compose restart

# ─── Monitoreo ─────────────────────────────────────────────────────────────────
logs: ## 📜 Muestra logs en tiempo real
	docker compose logs -f

logs-n8n: ## 📜 Logs solo de n8n
	docker compose logs -f n8n

logs-db: ## 📜 Logs solo de PostgreSQL
	docker compose logs -f postgres

ps: ## 📊 Estado de los contenedores
	docker compose ps

# ─── Acceso ────────────────────────────────────────────────────────────────────
shell: ## 🐚 Abre una shell dentro del contenedor de n8n
	docker compose exec n8n sh

shell-db: ## 🐚 Abre psql dentro de PostgreSQL
	docker compose exec postgres psql -U $${POSTGRES_USER:-n8n} -d $${POSTGRES_DB:-n8n}

# ─── Limpieza ──────────────────────────────────────────────────────────────────
clean: ## 🧹 Detiene y elimina contenedores (mantiene volúmenes/datos)
	docker compose down --remove-orphans

nuke: ## 💥 Elimina TODO incluyendo datos (¡irreversible!)
	@echo "$(YELLOW)⚠ Esto borrará todos los datos de n8n y PostgreSQL.$(RESET)"
	@read -p "¿Estás seguro? (escribe 'si' para confirmar): " confirm; \
	if [ "$$confirm" = "si" ]; then \
		docker compose down -v --remove-orphans; \
		echo "$(GREEN)✔ Todo eliminado.$(RESET)"; \
	else \
		echo "Cancelado."; \
	fi

# ─── Actualización ─────────────────────────────────────────────────────────────
update: ## ⬆️ Actualiza la imagen de n8n a la última versión
	docker compose pull n8n
	docker compose up -d n8n
	@echo "$(GREEN)✔ n8n actualizado.$(RESET)"
