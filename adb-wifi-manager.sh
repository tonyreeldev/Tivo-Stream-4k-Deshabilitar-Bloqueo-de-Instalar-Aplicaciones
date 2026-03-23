#!/usr/bin/env bash
# ============================================================
#  ADB WiFi Manager — TV Box Tool (macOS) v4
#  Autor: Tony Reel
#  Idiomas: Espanol / English
#  Requisitos: adb (Android Platform Tools)
#              brew install android-platform-tools
#              brew install nmap (opcional)
# ============================================================

# ── Colores ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Config ───────────────────────────────────────────────────
ADB_PORT=5555
ACTIVE_PORT=5555
DOWNLOADS_DIR="$HOME/Downloads"
CONNECTED_DEVICE=""
LANG_SEL="ES"   # ES | EN

# ── Idiomas ──────────────────────────────────────────────────
t() {
    local key="$1"; shift
    local args=("$@")
    local text=""
    case "$key" in
        # General
        press_enter)    [[ $LANG_SEL == "ES" ]] && text="  Presiona Enter para continuar" || text="  Press Enter to continue" ;;
        invalid_opt)    [[ $LANG_SEL == "ES" ]] && text="  Opcion invalida." || text="  Invalid option." ;;
        not_connected)  [[ $LANG_SEL == "ES" ]] && text="  No hay dispositivo conectado. Conectate primero." || text="  No device connected. Connect first." ;;
        yes_key)        [[ $LANG_SEL == "ES" ]] && text="s" || text="y" ;;
        # Banner
        banner_on)      [[ $LANG_SEL == "ES" ]] && text="  [ON]  Conectado: " || text="  [ON]  Connected: " ;;
        banner_model)   [[ $LANG_SEL == "ES" ]] && text="        Modelo: " || text="        Model: " ;;
        banner_off)     [[ $LANG_SEL == "ES" ]] && text="  [OFF] Sin dispositivo conectado" || text="  [OFF] No device connected" ;;
        net_lost)       [[ $LANG_SEL == "ES" ]] && text="  [OFF] Conexion perdida (cambio de red detectado)" || text="  [OFF] Connection lost (network change detected)" ;;
        net_lost2)      [[ $LANG_SEL == "ES" ]] && text="        Reconecta con opcion [1] o [2]" || text="        Reconnect using option [1] or [2]" ;;
        # Menu
        menu_conn)      [[ $LANG_SEL == "ES" ]] && text="  -- CONEXION ----------------------------------" || text="  -- CONNECTION --------------------------------" ;;
        menu_cmd)       [[ $LANG_SEL == "ES" ]] && text="  -- COMANDOS ----------------------------------" || text="  -- COMMANDS ----------------------------------" ;;
        menu_apk)       [[ $LANG_SEL == "ES" ]] && text="  -- APKs --------------------------------------" || text="  -- APKs --------------------------------------" ;;
        menu_opt)       [[ $LANG_SEL == "ES" ]] && text="  -- OPTIMIZACION ------------------------------" || text="  -- OPTIMIZATION ------------------------------" ;;
        menu_util)      [[ $LANG_SEL == "ES" ]] && text="  -- UTILIDADES --------------------------------" || text="  -- UTILITIES ---------------------------------" ;;
        menu_prompt)    [[ $LANG_SEL == "ES" ]] && text="  Opcion: " || text="  Option: " ;;
        menu_bye)       [[ $LANG_SEL == "ES" ]] && text="\n  Hasta luego!\n" || text="\n  Goodbye!\n" ;;
        # Adaptadores/Scan
        adapters_title) [[ $LANG_SEL == "ES" ]] && text="\n  Interfaces de red disponibles:\n" || text="\n  Available network interfaces:\n" ;;
        adapters_pick)  [[ $LANG_SEL == "ES" ]] && text="  Selecciona tu interfaz WiFi/Ethernet [1-${args[0]}]: " || text="  Select your WiFi/Ethernet interface [1-${args[0]}]: " ;;
        adapters_none)  [[ $LANG_SEL == "ES" ]] && text="  No se encontro ninguna interfaz activa." || text="  No active network interface found." ;;
        scan_detecting) [[ $LANG_SEL == "ES" ]] && text="\n  [SCAN] Selecciona la interfaz de red..." || text="\n  [SCAN] Select network interface..." ;;
        scan_running)   [[ $LANG_SEL == "ES" ]] && text="\n  [SCAN] Escaneando ${args[0]} - puerto ${args[1]}..." || text="\n  [SCAN] Scanning ${args[0]} - port ${args[1]}..." ;;
        scan_nmap)      [[ $LANG_SEL == "ES" ]] && text="  Usando nmap (rapido)...\n" || text="  Using nmap (fast)...\n" ;;
        scan_sweep)     [[ $LANG_SEL == "ES" ]] && text="  nmap no encontrado. Usando ping sweep paralelo..." || text="  nmap not found. Using parallel ping sweep..." ;;
        scan_none)      [[ $LANG_SEL == "ES" ]] && text="\n  No se encontraron dispositivos con ADB activo (puerto ${args[0]})." || text="\n  No devices found with ADB active (port ${args[0]})." ;;
        scan_tip1)      [[ $LANG_SEL == "ES" ]] && text="  Activa 'Depuracion ADB/WiFi' en el dispositivo." || text="  Enable 'ADB/WiFi Debugging' on the device." ;;
        scan_tip2)      [[ $LANG_SEL == "ES" ]] && text="  Si es la primera vez usa opcion [3] con cable USB.\n" || text="  First time? Use option [3] with USB cable.\n" ;;
        scan_found)     [[ $LANG_SEL == "ES" ]] && text="\n  Dispositivos encontrados con ADB activo:\n" || text="\n  Devices found with ADB active:\n" ;;
        scan_pick)      [[ $LANG_SEL == "ES" ]] && text="  Selecciona [1-${args[0]}] o 0 para cancelar: " || text="  Select [1-${args[0]}] or 0 to cancel: " ;;
        # Conexion
        conn_manual)    [[ $LANG_SEL == "ES" ]] && text="\n  [CONECTAR MANUAL]" || text="\n  [MANUAL CONNECT]" ;;
        conn_port_act)  [[ $LANG_SEL == "ES" ]] && text="  Puerto activo: ${args[0]}" || text="  Active port: ${args[0]}" ;;
        conn_ip)        [[ $LANG_SEL == "ES" ]] && text="  IP del dispositivo: " || text="  Device IP: " ;;
        conn_port_p)    [[ $LANG_SEL == "ES" ]] && text="  Puerto [${args[0]}]: " || text="  Port [${args[0]}]: " ;;
        conn_connecting)[[ $LANG_SEL == "ES" ]] && text="\n  [ADB] Conectando a ${args[0]}..." || text="\n  [ADB] Connecting to ${args[0]}..." ;;
        conn_authorized)[[ $LANG_SEL == "ES" ]] && text="  OK  Dispositivo autorizado y listo." || text="  OK  Device authorized and ready." ;;
        conn_auth_wait) [[ $LANG_SEL == "ES" ]] && text="  >>  Acepta 'Permitir depuracion ADB' en la pantalla del dispositivo." || text="  >>  Accept 'Allow ADB debugging' on the device screen." ;;
        conn_failed)    [[ $LANG_SEL == "ES" ]] && text="  ERR ${args[0]}" || text="  ERR ${args[0]}" ;;
        conn_retry_port)[[ $LANG_SEL == "ES" ]] && text="  No se pudo conectar en puerto ${args[0]}. Intentar con otro puerto? [s/N]: " || text="  Could not connect on port ${args[0]}. Try a different port? [y/N]: " ;;
        conn_enter_port)[[ $LANG_SEL == "ES" ]] && text="  Ingresa el puerto a probar: " || text="  Enter the port to try: " ;;
        conn_disconn)   [[ $LANG_SEL == "ES" ]] && text="\n  OK  Desconectado de ${args[0]}" || text="\n  OK  Disconnected from ${args[0]}" ;;
        conn_none)      [[ $LANG_SEL == "ES" ]] && text="\n  No hay dispositivo conectado." || text="\n  No device connected." ;;
        # USB TCP
        usb_title)      [[ $LANG_SEL == "ES" ]] && text="\n  [HABILITAR ADB WIFI] Conecta el dispositivo por USB primero.\n" || text="\n  [ENABLE ADB WIFI] Connect the device via USB first.\n" ;;
        usb_none)       [[ $LANG_SEL == "ES" ]] && text="  No se detecto dispositivo USB." || text="  No USB device detected." ;;
        usb_found)      [[ $LANG_SEL == "ES" ]] && text="  Dispositivo USB: ${args[0]}" || text="  USB device: ${args[0]}" ;;
        usb_ok)         [[ $LANG_SEL == "ES" ]] && text="  OK  ADB escuchando en puerto ${args[0]}. Desconecta el USB y usa Scan." || text="  OK  ADB listening on port ${args[0]}. Disconnect USB and use Scan." ;;
        # Shell/ADB
        shell_title)    [[ $LANG_SEL == "ES" ]] && text="\n  [SHELL] ${args[0]}" || text="\n  [SHELL] ${args[0]}" ;;
        shell_hint)     [[ $LANG_SEL == "ES" ]] && text="  Escribe 'exit' para volver al menu.\n" || text="  Type 'exit' to return to menu.\n" ;;
        adbcmd_title)   [[ $LANG_SEL == "ES" ]] && text="\n  [ADB CMD] ${args[0]}" || text="\n  [ADB CMD] ${args[0]}" ;;
        adbcmd_hint)    [[ $LANG_SEL == "ES" ]] && text="  Ej: reboot, logcat. Escribe 'exit' para volver.\n" || text="  E.g.: reboot, logcat. Type 'exit' to return.\n" ;;
        # APK
        apk_title)      [[ $LANG_SEL == "ES" ]] && text="\n  [INSTALAR APK] Buscando en: ${args[0]}\n" || text="\n  [INSTALL APK] Searching in: ${args[0]}\n" ;;
        apk_none)       [[ $LANG_SEL == "ES" ]] && text="  No se encontraron .apk en ${args[0]}" || text="  No .apk files found in ${args[0]}" ;;
        apk_found)      [[ $LANG_SEL == "ES" ]] && text="  APKs encontrados:\n" || text="  APKs found:\n" ;;
        apk_mode_title) [[ $LANG_SEL == "ES" ]] && text="\n  Modo de instalacion:" || text="\n  Installation mode:" ;;
        apk_ok)         [[ $LANG_SEL == "ES" ]] && text="  OK  APK instalada correctamente." || text="  OK  APK installed successfully." ;;
        apk_sources)    [[ $LANG_SEL == "ES" ]] && text="  Verifica 'Origenes desconocidos' en Configuracion > Seguridad." || text="  Check 'Unknown sources' in Settings > Security." ;;
        # Packages
        pkg_title)      [[ $LANG_SEL == "ES" ]] && text="\n  [PAQUETES]\n" || text="\n  [PACKAGES]\n" ;;
        pkg_opts)       [[ $LANG_SEL == "ES" ]] && text="  [1] Todas  [2] Solo terceros  [3] Buscar" || text="  [1] All  [2] Third-party only  [3] Search" ;;
        # Uninstall
        uninst_title)   [[ $LANG_SEL == "ES" ]] && text="\n  [DESINSTALAR] Cargando apps de terceros...\n" || text="\n  [UNINSTALL] Loading third-party apps...\n" ;;
        uninst_none)    [[ $LANG_SEL == "ES" ]] && text="  Sin apps de terceros." || text="  No third-party apps found." ;;
        uninst_confirm) [[ $LANG_SEL == "ES" ]] && text="  Desinstalar '${args[0]}'? [s/N]: " || text="  Uninstall '${args[0]}'? [y/N]: " ;;
        # Info
        info_title)     [[ $LANG_SEL == "ES" ]] && text="\n  [INFO] ${args[0]}\n" || text="\n  [INFO] ${args[0]}\n" ;;
        info_storage)   [[ $LANG_SEL == "ES" ]] && text="\n  Almacenamiento:" || text="\n  Storage:" ;;
        info_battery)   [[ $LANG_SEL == "ES" ]] && text="\n  Bateria:" || text="\n  Battery:" ;;
        # Screenshot
        ss_title)       [[ $LANG_SEL == "ES" ]] && text="\n  [SCREENSHOT] Capturando..." || text="\n  [SCREENSHOT] Capturing..." ;;
        ss_ok)          [[ $LANG_SEL == "ES" ]] && text="  OK  Guardado: ${args[0]}" || text="  OK  Saved: ${args[0]}" ;;
        ss_err)         [[ $LANG_SEL == "ES" ]] && text="  ERR No se pudo capturar." || text="  ERR Could not capture screenshot." ;;
        # Puerto
        port_title)     [[ $LANG_SEL == "ES" ]] && text="\n  [CAMBIAR PUERTO ADB]\n" || text="\n  [CHANGE ADB PORT]\n" ;;
        port_hint)      [[ $LANG_SEL == "ES" ]] && text="  Puerto por defecto: 5555. Android 11+ puede usar un puerto diferente." || text="  Default port: 5555. Android 11+ may use a different port." ;;
        port_current)   [[ $LANG_SEL == "ES" ]] && text="  Puerto activo: ${args[0]}" || text="  Active port: ${args[0]}" ;;
        port_prompt)    [[ $LANG_SEL == "ES" ]] && text="  Nuevo puerto [${args[0]}]: " || text="  New port [${args[0]}]: " ;;
        port_ok)        [[ $LANG_SEL == "ES" ]] && text="  OK  Puerto cambiado a ${args[0]}." || text="  OK  Port changed to ${args[0]}." ;;
        port_invalid)   [[ $LANG_SEL == "ES" ]] && text="  ERR Puerto invalido. Debe ser un numero entre 1024 y 65535." || text="  ERR Invalid port. Must be between 1024 and 65535." ;;
        port_menu)      [[ $LANG_SEL == "ES" ]] && text="  [15] Cambiar puerto ADB [${args[0]}]" || text="  [15] Change ADB port [${args[0]}]" ;;
        # Idioma
        lang_title)     text="\n  [IDIOMA / LANGUAGE]\n" ;;
        lang_cur_es)    [[ $LANG_SEL == "ES" ]] && text="  Idioma actual: Espanol" || text="  Current language: Spanish" ;;
        lang_cur_en)    [[ $LANG_SEL == "ES" ]] && text="  Idioma actual: Ingles" || text="  Current language: English" ;;
        lang_ok_es)     text="  OK  Idioma cambiado a Espanol / Language set to Spanish." ;;
        lang_ok_en)     text="  OK  Language set to English / Idioma cambiado a Ingles." ;;
        # Bloatware
        blw_title)      [[ $LANG_SEL == "ES" ]] && text="\n  [BLOATWARE] ${args[0]}\n" || text="\n  [BLOATWARE] ${args[0]}\n" ;;
        blw_quick)      [[ $LANG_SEL == "ES" ]] && text="  -- Acceso rapido ---------------------------------" || text="  -- Quick access -----------------------------------" ;;
        blw_manual)     [[ $LANG_SEL == "ES" ]] && text="  -- Opciones manuales -----------------------------" || text="  -- Manual options ---------------------------------" ;;
        blw_pkg_p)      [[ $LANG_SEL == "ES" ]] && text="  Nombre del paquete (ej: com.nes.coreservice): " || text="  Package name (e.g.: com.nes.coreservice): " ;;
        blw_confirm)    [[ $LANG_SEL == "ES" ]] && text="  Desinstalar '${args[0]}'? [s/N]: " || text="  Uninstall '${args[0]}'? [y/N]: " ;;
        blw_dis_ok)     [[ $LANG_SEL == "ES" ]] && text="  OK  ${args[0]}" || text="  OK  ${args[0]}" ;;
        blw_uninst_ok)  [[ $LANG_SEL == "ES" ]] && text="  OK  Paquete eliminado correctamente." || text="  OK  Package removed successfully." ;;
        blw_rest_ok)    [[ $LANG_SEL == "ES" ]] && text="  OK  Paquete restaurado." || text="  OK  Package restored." ;;
        blw_preset_t)   [[ $LANG_SEL == "ES" ]] && text="\n  Lista predefinida de bloatware comun:\n" || text="\n  Predefined common bloatware list:\n" ;;
        blw_preset_c)   [[ $LANG_SEL == "ES" ]] && text="  Procesar ${args[0]} paquetes? [s/N]: " || text="  Process ${args[0]} packages? [y/N]: " ;;
        blw_dis_list)   [[ $LANG_SEL == "ES" ]] && text="\n  Paquetes deshabilitados:\n" || text="\n  Disabled packages:\n" ;;
        # NES
        nes_title)      [[ $LANG_SEL == "ES" ]] && text="\n  [ACCESO RAPIDO] Eliminar ${args[0]}\n" || text="\n  [QUICK ACCESS] Remove ${args[0]}\n" ;;
        nes_desc1)      [[ $LANG_SEL == "ES" ]] && text="  Servicio de telemetria/spyware comun en TV Boxes genericos chinos." || text="  Telemetry/spyware service common in generic Chinese TV Boxes." ;;
        nes_desc2)      [[ $LANG_SEL == "ES" ]] && text="  Su eliminacion es segura y no afecta el funcionamiento.\n" || text="  Its removal is safe and does not affect device functionality.\n" ;;
        nes_not_found)  [[ $LANG_SEL == "ES" ]] && text="  INFO El paquete no esta instalado en este dispositivo." || text="  INFO Package is not installed on this device." ;;
        nes_found)      [[ $LANG_SEL == "ES" ]] && text="  Paquete encontrado. Como deseas eliminarlo?\n" || text="  Package found. How do you want to remove it?\n" ;;
        nes_dis_ok)     [[ $LANG_SEL == "ES" ]] && text="  OK  ${args[0]} deshabilitado correctamente." || text="  OK  ${args[0]} disabled successfully." ;;
        nes_dis_tip)    [[ $LANG_SEL == "ES" ]] && text="      Para restaurarlo usa la opcion [3] de este menu." || text="      To restore it use option [3] in this menu." ;;
        nes_uninst_ok)  [[ $LANG_SEL == "ES" ]] && text="  OK  ${args[0]} eliminado permanentemente." || text="  OK  ${args[0]} permanently removed." ;;
        # NES Status
        nes_status_t)   [[ $LANG_SEL == "ES" ]] && text="\n  [STATUS] com.nes.coreservice\n" || text="\n  [STATUS] com.nes.coreservice\n" ;;
        nes_s_enabled)  [[ $LANG_SEL == "ES" ]] && text="  Estado:  ACTIVO / HABILITADO" || text="  Status:  ACTIVE / ENABLED" ;;
        nes_s_disabled) [[ $LANG_SEL == "ES" ]] && text="  Estado:  DESHABILITADO (disable-user)" || text="  Status:  DISABLED (disable-user)" ;;
        nes_s_uninst)   [[ $LANG_SEL == "ES" ]] && text="  Estado:  DESINSTALADO para usuario 0" || text="  Status:  UNINSTALLED for user 0" ;;
        nes_s_none)     [[ $LANG_SEL == "ES" ]] && text="  Estado:  NO INSTALADO en este dispositivo" || text="  Status:  NOT INSTALLED on this device" ;;
        # AdBlock
        ads_title)      [[ $LANG_SEL == "ES" ]] && text="\n  [BLOQUEO DE PUBLICIDAD] ${args[0]}\n" || text="\n  [AD BLOCKING] ${args[0]}\n" ;;
        ads_status)     [[ $LANG_SEL == "ES" ]] && text="  Estado DNS: " || text="  DNS Status: " ;;
        ads_active)     [[ $LANG_SEL == "ES" ]] && text="ACTIVO  ->  ${args[0]}" || text="ACTIVE  ->  ${args[0]}" ;;
        ads_inactive)   [[ $LANG_SEL == "ES" ]] && text="Sin DNS bloqueador configurado" || text="No ad-blocking DNS configured" ;;
        ads_set_ok)     [[ $LANG_SEL == "ES" ]] && text="  OK  DNS privado configurado: ${args[0]}" || text="  OK  Private DNS configured: ${args[0]}" ;;
        ads_set_tip)    [[ $LANG_SEL == "ES" ]] && text="  Los anuncios seran bloqueados en todo el dispositivo." || text="  Ads will be blocked across the entire device." ;;
        ads_off_ok)     [[ $LANG_SEL == "ES" ]] && text="\n  OK  DNS bloqueador desactivado. Usando DNS del router." || text="\n  OK  Ad-blocking DNS disabled. Using router DNS." ;;
        ads_custom_p)   [[ $LANG_SEL == "ES" ]] && text="  Hostname del DNS: " || text="  DNS hostname: " ;;
        ads_nextdns_p)  [[ $LANG_SEL == "ES" ]] && text="  Tu ID de NextDNS (ej: abc123): " || text="  Your NextDNS ID (e.g.: abc123): " ;;
        ads_adaway_t)   [[ $LANG_SEL == "ES" ]] && text="\n  [ADAWAY] AdAway en modo VPN filtra anuncios sin root.\n  Descarga desde: https://adaway.org\n" || text="\n  [ADAWAY] AdAway in VPN mode filters ads without root.\n  Download from: https://adaway.org\n" ;;
        ads_adaway_f)   [[ $LANG_SEL == "ES" ]] && text="  APK encontrado: ${args[0]}" || text="  APK found: ${args[0]}" ;;
        ads_adaway_n)   [[ $LANG_SEL == "ES" ]] && text="  No se encontro adaway*.apk en $DOWNLOADS_DIR" || text="  adaway*.apk not found in $DOWNLOADS_DIR" ;;
        ads_adaway_ok)  [[ $LANG_SEL == "ES" ]] && text="  OK  AdAway instalado. Abrelo y activa el modo VPN." || text="  OK  AdAway installed. Open it and enable VPN mode." ;;
        # STN
        stn_title)      [[ $LANG_SEL == "ES" ]] && text="\n  [SMARTTUBENEXT] YouTube sin publicidad\n" || text="\n  [SMARTTUBENEXT] YouTube ad-free\n" ;;
        stn_desc1)      [[ $LANG_SEL == "ES" ]] && text="  App alternativa de YouTube para Android TV." || text="  Alternative YouTube app for Android TV." ;;
        stn_desc2)      [[ $LANG_SEL == "ES" ]] && text="  Bloquea publicidad, sin root, sin cuenta requerida.\n" || text="  Blocks ads, no root, no account required.\n" ;;
        stn_already)    [[ $LANG_SEL == "ES" ]] && text="  INFO SmartTubeNext ya esta instalado." || text="  INFO SmartTubeNext is already installed." ;;
        stn_checking)   [[ $LANG_SEL == "ES" ]] && text="  Consultando ultima version en GitHub..." || text="  Checking latest version on GitHub..." ;;
        stn_api_err)    [[ $LANG_SEL == "ES" ]] && text="  ERR No se pudo consultar GitHub API." || text="  ERR Could not reach GitHub API." ;;
        stn_found)      [[ $LANG_SEL == "ES" ]] && text="  Version encontrada: ${args[0]}" || text="  Version found: ${args[0]}" ;;
        stn_size)       [[ $LANG_SEL == "ES" ]] && text="  Tamano del APK: ${args[0]} MB" || text="  APK size: ${args[0]} MB" ;;
        stn_dl_start)   [[ $LANG_SEL == "ES" ]] && text="\n  Descargando ${args[0]}..." || text="\n  Downloading ${args[0]}..." ;;
        stn_dl_ok)      [[ $LANG_SEL == "ES" ]] && text="  OK  Descargado en: ${args[0]}" || text="  OK  Downloaded to: ${args[0]}" ;;
        stn_dl_err)     [[ $LANG_SEL == "ES" ]] && text="  ERR Error al descargar. Verifica tu conexion." || text="  ERR Download error. Check your connection." ;;
        stn_installing) [[ $LANG_SEL == "ES" ]] && text="\n  Instalando SmartTubeNext en el dispositivo..." || text="\n  Installing SmartTubeNext on device..." ;;
        stn_verifying)  [[ $LANG_SEL == "ES" ]] && text="  Verificando instalacion..." || text="  Verifying installation..." ;;
        stn_inst_ok)    [[ $LANG_SEL == "ES" ]] && text="  OK  SmartTubeNext instalado correctamente." || text="  OK  SmartTubeNext installed successfully." ;;
        stn_inst_tip)   [[ $LANG_SEL == "ES" ]] && text="  Abrelo desde el menu de apps del TV Box." || text="  Open it from the TV Box app menu." ;;
        stn_warn)       [[ $LANG_SEL == "ES" ]] && text="  WARN No se pudo confirmar. Revisa el menu de apps del TV Box." || text="  WARN Could not confirm. Check the TV Box app menu." ;;
        stn_warn2)      [[ $LANG_SEL == "ES" ]] && text="  Si aparece SmartTube en las apps, la instalacion fue exitosa." || text="  If SmartTube appears in apps, installation was successful." ;;
        stn_uninst_ok)  [[ $LANG_SEL == "ES" ]] && text="  OK  SmartTubeNext desinstalado." || text="  OK  SmartTubeNext uninstalled." ;;
        stn_confirm)    [[ $LANG_SEL == "ES" ]] && text="  Descargar e instalar? [s/N]: " || text="  Download and install? [y/N]: " ;;
        stn_reuse)      [[ $LANG_SEL == "ES" ]] && text="  Archivo ya descargado. Usar existente? [s/N]: " || text="  File already downloaded. Reuse it? [y/N]: " ;;
        stn_retry)      [[ $LANG_SEL == "ES" ]] && text="  Reintentar con fuentes externas (-r -d)? [s/N]: " || text="  Retry with external sources (-r -d)? [y/N]: " ;;
        *) text="[$key]" ;;
    esac
    echo -e "$text"
}

# ── Dependencias ─────────────────────────────────────────────
check_deps() {
    if ! command -v adb &>/dev/null; then
        echo -e "${RED}  [ERROR] 'adb' no encontrado.${RESET}"
        echo -e "${CYAN}  Instala con Homebrew:${RESET}"
        echo -e "  ${DIM}brew install android-platform-tools${RESET}"
        echo -e "  ${DIM}Si no tienes Homebrew: https://brew.sh${RESET}\n"
        read -rp "  Presiona Enter para salir..." ; exit 1
    fi
    if ! command -v curl &>/dev/null && ! command -v wget &>/dev/null; then
        echo -e "${YELLOW}  WARN: curl/wget no encontrado. La descarga automatica no funcionara.${RESET}"
    fi
}

# ── Health check de conexion ─────────────────────────────────
device_alive() {
    [[ -z "$CONNECTED_DEVICE" ]] && return 1
    local ip port
    ip="${CONNECTED_DEVICE%%:*}"
    port="${CONNECTED_DEVICE##*:}"
    # Test TCP con timeout de 1 segundo
    if ! nc -z -w1 "$ip" "$port" 2>/dev/null; then return 1; fi
    # Confirmar con adb get-state
    local state
    state=$(adb -s "$CONNECTED_DEVICE" get-state 2>/dev/null | tr -d '\r\n')
    [[ "$state" == "device" ]]
}

# ── Banner ───────────────────────────────────────────────────
banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "  +----------------------------------------------+"
    echo "  |        ADB WiFi Manager - TV Box Tool        |"
    echo "  |              by Leonel Rubira  v4            |"
    echo "  +----------------------------------------------+"
    echo -e "${RESET}"

    if [[ -n "$CONNECTED_DEVICE" ]]; then
        if device_alive; then
            echo -e "$(t banner_on)${BOLD}$CONNECTED_DEVICE${RESET}"
            local model
            model=$(adb -s "$CONNECTED_DEVICE" shell getprop ro.product.model 2>/dev/null | tr -d '\r\n')
            [[ -n "$model" ]] && echo -e "$(t banner_model)${DIM}$model${RESET}"
        else
            adb disconnect "$CONNECTED_DEVICE" &>/dev/null
            CONNECTED_DEVICE=""
            echo -e "${YELLOW}$(t net_lost)${RESET}"
            echo -e "${DIM}$(t net_lost2)${RESET}"
        fi
    else
        echo -e "${YELLOW}$(t banner_off)${RESET}"
    fi
    echo ""
}

# ── Subred local (macOS usa 'networksetup' e 'ifconfig') ─────
get_local_subnet() {
    echo -e "$(t adapters_title)"
    # Obtener interfaces activas con IP
    local interfaces=()
    local ips=()
    local labels=()

    while IFS= read -r line; do
        local iface ip
        iface=$(echo "$line" | awk '{print $1}')
        ip=$(echo "$line" | awk '{print $2}')
        [[ -z "$iface" || -z "$ip" ]] && continue
        [[ "$ip" == "127."* || "$ip" == "169.254."* ]] && continue

        # Etiquetar virtuales
        local label="$iface"
        if echo "$iface $ip" | grep -qiE "vmnet|vbox|bridge|utun|awdl|llw|gif|stf"; then
            label="$iface [VIRTUAL - omitir]"
        fi
        interfaces+=("$iface")
        ips+=("$ip")
        labels+=("$label")
    done < <(ifconfig -a | awk '/^[a-z]/{iface=$1} /inet /{gsub(/:/, "", iface); print iface, $2}' | grep -v "^$")

    if [[ ${#ips[@]} -eq 0 ]]; then
        echo -e "${RED}$(t adapters_none)${RESET}"
        return 1
    fi

    local i=1
    for idx in "${!ips[@]}"; do
        echo -e "  ${BOLD}[$i]${RESET} ${GREEN}${ips[$idx]}${RESET}   ${DIM}${labels[$idx]}${RESET}"
        ((i++))
    done
    echo ""

    local pick
    read -rp "$(t adapters_pick "${#ips[@]}")" pick
    local sel=$((pick - 1))
    if [[ $sel -lt 0 || $sel -ge ${#ips[@]} ]]; then
        echo -e "${YELLOW}  Entrada invalida, usando primera disponible.${RESET}"
        sel=0
    fi

    local selected_ip="${ips[$sel]}"
    local parts
    IFS='.' read -ra parts <<< "$selected_ip"
    echo "${parts[0]}.${parts[1]}.${parts[2]}.0/24"
}

# ── Ping sweep paralelo (macOS) ──────────────────────────────
ping_sweep() {
    local base="$1" port="$2"
    echo -e "${DIM}  Escaneando ${base}.1-254 en puerto ${port}...\n${RESET}"
    local found=()
    local tmp
    tmp=$(mktemp)

    for i in $(seq 1 254); do
        {
            local ip="${base}.${i}"
            if nc -z -w1 "$ip" "$port" 2>/dev/null; then
                echo "$ip" >> "$tmp"
            fi
        } &
        # Limitar a 50 procesos paralelos
        if [[ $(jobs -r | wc -l) -ge 50 ]]; then wait -n 2>/dev/null || wait; fi
    done
    wait

    if [[ -f "$tmp" ]]; then
        mapfile -t found < <(sort "$tmp")
        rm -f "$tmp"
    fi
    printf '%s\n' "${found[@]}"
}

# ── Scan de red ──────────────────────────────────────────────
scan_network() {
    echo -e "$(t scan_detecting)"
    local subnet
    subnet=$(get_local_subnet)
    if [[ -z "$subnet" ]]; then
        echo -e "${YELLOW}  No se pudo detectar la subred.${RESET}"
        read -rp "  Ingresa la subred (ej: 192.168.1.0/24): " subnet
        [[ -z "$subnet" ]] && return
    fi

    echo -e "$(t scan_running "$subnet" "$ACTIVE_PORT")"
    local found=()

    if command -v nmap &>/dev/null; then
        echo -e "$(t scan_nmap)"
        local current_ip=""
        while IFS= read -r line; do
            if echo "$line" | grep -q "Nmap scan report"; then
                current_ip=$(echo "$line" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}')
            fi
            if echo "$line" | grep -q "open" && [[ -n "$current_ip" ]]; then
                found+=("$current_ip")
                current_ip=""
            fi
        done < <(nmap -p "$ACTIVE_PORT" --open -T4 "$subnet" 2>/dev/null)
    else
        echo -e "$(t scan_sweep)"
        local base="${subnet%.*}"
        base="${base%.*}"
        local oct3="${subnet%.*}"
        oct3="${oct3##*.}"
        local scan_base="${subnet%%.*}.$(echo "$subnet" | cut -d. -f2).$(echo "$subnet" | cut -d. -f3)"
        mapfile -t found < <(ping_sweep "$scan_base" "$ACTIVE_PORT")
    fi

    if [[ ${#found[@]} -eq 0 ]]; then
        echo -e "${YELLOW}$(t scan_none "$ACTIVE_PORT")${RESET}"
        echo -e "${DIM}$(t scan_tip1)${RESET}"
        echo -e "${DIM}$(t scan_tip2)${RESET}"
        read -rp "$(t press_enter)" ; return
    fi

    echo -e "${GREEN}$(t scan_found)${RESET}"
    local i=1
    for ip in "${found[@]}"; do
        echo -e "  ${BOLD}[$i]${RESET} ${GREEN}$ip${RESET}"
        ((i++))
    done
    echo ""
    read -rp "$(t scan_pick "${#found[@]}")" choice
    [[ "$choice" == "0" || -z "$choice" ]] && return
    local idx=$((choice - 1))
    if [[ $idx -ge 0 && $idx -lt ${#found[@]} ]]; then
        connect_device "${found[$idx]}" "$ACTIVE_PORT"
    else
        echo -e "${RED}$(t invalid_opt)${RESET}"; sleep 1
    fi
}

# ── Conectar manual ──────────────────────────────────────────
connect_manual() {
    echo -e "$(t conn_manual)"
    echo -e "${DIM}$(t conn_port_act "$ACTIVE_PORT")${RESET}\n"
    read -rp "$(t conn_ip)" ip
    [[ -z "$ip" ]] && return
    read -rp "$(t conn_port_p "$ACTIVE_PORT")" port_in
    local port="${port_in:-$ACTIVE_PORT}"
    connect_device "$ip" "$port"
}

# ── Conectar ADB ─────────────────────────────────────────────
connect_device() {
    local ip="$1" port="${2:-$ACTIVE_PORT}"
    while true; do
        local target="${ip}:${port}"
        echo -e "$(t conn_connecting "$target")"
        local output
        output=$(adb connect "$target" 2>&1)

        if echo "$output" | grep -qiE "connected|already"; then
            echo -e "${GREEN}  OK  $output${RESET}"
            CONNECTED_DEVICE="$target"
            ACTIVE_PORT="$port"
            sleep 1
            local state
            state=$(adb -s "$target" get-state 2>/dev/null | tr -d '\r\n')
            if [[ "$state" == "device" ]]; then
                echo -e "${GREEN}$(t conn_authorized)${RESET}"
            else
                echo -e "${YELLOW}$(t conn_auth_wait)${RESET}"
            fi
            echo ""; read -rp "$(t press_enter)" ; return
        else
            echo -e "${RED}$(t conn_failed "$output")${RESET}"
            local yes_k; yes_k=$(t yes_key)
            local retry
            read -rp "$(t conn_retry_port "$port")" retry
            if [[ "${retry,,}" == "${yes_k,,}" ]]; then
                read -rp "$(t conn_enter_port)" new_port
                if [[ "$new_port" =~ ^[0-9]+$ && $new_port -ge 1024 && $new_port -le 65535 ]]; then
                    port="$new_port"
                else
                    echo -e "${RED}$(t port_invalid)${RESET}"
                    echo ""; read -rp "$(t press_enter)" ; return
                fi
            else
                CONNECTED_DEVICE=""; echo ""; read -rp "$(t press_enter)" ; return
            fi
        fi
    done
}

# ── Desconectar ───────────────────────────────────────────────
disconnect_device() {
    if [[ -z "$CONNECTED_DEVICE" ]]; then
        echo -e "${YELLOW}$(t conn_none)${RESET}"; sleep 1; return
    fi
    adb disconnect "$CONNECTED_DEVICE" &>/dev/null
    echo -e "${GREEN}$(t conn_disconn "$CONNECTED_DEVICE")${RESET}"
    CONNECTED_DEVICE=""; sleep 1
}

# ── Verificar conexion activa ─────────────────────────────────
assert_connection() {
    if [[ -z "$CONNECTED_DEVICE" ]]; then
        echo -e "${RED}$(t not_connected)${RESET}"; sleep 2; return 1
    fi
    return 0
}

# ── Habilitar ADB TCP desde USB ───────────────────────────────
enable_tcpip() {
    echo -e "$(t usb_title)"
    local usb_device
    usb_device=$(adb devices 2>/dev/null | grep -v "List of" | awk '/\tdevice$/{print $1}' | head -1)
    if [[ -z "$usb_device" ]]; then
        echo -e "${RED}$(t usb_none)${RESET}"
    else
        echo -e "${GREEN}$(t usb_found "$usb_device")${RESET}"
        read -rp "$(t conn_port_p "$ACTIVE_PORT")" tcp_port
        tcp_port="${tcp_port:-$ACTIVE_PORT}"
        adb -s "$usb_device" tcpip "$tcp_port"
        echo -e "${GREEN}$(t usb_ok "$tcp_port")${RESET}"
    fi
    echo ""; read -rp "$(t press_enter)"
}

# ── Shell interactivo ─────────────────────────────────────────
shell_interactive() {
    assert_connection || return
    echo -e "$(t shell_title "$CONNECTED_DEVICE")"
    echo -e "${DIM}$(t shell_hint)${RESET}"
    while true; do
        read -rp "$(echo -e "${GREEN}  shell > ${RESET}")" cmd
        [[ -z "$cmd" || "$cmd" == "exit" || "$cmd" == "quit" ]] && break
        echo -e "${DIM}  ----------------------------------------${RESET}"
        adb -s "$CONNECTED_DEVICE" shell "$cmd"
        echo -e "${DIM}  ----------------------------------------${RESET}\n"
    done
}

# ── Comando ADB directo ───────────────────────────────────────
adb_command() {
    assert_connection || return
    echo -e "$(t adbcmd_title "$CONNECTED_DEVICE")"
    echo -e "${DIM}$(t adbcmd_hint)${RESET}"
    while true; do
        read -rp "$(echo -e "${BLUE}  adb > ${RESET}")" cmd
        [[ -z "$cmd" || "$cmd" == "exit" || "$cmd" == "quit" ]] && break
        echo -e "${DIM}  ----------------------------------------${RESET}"
        # shellcheck disable=SC2086
        adb -s "$CONNECTED_DEVICE" $cmd
        echo -e "${DIM}  ----------------------------------------${RESET}\n"
    done
}

# ── Evaluar resultado de adb install ─────────────────────────
eval_install_result() {
    local output="$1"
    if echo "$output" | grep -q "Success"; then echo "ok"; return; fi
    if echo "$output" | grep -q "INSTALL_FAILED_UPDATE_INCOMPATIBLE"; then echo "incompatible"; return; fi
    if echo "$output" | grep -q "INSTALL_FAILED_VERSION_DOWNGRADE"; then echo "downgrade"; return; fi
    if echo "$output" | grep -q "INSTALL_FAILED_USER_RESTRICTED\|INSTALL_FAILED_UNKNOWN_SOURCES"; then echo "sources"; return; fi
    if echo "$output" | grep -q "INSTALL_FAILED_ALREADY_EXISTS"; then echo "ok"; return; fi
    if echo "$output" | grep -q "INSTALL_FAILED\|Failure\|Exception"; then echo "error:$output"; return; fi
    # Solo lineas informativas = exito silencioso
    local real_lines
    real_lines=$(echo "$output" | grep -vE "^Performing|^Streaming|^\[|^adb" | grep -v "^$")
    if [[ -z "$real_lines" ]]; then echo "ok"; return; fi
    echo "error:$output"
}

# ── Instalar APK ─────────────────────────────────────────────
install_apk() {
    assert_connection || return
    echo -e "$(t apk_title "$DOWNLOADS_DIR")"

    local apks=()
    while IFS= read -r -d '' f; do apks+=("$f"); done < <(find "$DOWNLOADS_DIR" -maxdepth 3 -name "*.apk" -print0 2>/dev/null)

    if [[ ${#apks[@]} -eq 0 ]]; then
        echo -e "${YELLOW}$(t apk_none "$DOWNLOADS_DIR")${RESET}"
        read -rp "  Ruta completa del APK (o Enter para cancelar): " custom
        [[ -z "$custom" || ! -f "$custom" ]] && return
        apks=("$custom")
    fi

    echo -e "${GREEN}$(t apk_found)${RESET}"
    local i=1
    for apk in "${apks[@]}"; do
        local sz; sz=$(du -sh "$apk" 2>/dev/null | cut -f1)
        echo -e "  ${BOLD}[$i]${RESET} ${YELLOW}$(basename "$apk")${RESET} ${DIM}($sz)${RESET}"
        echo -e "      ${DIM}$apk${RESET}"
        ((i++))
    done
    local extra=$i
    echo -e "  ${BOLD}[$extra]${RESET} ${DIM}Ingresar ruta manualmente${RESET}"
    echo ""
    read -rp "  Selecciona APK [1-$extra] o 0 para cancelar: " choice
    [[ "$choice" == "0" || -z "$choice" ]] && return

    local apk_path=""
    if [[ "$choice" == "$extra" ]]; then
        read -rp "  Ruta completa: " apk_path
        [[ ! -f "$apk_path" ]] && echo -e "${RED}  Archivo no encontrado.${RESET}"; sleep 1; return
    else
        local idx=$((choice - 1))
        if [[ $idx -ge 0 && $idx -lt ${#apks[@]} ]]; then
            apk_path="${apks[$idx]}"
        else
            echo -e "${RED}$(t invalid_opt)${RESET}"; sleep 1; return
        fi
    fi

    echo -e "$(t apk_mode_title)"
    echo "  [1] Normal"
    echo "  [2] Reemplazar (-r)"
    echo "  [3] Fuentes externas + reemplazar (-r -d)"
    read -rp "  Modo [1]: " mode; mode="${mode:-1}"

    echo -e "\n  Instalando $(basename "$apk_path") en $CONNECTED_DEVICE...\n"
    local res=""
    case "$mode" in
        2) res=$(adb -s "$CONNECTED_DEVICE" install -r "$apk_path" 2>&1) ;;
        3) res=$(adb -s "$CONNECTED_DEVICE" install -r -d "$apk_path" 2>&1) ;;
        *) res=$(adb -s "$CONNECTED_DEVICE" install "$apk_path" 2>&1) ;;
    esac

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        if echo "$line" | grep -qiE "Performing|Streaming"; then echo -e "${DIM}  >> $line${RESET}"
        elif echo "$line" | grep -qi "Success"; then echo -e "${GREEN}  >> $line${RESET}"
        elif echo "$line" | grep -qiE "Failure|Error|FAILED"; then echo -e "${RED}  >> $line${RESET}"
        else echo -e "${DIM}  >> $line${RESET}"; fi
    done <<< "$res"

    echo ""
    local result; result=$(eval_install_result "$res")
    case "$result" in
        ok)           echo -e "${GREEN}$(t apk_ok)${RESET}" ;;
        incompatible) echo -e "${RED}  ERR App incompatible. Desinstala la version anterior primero.${RESET}" ;;
        downgrade)    echo -e "${RED}  ERR Version mas antigua. Usa modo [3].${RESET}" ;;
        sources)      echo -e "${RED}$(t apk_sources)${RESET}" ;;
        *)            local err="${result#error:}"
                      echo -e "${RED}  ERR Error al instalar: $err${RESET}"
                      echo -e "${YELLOW}$(t apk_sources)${RESET}" ;;
    esac
    echo ""; read -rp "$(t press_enter)"
}

# ── Ver apps instaladas ───────────────────────────────────────
show_packages() {
    assert_connection || return
    echo -e "$(t pkg_title)"
    echo -e "$(t pkg_opts)"
    read -rp "  Opcion [1]: " opt; opt="${opt:-1}"
    echo -e "${DIM}  ----------------------------------------${RESET}"
    case "$opt" in
        1) adb -s "$CONNECTED_DEVICE" shell pm list packages | sort ;;
        2) adb -s "$CONNECTED_DEVICE" shell pm list packages -3 | sort ;;
        3) read -rp "  Buscar: " term
           adb -s "$CONNECTED_DEVICE" shell pm list packages | grep -i "$term" ;;
    esac
    echo -e "${DIM}  ----------------------------------------${RESET}\n"
    read -rp "$(t press_enter)"
}

# ── Desinstalar app ───────────────────────────────────────────
remove_apk() {
    assert_connection || return
    echo -e "$(t uninst_title)"
    local pkgs=()
    while IFS= read -r line; do
        local p="${line#package:}"; p="${p//$'\r'/}"
        [[ -n "$p" ]] && pkgs+=("$p")
    done < <(adb -s "$CONNECTED_DEVICE" shell pm list packages -3 2>/dev/null | sort)

    if [[ ${#pkgs[@]} -eq 0 ]]; then
        echo -e "${YELLOW}$(t uninst_none)${RESET}"; sleep 1; return
    fi

    local i=1
    for pkg in "${pkgs[@]}"; do
        echo -e "  ${BOLD}[$i]${RESET} $pkg"; ((i++))
    done
    echo ""
    read -rp "  Selecciona [1-${#pkgs[@]}] o escribe el nombre del paquete: " choice

    local pkg_name=""
    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        local idx=$((choice - 1))
        [[ $idx -ge 0 && $idx -lt ${#pkgs[@]} ]] && pkg_name="${pkgs[$idx]}"
    else
        pkg_name="$choice"
    fi
    [[ -z "$pkg_name" ]] && return

    local yes_k; yes_k=$(t yes_key)
    read -rp "$(t uninst_confirm "$pkg_name")" confirm
    [[ "${confirm,,}" != "${yes_k,,}" ]] && return
    adb -s "$CONNECTED_DEVICE" uninstall "$pkg_name"
    echo ""; read -rp "$(t press_enter)"
}

# ── Info del dispositivo ──────────────────────────────────────
device_info() {
    assert_connection || return
    echo -e "$(t info_title "$CONNECTED_DEVICE")"
    echo -e "${DIM}  ----------------------------------------${RESET}"
    local props=(
        "ro.product.brand:Marca:Brand"
        "ro.product.model:Modelo:Model"
        "ro.product.name:Nombre:Name"
        "ro.build.version.release:Android:Android"
        "ro.build.version.sdk:SDK:SDK"
        "ro.product.cpu.abi:CPU:CPU"
        "ro.serialno:Serie:Serial"
    )
    for entry in "${props[@]}"; do
        local prop="${entry%%:*}"
        local rest="${entry#*:}"
        local label_es="${rest%%:*}"
        local label_en="${rest##*:}"
        local label; [[ $LANG_SEL == "ES" ]] && label="$label_es" || label="$label_en"
        local val
        val=$(adb -s "$CONNECTED_DEVICE" shell getprop "$prop" 2>/dev/null | tr -d '\r\n')
        printf "  %-22s %s\n" "$label:" "$val"
    done
    echo -e "$(t info_storage)"
    adb -s "$CONNECTED_DEVICE" shell df /data 2>/dev/null | tail -1 | awk '{print "  "$0}'
    echo -e "$(t info_battery)"
    adb -s "$CONNECTED_DEVICE" shell dumpsys battery 2>/dev/null | grep -E "level|status|temperature" | sed 's/^/  /'
    echo ""; read -rp "$(t press_enter)"
}

# ── Screenshot ────────────────────────────────────────────────
take_screenshot() {
    assert_connection || return
    local ts; ts=$(date +%Y%m%d_%H%M%S)
    local pics_dir="$HOME/Pictures"
    local dest="$pics_dir/screenshot_${ts}.png"
    mkdir -p "$pics_dir"
    echo -e "$(t ss_title)"
    adb -s "$CONNECTED_DEVICE" shell screencap -p /sdcard/tmp_ss.png 2>/dev/null
    adb -s "$CONNECTED_DEVICE" pull /sdcard/tmp_ss.png "$dest" 2>&1 | tail -1
    adb -s "$CONNECTED_DEVICE" shell rm /sdcard/tmp_ss.png 2>/dev/null
    if [[ -f "$dest" ]]; then
        echo -e "${GREEN}$(t ss_ok "$dest")${RESET}"
        open "$dest" 2>/dev/null   # macOS: abrir con app predeterminada
    else
        echo -e "${RED}$(t ss_err)${RESET}"
    fi
    echo ""; read -rp "$(t press_enter)"
}

# ── Cambiar puerto ────────────────────────────────────────────
select_port() {
    echo -e "$(t port_title)"
    echo -e "${DIM}$(t port_hint)${RESET}\n"
    echo -e "$(t port_current "$ACTIVE_PORT")\n"
    read -rp "$(t port_prompt "$ACTIVE_PORT")" new_port
    [[ -z "$new_port" ]] && return
    if [[ "$new_port" =~ ^[0-9]+$ && $new_port -ge 1024 && $new_port -le 65535 ]]; then
        ACTIVE_PORT="$new_port"
        echo -e "${GREEN}$(t port_ok "$new_port")${RESET}"
    else
        echo -e "${RED}$(t port_invalid)${RESET}"
    fi
    echo ""; sleep 1
}

# ── Idioma ────────────────────────────────────────────────────
select_language() {
    echo -e "$(t lang_title)"
    if [[ $LANG_SEL == "ES" ]]; then echo -e "$(t lang_cur_es)"
    else echo -e "$(t lang_cur_en)"; fi
    echo ""
    echo "  [1]  Espanol"
    echo "  [2]  English"
    echo "  [0]  Volver / Back"
    echo ""
    read -rp "  Selecciona / Select: " opt
    case "$opt" in
        1) LANG_SEL="ES"; echo -e "${GREEN}$(t lang_ok_es)${RESET}"; sleep 1 ;;
        2) LANG_SEL="EN"; echo -e "${GREEN}$(t lang_ok_en)${RESET}"; sleep 1 ;;
        0) return ;;
        *) echo -e "${RED}$(t invalid_opt)${RESET}"; sleep 1 ;;
    esac
}

# ── DNS privado ───────────────────────────────────────────────
set_private_dns() {
    local dns_host="$1"
    adb -s "$CONNECTED_DEVICE" shell settings put global private_dns_mode hostname 2>/dev/null
    adb -s "$CONNECTED_DEVICE" shell settings put global private_dns_specifier "$dns_host" 2>/dev/null
    local verify
    verify=$(adb -s "$CONNECTED_DEVICE" shell settings get global private_dns_specifier 2>/dev/null | tr -d '\r\n')
    if [[ "$verify" == "$dns_host" ]]; then
        echo -e "${GREEN}$(t ads_set_ok "$dns_host")${RESET}"
        echo -e "${DIM}$(t ads_set_tip)${RESET}"
    else
        echo -e "${RED}  ERR No se pudo verificar la configuracion.${RESET}"
    fi
    echo ""; read -rp "$(t press_enter)"
}

# ── Bloqueo de publicidad ─────────────────────────────────────
manage_adblock() {
    assert_connection || return
    local yes_k; yes_k=$(t yes_key)
    while true; do
        local cur_mode cur_dns
        cur_mode=$(adb -s "$CONNECTED_DEVICE" shell settings get global private_dns_mode 2>/dev/null | tr -d '\r\n')
        cur_dns=$(adb -s "$CONNECTED_DEVICE" shell settings get global private_dns_specifier 2>/dev/null | tr -d '\r\n')
        echo -e "$(t ads_title "$CONNECTED_DEVICE")"
        echo -ne "$(t ads_status)"
        if [[ "$cur_mode" == "hostname" && -n "$cur_dns" && "$cur_dns" != "null" ]]; then
            echo -e "${GREEN}$(t ads_active "$cur_dns")${RESET}"
        else
            echo -e "${YELLOW}$(t ads_inactive)${RESET}"
        fi
        echo ""
        echo -e "${BLUE}  -- $([ $LANG_SEL == "ES" ] && echo "OPCIONES" || echo "OPTIONS") ----------------------${RESET}"
        echo "  [1]  DNS AdGuard       (dns.adguard.com)"
        echo "  [2]  DNS NextDNS       (requiere cuenta / requires account)"
        echo "  [3]  DNS Mullvad       (adblock.dns.mullvad.net)"
        echo "  [4]  DNS ControlD      (freedns.controld.com)"
        echo "  [5]  DNS personalizado / Custom DNS"
        echo "  [6]  Desactivar / Disable DNS"
        echo "  [7]  Instalar AdAway (modo VPN)"
        echo "  [0]  $([ $LANG_SEL == "ES" ] && echo "Volver al menu" || echo "Back to menu")"
        echo ""
        read -rp "$(t menu_prompt)" opt
        case "$opt" in
            1) set_private_dns "dns.adguard.com" ;;
            2) read -rp "$(t ads_nextdns_p)" id_nx
               [[ -n "$id_nx" ]] && set_private_dns "${id_nx}.dns.nextdns.io" ;;
            3) set_private_dns "adblock.dns.mullvad.net" ;;
            4) set_private_dns "freedns.controld.com" ;;
            5) read -rp "$(t ads_custom_p)" dns_host
               [[ -n "$dns_host" ]] && set_private_dns "$dns_host" ;;
            6) adb -s "$CONNECTED_DEVICE" shell settings put global private_dns_mode opportunistic 2>/dev/null
               adb -s "$CONNECTED_DEVICE" shell settings delete global private_dns_specifier 2>/dev/null
               echo -e "${GREEN}$(t ads_off_ok)${RESET}"; echo ""; read -rp "$(t press_enter)" ;;
            7) echo -e "$(t ads_adaway_t)"
               local adaway_apk
               adaway_apk=$(find "$DOWNLOADS_DIR" -maxdepth 3 -iname "*adaway*.apk" 2>/dev/null | head -1)
               local apk_path=""
               if [[ -n "$adaway_apk" ]]; then
                   echo -e "${GREEN}$(t ads_adaway_f "$(basename "$adaway_apk")")${RESET}"
                   read -rp "  Instalar? [${yes_k}/N]: " confirm
                   [[ "${confirm,,}" == "${yes_k,,}" ]] && apk_path="$adaway_apk"
               else
                   echo -e "${YELLOW}$(t ads_adaway_n)${RESET}"
                   read -rp "  Ruta del APK (o Enter para cancelar): " apk_path
               fi
               if [[ -n "$apk_path" && -f "$apk_path" ]]; then
                   local res; res=$(adb -s "$CONNECTED_DEVICE" install -r "$apk_path" 2>&1)
                   echo ""
                   if echo "$res" | grep -q "Success"; then echo -e "${GREEN}$(t ads_adaway_ok)${RESET}"
                   else echo -e "${RED}  ERR $res${RESET}"; fi
                   echo ""; read -rp "$(t press_enter)"
               fi ;;
            0) return ;;
            *) echo -e "${RED}$(t invalid_opt)${RESET}"; sleep 0.7 ;;
        esac
    done
}

# ── Gestionar bloatware ───────────────────────────────────────
manage_bloatware() {
    assert_connection || return
    local preset_list=(
        "com.nes.coreservice" "com.nes.otaservice" "com.nes.activation"
        "com.smart.ota" "com.adups.fota" "com.adups.fota.sysoper"
        "com.rockchip.setbox" "com.rockchip.gamestation"
        "com.android.browser" "com.android.email"
    )
    local yes_k; yes_k=$(t yes_key)

    while true; do
        echo -e "$(t blw_title "$CONNECTED_DEVICE")"
        echo -e "${YELLOW}$(t blw_quick)${RESET}"
        echo "  [6]  Eliminar com.nes.coreservice   (1 clic, sin root)"
        echo "  [7]  Deshabilitar com.nes.coreservice  (1 clic)"
        echo "  [8]  Ver estado de com.nes.coreservice"
        echo ""
        echo -e "${BLUE}$(t blw_manual)${RESET}"
        echo "  [1]  $([ $LANG_SEL == "ES" ] && echo "Deshabilitar paquete (disable-user)   - reversible" || echo "Disable package (disable-user)   - reversible")"
        echo "  [2]  $([ $LANG_SEL == "ES" ] && echo "Desinstalar paquete para usuario 0    - permanente sin root" || echo "Uninstall package for user 0    - permanent, no root")"
        echo "  [3]  $([ $LANG_SEL == "ES" ] && echo "Restaurar paquete desinstalado" || echo "Restore uninstalled package")"
        echo "  [4]  $([ $LANG_SEL == "ES" ] && echo "Limpiar lista predefinida de bloatware" || echo "Clean predefined bloatware list")"
        echo "  [5]  $([ $LANG_SEL == "ES" ] && echo "Ver paquetes deshabilitados" || echo "View disabled packages")"
        echo "  [0]  $([ $LANG_SEL == "ES" ] && echo "Volver al menu" || echo "Back to menu")"
        echo ""
        read -rp "$(t menu_prompt)" opt

        case "$opt" in
            6) # Acceso rapido NES - eliminar
                local pkg="com.nes.coreservice"
                echo -e "$(t nes_title "$pkg")"
                echo -e "${DIM}$(t nes_desc1)${RESET}"
                echo -e "${DIM}$(t nes_desc2)${RESET}"
                local chk; chk=$(adb -s "$CONNECTED_DEVICE" shell pm list packages 2>/dev/null | grep "com\.nes\.coreservice")
                if [[ -z "$chk" ]]; then
                    echo -e "${CYAN}$(t nes_not_found)${RESET}"
                    echo ""; read -rp "$(t press_enter)"; continue
                fi
                echo -e "${GREEN}$(t nes_found)${RESET}"
                echo "  [1]  $([ $LANG_SEL == "ES" ] && echo "Deshabilitar  (reversible)" || echo "Disable  (reversible)")"
                echo "  [2]  $([ $LANG_SEL == "ES" ] && echo "Desinstalar   (permanente, sin root)" || echo "Uninstall  (permanent, no root)")"
                echo "  [0]  $([ $LANG_SEL == "ES" ] && echo "Cancelar" || echo "Cancel")"
                echo ""
                read -rp "$(t menu_prompt)" sub
                case "$sub" in
                    1) local res; res=$(adb -s "$CONNECTED_DEVICE" shell pm disable-user "$pkg" 2>&1)
                       echo ""
                       if echo "$res" | grep -q "disabled"; then
                           echo -e "${GREEN}$(t nes_dis_ok "$pkg")${RESET}"
                           echo -e "${DIM}$(t nes_dis_tip)${RESET}"
                       else echo -e "${RED}  ERR $res${RESET}"; fi ;;
                    2) local res; res=$(adb -s "$CONNECTED_DEVICE" shell pm uninstall -k --user 0 "$pkg" 2>&1)
                       echo ""
                       if echo "$res" | grep -q "Success"; then
                           echo -e "${GREEN}$(t nes_uninst_ok "$pkg")${RESET}"
                           echo -e "${DIM}$(t nes_dis_tip)${RESET}"
                       else echo -e "${RED}  ERR $res${RESET}"; fi ;;
                    0) continue ;;
                    *) echo -e "${RED}$(t invalid_opt)${RESET}" ;;
                esac
                echo ""; read -rp "$(t press_enter)" ;;
            7) # Deshabilitar NES directo
                local pkg="com.nes.coreservice"
                echo -e "\n  [$([ $LANG_SEL == "ES" ] && echo "DESHABILITAR" || echo "DISABLE")] $pkg"
                echo -e "${DIM}  Ejecutando: pm disable-user $pkg${RESET}\n"
                local chk; chk=$(adb -s "$CONNECTED_DEVICE" shell pm list packages 2>/dev/null | grep "com\.nes\.coreservice")
                if [[ -z "$chk" ]]; then
                    echo -e "${CYAN}$(t nes_not_found)${RESET}"
                else
                    local res; res=$(adb -s "$CONNECTED_DEVICE" shell pm disable-user "$pkg" 2>&1)
                    echo ""
                    if echo "$res" | grep -q "disabled"; then
                        echo -e "${GREEN}  OK  Servicio deshabilitado correctamente.${RESET}"
                        echo -e "${DIM}  Comando ejecutado: pm disable-user $pkg${RESET}"
                    else echo -e "${RED}  ERR $res${RESET}"; fi
                fi
                echo ""; read -rp "$(t press_enter)" ;;
            8) # Status NES
                local pkg="com.nes.coreservice"
                echo -e "$(t nes_status_t)"
                echo -e "${DIM}$([ $LANG_SEL == "ES" ] && echo "  Consultando estado del paquete..." || echo "  Querying package state...")${RESET}\n"
                local all_pkgs dis_pkgs ena_pkgs
                all_pkgs=$(adb -s "$CONNECTED_DEVICE" shell pm list packages -a 2>/dev/null)
                dis_pkgs=$(adb -s "$CONNECTED_DEVICE" shell pm list packages -d 2>/dev/null)
                ena_pkgs=$(adb -s "$CONNECTED_DEVICE" shell pm list packages -e 2>/dev/null)
                echo -e "${DIM}  ----------------------------------------${RESET}"
                echo -e "  Paquete: $pkg"
                if ! echo "$all_pkgs" | grep -q "com\.nes\.coreservice"; then
                    echo -e "${YELLOW}$(t nes_s_none)${RESET}"
                elif echo "$dis_pkgs" | grep -q "com\.nes\.coreservice"; then
                    echo -e "${GREEN}$(t nes_s_disabled)${RESET}"
                elif echo "$ena_pkgs" | grep -q "com\.nes\.coreservice"; then
                    echo -e "${RED}$(t nes_s_enabled)${RESET}"
                else
                    echo -e "${GREEN}$(t nes_s_uninst)${RESET}"
                fi
                local dump_info
                dump_info=$(adb -s "$CONNECTED_DEVICE" shell dumpsys package "$pkg" 2>/dev/null | grep -E "enabledState|pkgFlags" | head -2)
                if [[ -n "$dump_info" ]]; then
                    echo ""; echo -e "${DIM}  Detalle:"
                    echo "$dump_info" | sed 's/^/  /'
                    echo -e "${RESET}"
                fi
                echo -e "${DIM}  ----------------------------------------${RESET}"
                echo ""; read -rp "$(t press_enter)" ;;
            1) echo -e "\n  $([ $LANG_SEL == "ES" ] && echo "Deshabilitar paquete (disable-user)" || echo "Disable package (disable-user)")"
               echo -e "${DIM}  $([ $LANG_SEL == "ES" ] && echo "El paquete se desactiva pero puede restaurarse." || echo "Package is disabled but can be restored.")${RESET}\n"
               read -rp "$(t blw_pkg_p)" pkg
               [[ -z "$pkg" ]] && continue
               local res; res=$(adb -s "$CONNECTED_DEVICE" shell pm disable-user "$pkg" 2>&1)
               echo ""
               if echo "$res" | grep -q "disabled"; then echo -e "${GREEN}$(t blw_dis_ok "$res")${RESET}"
               else echo -e "${RED}  ERR $res${RESET}"; fi
               echo ""; read -rp "$(t press_enter)" ;;
            2) echo -e "\n  $([ $LANG_SEL == "ES" ] && echo "Desinstalar para usuario 0 (permanente, sin root)" || echo "Uninstall for user 0 (permanent, no root)")"
               echo -e "${DIM}  $([ $LANG_SEL == "ES" ] && echo "El APK queda en el sistema pero invisible para todos los usuarios." || echo "APK stays in firmware but invisible to all users.")${RESET}\n"
               read -rp "$(t blw_pkg_p)" pkg
               [[ -z "$pkg" ]] && continue
               read -rp "$(t blw_confirm "$pkg")" confirm
               [[ "${confirm,,}" != "${yes_k,,}" ]] && continue
               local res; res=$(adb -s "$CONNECTED_DEVICE" shell pm uninstall -k --user 0 "$pkg" 2>&1)
               echo ""
               if echo "$res" | grep -q "Success"; then echo -e "${GREEN}$(t blw_uninst_ok)${RESET}"
               else echo -e "${RED}  ERR $res${RESET}"; fi
               echo ""; read -rp "$(t press_enter)" ;;
            3) echo -e "\n  $([ $LANG_SEL == "ES" ] && echo "Restaurar paquete desinstalado" || echo "Restore uninstalled package")\n"
               read -rp "$(t blw_pkg_p)" pkg
               [[ -z "$pkg" ]] && continue
               local res; res=$(adb -s "$CONNECTED_DEVICE" shell pm install-existing "$pkg" 2>&1)
               echo ""
               if echo "$res" | grep -qiE "Success|installed"; then echo -e "${GREEN}$(t blw_rest_ok)${RESET}"
               else echo -e "${RED}  ERR $res${RESET}"; fi
               echo ""; read -rp "$(t press_enter)" ;;
            4) echo -e "$(t blw_preset_t)"
               for p in "${preset_list[@]}"; do echo -e "${DIM}  $p${RESET}"; done
               echo ""
               echo "  [1] $([ $LANG_SEL == "ES" ] && echo "Deshabilitar todos (reversible)" || echo "Disable all (reversible)")"
               echo "  [2] $([ $LANG_SEL == "ES" ] && echo "Desinstalar todos para usuario 0 (permanente)" || echo "Uninstall all for user 0 (permanent)")"
               read -rp "  Modo: " mode
               read -rp "$(t blw_preset_c "${#preset_list[@]}")" confirm
               [[ "${confirm,,}" != "${yes_k,,}" ]] && continue
               echo ""
               for p in "${preset_list[@]}"; do
                   printf "  >> %-45s" "$p"
                   local res=""
                   if [[ "$mode" == "2" ]]; then
                       res=$(adb -s "$CONNECTED_DEVICE" shell pm uninstall -k --user 0 "$p" 2>&1)
                   else
                       res=$(adb -s "$CONNECTED_DEVICE" shell pm disable-user "$p" 2>&1)
                   fi
                   if echo "$res" | grep -qiE "Success|disabled"; then echo -e "${GREEN}OK${RESET}"
                   else echo -e "${DIM}SKIP${RESET}"; fi
               done
               echo ""; read -rp "$(t press_enter)" ;;
            5) echo -e "$(t blw_dis_list)"
               echo -e "${DIM}  ----------------------------------------${RESET}"
               adb -s "$CONNECTED_DEVICE" shell pm list packages -d | sort | sed 's/^/  /'
               echo -e "${DIM}  ----------------------------------------${RESET}\n"
               read -rp "$(t press_enter)" ;;
            0) return ;;
            *) echo -e "${RED}$(t invalid_opt)${RESET}"; sleep 0.7 ;;
        esac
    done
}

# ── SmartTubeNext ─────────────────────────────────────────────
install_smarttube() {
    assert_connection || return
    local pkg="com.liskovsoft.videomanager"
    local yes_k; yes_k=$(t yes_key)

    while true; do
        echo -e "$(t stn_title)"
        echo -e "${DIM}$(t stn_desc1)${RESET}"
        echo -e "${DIM}$(t stn_desc2)${RESET}"
        local installed
        installed=$(adb -s "$CONNECTED_DEVICE" shell pm list packages 2>/dev/null | grep "com\.liskovsoft")
        [[ -n "$installed" ]] && echo -e "${CYAN}$(t stn_already)${RESET}\n"
        echo "  [1]  $([ $LANG_SEL == "ES" ] && echo "Descargar e instalar ultima version" || echo "Download and install latest version")"
        echo "  [2]  $([ $LANG_SEL == "ES" ] && echo "Desinstalar SmartTubeNext" || echo "Uninstall SmartTubeNext")"
        echo "  [0]  $([ $LANG_SEL == "ES" ] && echo "Volver al menu" || echo "Back to menu")"
        echo ""
        read -rp "$(t menu_prompt)" opt

        case "$opt" in
            1) # Detectar arquitectura
               local cpu_abi
               cpu_abi=$(adb -s "$CONNECTED_DEVICE" shell getprop ro.product.cpu.abi 2>/dev/null | tr -d '\r\n')
               echo -e "${DIM}  CPU detectada: $cpu_abi${RESET}"

               local is_32bit=false
               echo "$cpu_abi" | grep -qiE "armeabi-v7a|armeabi" && is_32bit=true

               echo -e "$(t stn_checking)"

               # Consultar GitHub API
               local api_url="https://api.github.com/repos/yuliskov/SmartTube/releases/latest"
               local release_json
               release_json=$(curl -s -H "User-Agent: ADB-WiFi-Manager" -H "Accept: application/vnd.github.v3+json" --connect-timeout 15 "$api_url" 2>/dev/null)

               if [[ -z "$release_json" ]]; then
                   echo -e "${RED}$(t stn_api_err)${RESET}"
                   echo ""; read -rp "$(t press_enter)"; continue
               fi

               # Parsear version y assets con grep/sed (sin jq)
               local version
               version=$(echo "$release_json" | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')

               # Obtener lista de APKs disponibles
               local all_assets
               all_assets=$(echo "$release_json" | grep '"browser_download_url"' | sed 's/.*"browser_download_url": *"\([^"]*\)".*/\1/' | grep "\.apk$")

               local dl_url="" fname="" size_bytes=0

               if $is_32bit; then
                   # Buscar APK para armeabi-v7a
                   dl_url=$(echo "$all_assets" | grep -iE "armeabi_v7a|arm_v7|armv7|arm-v7" | head -1)
                   # Fallback: arm sin arm64
                   [[ -z "$dl_url" ]] && dl_url=$(echo "$all_assets" | grep -i "arm" | grep -iv "arm64\|aarch64" | head -1)
                   # Ultimo fallback: cualquier APK
                   [[ -z "$dl_url" ]] && dl_url=$(echo "$all_assets" | head -1)
               else
                   # arm64 o universal
                   dl_url=$(echo "$all_assets" | grep -ivE "armeabi_v7a|arm_v7|armv7|arm-v7|beta|x86$" | head -1)
                   [[ -z "$dl_url" ]] && dl_url=$(echo "$all_assets" | head -1)
               fi

               if [[ -z "$dl_url" ]]; then
                   echo -e "${RED}$(t stn_api_err)${RESET}"
                   echo ""; read -rp "$(t press_enter)"; continue
               fi

               fname=$(basename "$dl_url")
               local dl_path="$DOWNLOADS_DIR/$fname"

               # Obtener tamaño aproximado
               local size_info
               size_info=$(curl -sI "$dl_url" 2>/dev/null | grep -i "content-length" | awk '{print $2}' | tr -d '\r')
               local size_mb="?"
               [[ -n "$size_info" && "$size_info" =~ ^[0-9]+$ ]] && size_mb=$(echo "scale=1; $size_info/1048576" | bc 2>/dev/null || echo "?")

               echo -e "${GREEN}$(t stn_found "$version")${RESET}"
               echo -e "${DIM}  APK: $fname${RESET}"
               echo -e "${DIM}$(t stn_size "$size_mb")${RESET}\n"

               # Reusar si ya existe
               local skip_dl=false
               if [[ -f "$dl_path" ]]; then
                   read -rp "$(t stn_reuse)" reuse
                   [[ "${reuse,,}" == "${yes_k,,}" ]] && skip_dl=true
               fi

               read -rp "$(t stn_confirm)" confirm
               [[ "${confirm,,}" != "${yes_k,,}" ]] && continue

               if ! $skip_dl; then
                   echo -e "$(t stn_dl_start "$fname")"
                   # Descargar con progreso
                   if command -v curl &>/dev/null; then
                       curl -L --progress-bar -H "User-Agent: ADB-WiFi-Manager" -o "$dl_path" "$dl_url"
                   elif command -v wget &>/dev/null; then
                       wget -q --show-progress -O "$dl_path" "$dl_url"
                   else
                       echo -e "${RED}  ERR curl y wget no disponibles.${RESET}"
                       echo ""; read -rp "$(t press_enter)"; continue
                   fi
                   echo ""
                   if [[ ! -f "$dl_path" ]]; then
                       echo -e "${RED}$(t stn_dl_err)${RESET}"
                       echo ""; read -rp "$(t press_enter)"; continue
                   fi
                   echo -e "${GREEN}$(t stn_dl_ok "$dl_path")${RESET}"
               fi

               # Instalar
               echo -e "$(t stn_installing)"
               local res_lines
               res_lines=$(adb -s "$CONNECTED_DEVICE" install -r "$dl_path" 2>&1)
               echo ""
               while IFS= read -r line; do
                   [[ -z "$line" ]] && continue
                   if echo "$line" | grep -qiE "Performing|Streaming"; then echo -e "${DIM}  >> $line${RESET}"
                   elif echo "$line" | grep -qi "Success"; then echo -e "${GREEN}  >> $line${RESET}"
                   elif echo "$line" | grep -qiE "Failure|Error|FAILED"; then echo -e "${RED}  >> $line${RESET}"
                   else echo -e "${DIM}  >> $line${RESET}"; fi
               done <<< "$res_lines"
               echo ""

               # Verificar con reintentos
               echo -e "${DIM}$(t stn_verifying)${RESET}"
               local pkg_found=false
               for attempt in 1 2 3 4; do
                   for pn in "com.liskovsoft.videomanager" "com.liskovsoft.smarttube" "com.liskovsoft"; do
                       if adb -s "$CONNECTED_DEVICE" shell pm list packages -a 2>/dev/null | grep -q "$pn"; then
                           pkg_found=true; break 2
                       fi
                   done
                   [[ $attempt -lt 4 ]] && { echo -e "${DIM}  Reintento $attempt/4...${RESET}"; sleep 2; }
               done

               if $pkg_found; then
                   echo -e "${GREEN}$(t stn_inst_ok)${RESET}"
                   echo -e "${DIM}$(t stn_inst_tip)${RESET}"
               else
                   local result; result=$(eval_install_result "$res_lines")
                   case "$result" in
                       ok)           echo -e "${YELLOW}$(t stn_warn)${RESET}"
                                     echo -e "${DIM}$(t stn_warn2)${RESET}" ;;
                       incompatible) echo -e "${RED}  ERR App incompatible. Usa opcion [2] para desinstalar primero.${RESET}" ;;
                       downgrade)    echo -e "${RED}  ERR Version mas antigua. Usa opcion [2] para desinstalar primero.${RESET}" ;;
                       sources)      echo -e "${RED}  ERR Activa 'Origenes desconocidos' en Configuracion > Seguridad.${RESET}" ;;
                       *)            local err="${result#error:}"
                                     echo -e "${RED}  ERR Error al instalar: $err${RESET}" ;;
                   esac
               fi
               echo ""; read -rp "$(t press_enter)" ;;
            2) read -rp "  Desinstalar SmartTubeNext? [${yes_k}/N]: " confirm
               [[ "${confirm,,}" == "${yes_k,,}" ]] && {
                   local res; res=$(adb -s "$CONNECTED_DEVICE" uninstall "$pkg" 2>&1)
                   echo ""
                   if echo "$res" | grep -q "Success"; then echo -e "${GREEN}$(t stn_uninst_ok)${RESET}"
                   else echo -e "${RED}  ERR $res${RESET}"; fi
                   echo ""; read -rp "$(t press_enter)"
               } ;;
            0) return ;;
            *) echo -e "${RED}$(t invalid_opt)${RESET}"; sleep 0.7 ;;
        esac
    done
}

# ── Menu principal ────────────────────────────────────────────
main_menu() {
    while true; do
        banner
        echo -e "$(t menu_conn)"
        echo "  [1]  $([ $LANG_SEL == "ES" ] && echo "Escanear red y conectar" || echo "Scan network and connect")"
        echo "  [2]  $([ $LANG_SEL == "ES" ] && echo "Conectar por IP manual" || echo "Connect by manual IP")"
        echo "  [3]  $([ $LANG_SEL == "ES" ] && echo "Habilitar ADB WiFi desde USB" || echo "Enable ADB WiFi from USB")"
        echo "  [4]  $([ $LANG_SEL == "ES" ] && echo "Desconectar dispositivo" || echo "Disconnect device")"
        echo ""
        echo -e "$(t menu_cmd)"
        echo "  [5]  $([ $LANG_SEL == "ES" ] && echo "Shell interactivo (adb shell)" || echo "Interactive shell (adb shell)")"
        echo "  [6]  $([ $LANG_SEL == "ES" ] && echo "Comando ADB directo" || echo "Direct ADB command")"
        echo ""
        echo -e "$(t menu_apk)"
        echo "  [7]  $([ $LANG_SEL == "ES" ] && echo "Instalar APK desde Descargas" || echo "Install APK from Downloads")"
        echo "  [8]  $([ $LANG_SEL == "ES" ] && echo "Ver apps instaladas" || echo "View installed apps")"
        echo "  [9]  $([ $LANG_SEL == "ES" ] && echo "Desinstalar app" || echo "Uninstall app")"
        echo ""
        echo -e "$(t menu_opt)"
        echo "  [10] $([ $LANG_SEL == "ES" ] && echo "Gestionar bloatware" || echo "Manage bloatware")"
        echo "  [11] $([ $LANG_SEL == "ES" ] && echo "Bloqueo de publicidad" || echo "Ad blocking")"
        echo "  [16] $([ $LANG_SEL == "ES" ] && echo "YouTube sin publicidad (SmartTubeNext)" || echo "YouTube ad-free (SmartTubeNext)")"
        echo ""
        echo -e "$(t menu_util)"
        echo "  [12] $([ $LANG_SEL == "ES" ] && echo "Info del dispositivo" || echo "Device info")"
        echo "  [13] $([ $LANG_SEL == "ES" ] && echo "Captura de pantalla" || echo "Screenshot")"
        echo "  [14] Idioma / Language"
        echo -e "$(t port_menu "$ACTIVE_PORT")"
        echo ""
        echo -e "${RED}  [0]  $([ $LANG_SEL == "ES" ] && echo "Salir" || echo "Exit")${RESET}"
        echo ""
        read -rp "$(t menu_prompt)" opt

        case "$opt" in
            1)  scan_network ;;
            2)  connect_manual ;;
            3)  enable_tcpip ;;
            4)  disconnect_device ;;
            5)  shell_interactive ;;
            6)  adb_command ;;
            7)  install_apk ;;
            8)  show_packages ;;
            9)  remove_apk ;;
            10) manage_bloatware ;;
            11) manage_adblock ;;
            12) device_info ;;
            13) take_screenshot ;;
            14) select_language ;;
            15) select_port ;;
            16) install_smarttube ;;
            0)  echo -e "$(t menu_bye)"
                [[ -n "$CONNECTED_DEVICE" ]] && adb disconnect "$CONNECTED_DEVICE" &>/dev/null
                exit 0 ;;
            *)  echo -e "${RED}$(t invalid_opt)${RESET}"; sleep 0.7 ;;
        esac
    done
}

# ── Entry point ───────────────────────────────────────────────
check_deps
main_menu
