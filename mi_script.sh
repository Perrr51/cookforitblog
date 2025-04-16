#!/bin/bash

# Configuración
REPO_URL="git@github.com:Perrr51/cookforitblog.git"
BRANCH_MAIN="master"
BRANCH_HOSTINGER="hostinger"
PUBLIC_DIR="public"
COMMIT_MSG="Actualización automática del sitio Hugo $(date +'%Y-%m-%d %H:%M:%S')"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Función para errores
handle_error() {
    echo -e "${RED}Error: $1${NC}"
    exit 1
}

# 1. Verifica cambios no commitados y haz commit automáticamente si hay cambios
echo -e "${GREEN}Verificando cambios pendientes...${NC}"
if [[ $(git status --porcelain) ]]; then
    echo -e "${YELLOW}Hay cambios no commitados. Haciendo commit automáticamente...${NC}"
    git add .
    git commit -m "$COMMIT_MSG" || handle_error "No se pudo hacer commit"
else
    echo -e "${GREEN}No hay cambios pendientes.${NC}"
fi

# 2. Generar sitio Hugo
echo -e "${GREEN}Generando sitio Hugo...${NC}"
hugo || handle_error "Error al generar el sitio"

# 3. Subir cambios a la rama master
echo -e "${GREEN}Subiendo cambios a la rama $BRANCH_MAIN...${NC}"
git checkout $BRANCH_MAIN || handle_error "No se pudo cambiar a $BRANCH_MAIN"
git pull --rebase || handle_error "Error al hacer pull en $BRANCH_MAIN"
git push origin $BRANCH_MAIN || handle_error "Error al hacer push en $BRANCH_MAIN"

# 4. Actualizar rama hostinger con contenido de public/
echo -e "${GREEN}Actualizando rama $BRANCH_HOSTINGER con contenido de $PUBLIC_DIR...${NC}"
# Crear rama temporal
TEMP_BRANCH="temp-host-$(date +'%s')"
git subtree split --prefix=$PUBLIC_DIR -b $TEMP_BRANCH || handle_error "Error en subtree split"

# Forzar push a la rama hostinger
git push origin $TEMP_BRANCH:$BRANCH_HOSTINGER --force || handle_error "Error en push a $BRANCH_HOSTINGER"

# Borrar rama temporal
git branch -D $TEMP_BRANCH || handle_error "No se pudo borrar la rama temporal"

# 5. Volver a la rama principal
git checkout $BRANCH_MAIN || handle_error "No se pudo volver a $BRANCH_MAIN"

echo -e "${GREEN}¡Proceso completado con éxito!${NC}"

