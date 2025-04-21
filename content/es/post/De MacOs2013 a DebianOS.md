---
title: Reutilizar en vez de desechar: cómo convertí un viejo MacBook en servidor Debian
date: 2025-04-21
---

Recientemente me he comprado un ordenador nuevo, un Lenovo P15 G2, pero de eso hablaremos en otro post. Hoy quiero centrarme en algo que considero fundamental: **reutilizar equipos antes de tirarlos o dejarlos olvidados en un cajón**.

Durante años, mi MacBook —con un procesador Core i5, 8 GB de RAM y 175 GB en SSD— fue mi compañero de batalla. Sin embargo, la última actualización de macOS que pude instalarle fue Big Sur, y ya sabemos que el software privativo deja de dar soporte a versiones antiguas rápidamente. En lugar de desecharlo, decidí darle una segunda vida como servidor Debian.

**¿Por qué Debian y por qué LXDE?**  
Elegí Debian por su estabilidad y, en concreto, la versión de escritorio ligero LXDE para aprovechar al máximo los recursos del equipo. El proceso requiere un USB y descargar la ISO de Debian que quieras instalar. Al principio, instalé Debian 12, pero me encontré con un problema: el driver de la tarjeta de red BCM4360 (Broadcom) no era compatible con el kernel 6.10 que trae Debian 12. El driver propietario broadcom-sta solo es compatible hasta el kernel 5.10.

**¿La solución?**  
Instalar Debian 11, que incluye el kernel adecuado, y luego añadir manualmente las dependencias necesarias. Aquí tienes la lista completa de paquetes que debes descargar y guardar en una carpeta (mejor fuera del escritorio):

## **Lista de paquetes a descargar**

- **Dependencias de Perl y sistema:**
    
    - perl-base
        
    - perl-modules-5.32
        
    - libperl5.32
        
    - libfile-fcntllock-perl
        
    - liblocale-gettext-perl
        
    - dpkg
        
    - libdpkg-perl
        
    - distro-info-data
        
    - lsb-release
        
- **Herramientas de compilación:**
    
    - gcc
        
    - make
        
    - dpkg-dev
        
- **Encabezados del kernel y herramientas:**
    
    - linux-headers-<versión>-common
        
    - linux-headers-<versión>-amd64
        
    - linux-kbuild-5.10 (o el que corresponda a tu kernel)
        
    - libc6
        
    - libelf1
        
    - libssl1.1
        
- **Herramientas inalámbricas:**
    
    - wireless-tools
        
    - libiw30
        
- **Driver Broadcom STA:**
    
    - broadcom-sta-dkms


Guarda todos los paquetes en una carpeta y, desde la terminal, accede a ella con `cd` para instalarlos en este orden:

## Instalación paso a paso
# Dependencias básicas de Perl y sistema
sudo dpkg -i perl-base_*.deb
sudo dpkg -i perl-modules-5.32_*.deb
sudo dpkg -i libperl5.32_*.deb
sudo dpkg -i libfile-fcntllock-perl_*.deb
sudo dpkg -i liblocale-gettext-perl_*.deb
sudo dpkg -i dpkg_*.deb
sudo dpkg -i libdpkg-perl_*.deb
sudo dpkg -i distro-info-data_*.deb
sudo dpkg -i lsb-release_*.deb

# Herramientas de compilación
sudo dpkg -i gcc_*.deb
sudo dpkg -i make_*.deb
sudo dpkg -i dpkg-dev_*.deb

# Encabezados del kernel y herramientas
sudo dpkg -i libc6_*.deb
sudo dpkg -i libelf1_*.deb
sudo dpkg -i libssl1.1_*.deb
sudo dpkg -i linux-kbuild-5.10_*.deb
sudo dpkg -i linux-headers-`<versión>`-common_*.deb
sudo dpkg -i linux-headers-`<versión>`-amd64_*.deb

# Herramientas inalámbricas
sudo dpkg -i libiw30_*.deb
sudo dpkg -i wireless-tools_*.deb

# Driver Broadcom STA
sudo dpkg -i broadcom-sta-dkms_*.deb

# Si hay errores de dependencias
sudo apt-get install -f

# Cargar el módulo Broadcom STA
sudo modprobe wl

# Si el módulo no se carga automáticamente al reiniciar
echo "wl" | sudo tee /etc/modules-load.d/wl.conf

# Para evitar conflictos con otros módulos
echo -e "blacklist b43\nblacklist b43legacy\nblacklist ssb\nblacklist brcmsmac\nblacklist bcma" | sudo tee /etc/modprobe.d/blacklist-broadcom.conf

Este proceso fue fruto de casi ocho horas de pruebas e investigación. Espero que esta guía te ayude a aprovechar ese ordenador que pensabas tirar. ¡Nos vemos en el próximo post!

