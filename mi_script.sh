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

# Verificar y configurar .gitignore
echo -e "${GREEN}Verificando .gitignore...${NC}"
if ! grep -q ".obsidian/workspace.json" "$GITIGNORE_FILE"; then
    echo -e "${GREEN}Añadiendo .obsidian/workspace.json a .gitignore...${NC}"
    echo -e "\n# Ignorar archivos de workspace de Obsidian" >> "$GITIGNORE_FILE"
    echo ".obsidian/workspace.json" >> "$GITIGNORE_FILE"
    git add "$GITIGNORE_FILE"
    git commit -m "Ignorar workspace.json" || echo "Sin cambios en .gitignore"
fi

# Eliminar workspace.json del tracking
if git ls-files --error-unmatch .obsidian/workspace.json &> /dev/null; then
    echo -e "${GREEN}Eliminando workspace.json del tracking...${NC}"
    git rm --cached .obsidian/workspace.json
    git commit -m "Eliminar workspace.json del tracking" || handle_error "Commit fallido"
fi

# 1. Verificar cambios no commitados
echo -e "${GREEN}Verificando cambios pendientes...${NC}"
if [[ $(git status --porcelain) ]]; then
    echo -e "${GREEN}Haciendo commit automático...${NC}"
    git add .
    git commit -m "$COMMIT_MSG" || handle_error "Commit fallido"
else
    echo -e "${GREEN}No hay cambios pendientes.${NC}"
fi

# 2. Generar sitio Hugo
echo -e "${GREEN}Generando sitio Hugo...${NC}"
hugo || handle_error "Error al generar el sitio"

# 3. Subir cambios a la rama master
echo -e "${GREEN}Subiendo cambios a $BRANCH_MAIN...${NC}"
git checkout $BRANCH_MAIN || handle_error "No se pudo cambiar a $BRANCH_MAIN"
git config pull.rebase false

# Intentar pull con historias no relacionadas
if ! git pull origin $BRANCH_MAIN --allow-unrelated-histories; then
    echo -e "${YELLOW}Resolviendo conflictos de fusiones no relacionadas...${NC}"
    git reset --hard origin/$BRANCH_MAIN
    git pull origin $BRANCH_MAIN --allow-unrelated-histories || handle_error "Error al hacer pull"
fi

git push origin $BRANCH_MAIN || handle_error "Error al hacer push"

# 4. Actualizar rama hostinger
echo -e "${GREEN}Actualizando rama $BRANCH_HOSTINGER...${NC}"
TEMP_BRANCH="temp-host-$(date +%s)"
git subtree split --prefix=$PUBLIC_DIR -b $TEMP_BRANCH || handle_error "Error en subtree split"
git push origin $TEMP_BRANCH:$BRANCH_HOSTINGER --force || handle_error "Error al hacer push a $BRANCH_HOSTINGER"
git branch -D $TEMP_BRANCH || handle_error "Error al borrar rama temporal"

echo -e "${GREEN}¡Despliegue exitoso!${NC}"
