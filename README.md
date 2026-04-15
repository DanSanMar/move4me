# Move4Me.sh 🚀 v1.5

**Move4Me.sh** es una herramienta de automatización para Linux diseñada para facilitar la migración de entornos de trabajo. Identifica automáticamente tu distribución y genera un script de restauración con todas las aplicaciones que instalaste manualmente, ideal para mover laboratorios de **Kali Linux (WSL2)**, estaciones de trabajo Debian, Arch o Fedora a un nuevo equipo.

---

## 📋 Características

- **Detección Inteligente:** Identifica el SO y el gestor de paquetes (`apt`, `dnf`, `pacman`, `zypper`).
- **Limpieza:** No copia dependencias automáticas, solo los paquetes que tú instalaste explícitamente.
- **Portabilidad:** Crea un script independiente (`restaurar_apps.sh`) listo para ejecutar en el destino.
- **Seguridad:** Verifica permisos de escritura y existencia de archivos antes de actuar.
- **Interfaz Visual:** Menú interactivo con colores y guía de uso integrada.

---

## 🛠️ Sistemas Soportados

| Familia | Distribuciones Comunes | Gestor |
| :--- | :--- | :--- |
| **Debian** | Kali Linux, Ubuntu, Pop!_OS, Mint | `apt` |
| **Arch** | Manjaro, EndeavourOS, Arch puro | `pacman` |
| **RedHat** | Fedora, RHEL, CentOS, Rocky Linux | `dnf`/`yum` |
| **SUSE** | OpenSUSE Leap & Tumbleweed | `zypper` |

## 🚀 Instalación y Uso

### 1. Preparación (Equipo Origen)
Clona este repositorio o descarga el script:

```bash
git clone [https://github.com/DanSanMar/move4me.git](https://github.com/DanSanMar/move4me.git)
cd move4me
chmod +x move4me.sh
./move4me.sh
Selecciona la Opción 1 (Exportar Aplicaciones).

Se generarán dos archivos en la carpeta actual:

lista_paquetes.txt: Contiene los nombres de tus apps.

restaurar_apps.sh: El script que instalará todo en el nuevo equipo.

2. Migración (Transferencia)
Copia lista_paquetes.txt y restaurar_apps.sh a tu nueva máquina usando scp, un pendrive o la nube.

3. Restauración (Equipo Destino)
En la nueva máquina, abre la terminal en la carpeta donde copiaste los archivos y ejecuta:

Bash
chmod +x restaurar_apps.sh
./restaurar_apps.sh
📖 Instrucciones Detalladas
El script incluye un manual de uso rápido dentro del menú principal (Opción 2). Asegúrate de tener conexión a internet en el equipo de destino para que el gestor de paquetes pueda descargar las aplicaciones.

⚠️ Notas importantes
Repositorios Externos: Si usas PPAs o repositorios de terceros (como Brave, VSCode externo, etc.), asegúrate de añadirlos manualmente en el nuevo equipo antes de ejecutar el script de restauración.

Archivos de Configuración: Este script instala los binarios, pero no mueve tus archivos personales (/home). Se recomienda respaldar tus carpetas ocultas (.config, .zshrc, etc.) por separado.
