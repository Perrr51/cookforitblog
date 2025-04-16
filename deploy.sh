#!/bin/bash

# Configuración
REPO_URL="git@github.com:Perrr51/cookforitblog.git"
BRANCH_MAIN="master"
BRANCH_HOSTINGER="hostinger"
PUBLIC_DIR="public"
COMMIT_MSG="Actualización automática del sitio Hugo $(date +'%Y-%m-%d %H:%M:%S')"
GITIGNORE_FILE=".gitignore"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Función para errores
handle_error() {
    echo -e "${RED}Error: $1${NC}"
    exit 1
}

# --- PASO 0: Configuración inicial ---
echo -e "${GREEN}Verificando configuración de Git...${NC}"
git config --global pull.rebase false  # Estrategia merge como predeterminada
git remote set-url origin "$REPO_URL" || git remote add origin "$REPO_URL"

# --- PASO 1: Manejo de .gitignore ---
echo -e "${GREEN}Verificando .gitignore...${NC}"
if ! grep -q ".obsidian/workspace.json" "$GITIGNORE_FILE"; then
    echo -e "${GREEN}Añadiendo .obsidian/workspace.json a .gitignore...${NC}"
    echo -e "\n# Ignorar archivos de workspace de Obsidian" >> "$GITIGNORE_FILE"
    echo ".obsidian/workspace.json" >> "$GITIGNORE_FILE"
    git add "$GITIGNORE_FILE"
    git commit -m "Ignorar workspace.json" || echo "Sin cambios en .gitignore"
fi

# --- PASO 2: Sincronización forzada con origen ---
echo -e "${GREEN}Sincronizando rama $BRANCH_MAIN...${NC}"
git fetch --all
git checkout $BRANCH_MAIN
git reset --hard origin/$BRANCH_MAIN  # Alinea completamente con el remoto
git pull origin $BRANCH_MAIN

# --- PASO 3: Commit automático de cambios locales ---
echo -e "${GREEN}Verificando cambios pendientes...${NC}"
if [[ $(git status --porcelain) ]]; then
    echo -e "${GREEN}Haciendo commit automático...${NC}"
    git add .
    git commit -m "$COMMIT_MSG" || handle_error "Commit fallido"
    git push origin $BRANCH_MAIN
else
    echo -e "${GREEN}No hay cambios pendientes.${NC}"
fi

# --- PASO 4: Generación del sitio Hugo ---
echo -e "${GREEN}Generando sitio Hugo...${NC}"
hugo || handle_error "Error al generar el sitio"

# --- PASO 5: Despliegue en Hostinger ---
echo -e "${GREEN}Actualizando rama $BRANCH_HOSTINGER...${NC}"
TEMP_BRANCH="temp-host-$(date +%s)"
git subtree split --prefix=$PUBLIC_DIR -b $TEMP_BRANCH || handle_error "Error en subtree split"

# Forzar sincronización completa de la rama hostinger
git push origin $TEMP_BRANCH:$BRANCH_HOSTINGER --force || handle_error "Error al hacer push a $BRANCH_HOSTINGER"
git branch -D $TEMP_BRANCH || handle_error "Error al borrar rama temporal"

echo -e "${GREEN}¡Despliegue exitoso!${NC}"
echo -e "${YELLOW}Nota: Hostinger puede tardar 1-2 minutos en actualizar el sitio${NC}"
