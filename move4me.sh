#!/bin/bash

# --- COLORES ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# --- LOGO MOVE4ME.SH ---
mostrar_logo() {
    clear
    echo -e "${CYAN}"
    echo "  __  __                   _  _   __  __          _     "
    echo " |  \/  | ___ __   _____  | || | |  \/  | ___  __| |__  "
    echo " | |\/| |/ _ \ \ \ / / _ \ | || |_| |\/| |/ _ \/ _\` \ \ "
    echo " | |  | | (_) \ V /  __/ |__   _| |  | |  __/ (_| | | | "
    echo " |_|  |_|\___/ \_/ \___|    |_| |_|  |_|\___|\__,_| |_| "
    echo -e "VERSION                                         v1.5${NC}"
    echo -e "${YELLOW}------------------------------------------------------------${NC}"
}

# --- INSTRUCCIONES ---
mostrar_instrucciones() {
    mostrar_logo
    echo -e "${BLUE}INSTRUCCIONES DE USO:${NC}"
    echo -e "1. ${WHITE}En el equipo ORIGEN:${NC}"
    echo "   - Selecciona la opción '1' para exportar tus aplicaciones."
    echo "   - Se crearán dos archivos: 'lista_paquetes.txt' y 'restaurar_apps.sh'."
    echo ""
    echo -e "2. ${WHITE}Transferencia:${NC}"
    echo "   - Copia AMBOS archivos a tu nuevo equipo (vía USB, SCP, Drive, etc.)."
    echo ""
    echo -e "3. ${WHITE}En el equipo DESTINO:${NC}"
    echo "   - Abre una terminal donde hayas copiado los archivos."
    echo "   - Dale permisos de ejecución: chmod +x restaurar_apps.sh"
    echo "   - Ejecuta el script: ./restaurar_apps.sh"
    echo ""
    echo -e "${YELLOW}Presiona ENTER para volver al menú...${NC}"
    read
}

# --- LÓGICA DE EXPORTACIÓN ---
ejecutar_exportacion() {
    echo -e "${BLUE}Iniciando proceso de identificación...${NC}"
    
    # Verificación de permisos de escritura en el directorio actual
    if [ ! -w "." ]; then
        echo -e "${RED}⚠️ Error: No tienes permisos de escritura en esta carpeta.${NC}"
        read; return 1
    fi

    OS_ID=$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    OS_ID_LIKE=$(grep -E '^ID_LIKE=' /etc/os-release | cut -d= -f2 | tr -d '"')

    #La función solo devuelve el nombre del gestor para la lógica
    detect_package_manager() {
        case "$OS_ID" in
            kali|debian|ubuntu|linuxmint|pop) echo "apt" ;;
            fedora|rhel|centos|rocky|almalinux)
                if command -v dnf &>/dev/null; then echo "dnf"; else echo "yum"; fi ;;
            arch|manjaro|endeavouros) echo "pacman" ;;
            opensuse-leap|opensuse-tumbleweed|suse) echo "zypper" ;;
            *)
                if [[ "$OS_ID_LIKE" == *"debian"* ]]; then echo "apt"
                elif [[ "$OS_ID_LIKE" == *"fedora"* ]] || [[ "$OS_ID_LIKE" == *"rhel"* ]]; then echo "dnf"
                elif [[ "$OS_ID_LIKE" == *"arch"* ]]; then echo "pacman"
                elif [[ "$OS_ID_LIKE" == *"suse"* ]]; then echo "zypper"
                else echo "unknown"; fi ;;
        esac
    }

    PKG_MANAGER=$(detect_package_manager)
    # Se muestra el gestor, pero la variable PKG_MANAGER queda limpia
    echo -e "${GREEN}Sistema detectado: $OS_ID (Gestor: $PKG_MANAGER)${NC}"

    case "$PKG_MANAGER" in
        apt)
            apt-mark showmanual > lista_paquetes.txt
            cat > restaurar_apps.sh << 'EOF'
#!/bin/bash
if [ ! -f lista_paquetes.txt ]; then echo "Error: lista_paquetes.txt no encontrado"; exit 1; fi
echo "Actualizando repositorios..."
sudo apt update
echo "Instalando paquetes desde lista_paquetes.txt..."
sudo apt install -y $(cat lista_paquetes.txt)
echo "¡Restauración completada!"
EOF
            ;;
        dnf|yum)
            $PKG_MANAGER list installed --installed-only | awk 'NR>1 {print $1}' | sed 's/\..*$//' > lista_paquetes.txt
            cat > restaurar_apps.sh << EOF
#!/bin/bash
if [ ! -f lista_paquetes.txt ]; then echo "Error: lista_paquetes.txt no encontrado"; exit 1; fi
echo "Actualizando repositorios..."
sudo $PKG_MANAGER makecache
echo "Instalando paquetes..."
sudo $PKG_MANAGER install -y \$(cat lista_paquetes.txt)
echo "¡Restauración completada!"
EOF
            ;;
        pacman)
            pacman -Qe | awk '{print $1}' > lista_paquetes.txt
            cat > restaurar_apps.sh << 'EOF'
#!/bin/bash
if [ ! -f lista_paquetes.txt ]; then echo "Error: lista_paquetes.txt no encontrado"; exit 1; fi
echo "Sincronizando bases de datos..."
sudo pacman -Sy
echo "Instalando paquetes..."
sudo pacman -S --noconfirm $(cat lista_paquetes.txt)
echo "¡Restauración completada!"
EOF
            ;;
        zypper)
            zypper se -i | grep "^|" | awk '{print $3}' > lista_paquetes.txt
            cat > restaurar_apps.sh << 'EOF'
#!/bin/bash
if [ ! -f lista_paquetes.txt ]; then echo "Error: lista_paquetes.txt no encontrado"; exit 1; fi
echo "Refrescando repositorios..."
sudo zypper refresh
echo "Instalando paquetes..."
sudo zypper install -y $(cat lista_paquetes.txt)
echo "¡Restauración completada!"
EOF
            ;;
        *)
            echo -e "${RED}⚠️ Error: Gestor de paquetes no soportado.${NC}"
            read; return 1
            ;;
    esac

    # Validación de archivo y contenido.
    if [ -s lista_paquetes.txt ]; then
        chmod +x restaurar_apps.sh
        echo -e "\n${GREEN}--- ¡ÉXITO! ---${NC}"
        echo "Archivos generados: 'lista_paquetes.txt' y 'restaurar_apps.sh'"
    else
        echo -e "\n${RED}⚠️ Error: No se pudieron extraer paquetes o la lista está vacía.${NC}"
    fi
    
    echo -e "${YELLOW}Presiona ENTER para volver...${NC}"
    read
}

# --- MENÚ PRINCIPAL ---
while true; do
    mostrar_logo
    echo -e "1) ${CYAN}Exportar Aplicaciones${NC}"
    echo -e "2) ${BLUE}Instrucciones de uso${NC}"
    echo -e "3) ${RED}Salir${NC}"
    echo ""
    echo -n "Selecciona una opción: "
    read opcion

    case $opcion in
        1) ejecutar_exportacion ;;
        2) mostrar_instrucciones ;;
        3) echo -e "${GREEN}¡Suerte en tu nueva instalación! Adiós.${NC}"; exit 0 ;;
        *) echo -e "${RED}Opción no válida.${NC}"; sleep 1 ;;
    esac
done