# ============================================================
#  ADB WiFi Manager - TV Box Tool (Windows) v4
#  Autor: Tony Reel
#  Idiomas: Espanol / English
#  Requisitos: adb en PATH (Android Platform Tools)
# ============================================================
#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = "SilentlyContinue"

# -- Config --------------------------------------------------
$ADB_PORT              = 5555
$DOWNLOADS_DIR         = "$env:USERPROFILE\Downloads"
$script:CONNECTED_DEVICE = ""
$script:LANG           = "ES"   # ES | EN
$script:ACTIVE_PORT    = 5555   # Puerto activo, puede cambiarse desde el menu

# ============================================================
#  SISTEMA DE IDIOMAS
# ============================================================
$script:Strings = @{

    # -- General
    "press_enter"       = @{ ES = "  Presiona Enter para continuar"; EN = "  Press Enter to continue" }
    "invalid_option"    = @{ ES = "  Opcion invalida.";              EN = "  Invalid option." }
    "cancelled"         = @{ ES = "  Cancelado.";                    EN = "  Cancelled." }
    "not_connected"     = @{ ES = "  No hay dispositivo conectado. Conectate primero."; EN = "  No device connected. Connect first." }
    "enter_to_exit"     = @{ ES = "  Presiona Enter para salir";     EN = "  Press Enter to exit" }

    # -- Dependencias
    "dep_missing"       = @{ ES = "  [ERROR] 'adb' no encontrado en PATH.";             EN = "  [ERROR] 'adb' not found in PATH." }
    "dep_download"      = @{ ES = "  Descarga Platform Tools:";                         EN = "  Download Platform Tools:" }
    "dep_path"          = @{ ES = "  Extrae en C:\platform-tools\ y agrega al PATH.";   EN = "  Extract to C:\platform-tools\ and add to PATH." }

    # -- Banner
    "banner_line1"      = @{ ES = "  |        ADB WiFi Manager - TV Box Tool        |"; EN = "  |        ADB WiFi Manager - TV Box Tool        |" }
    "banner_line2"      = @{ ES = "  |              by Leonel Rubira  v4            |"; EN = "  |              by Leonel Rubira  v4            |" }
    "banner_on"         = @{ ES = "  [ON]  Conectado: ";    EN = "  [ON]  Connected: " }
    "banner_model"      = @{ ES = "        Modelo: ";       EN = "        Model: " }
    "banner_off"        = @{ ES = "  [OFF] Sin dispositivo conectado"; EN = "  [OFF] No device connected" }

    # -- Menu principal
    "menu_conn"         = @{ ES = "  -- CONEXION ----------------------------------";    EN = "  -- CONNECTION --------------------------------" }
    "menu_m1"           = @{ ES = "  [1]  Escanear red y conectar";                     EN = "  [1]  Scan network and connect" }
    "menu_m2"           = @{ ES = "  [2]  Conectar por IP manual";                      EN = "  [2]  Connect by manual IP" }
    "menu_m3"           = @{ ES = "  [3]  Habilitar ADB WiFi desde USB";                EN = "  [3]  Enable ADB WiFi from USB" }
    "menu_m4"           = @{ ES = "  [4]  Desconectar dispositivo";                     EN = "  [4]  Disconnect device" }
    "menu_cmd"          = @{ ES = "  -- COMANDOS ----------------------------------";    EN = "  -- COMMANDS ----------------------------------" }
    "menu_m5"           = @{ ES = "  [5]  Shell interactivo (adb shell)";               EN = "  [5]  Interactive shell (adb shell)" }
    "menu_m6"           = @{ ES = "  [6]  Comando ADB directo";                         EN = "  [6]  Direct ADB command" }
    "menu_apk"          = @{ ES = "  -- APKs --------------------------------------";   EN = "  -- APKs --------------------------------------" }
    "menu_m7"           = @{ ES = "  [7]  Instalar APK desde Descargas";                EN = "  [7]  Install APK from Downloads" }
    "menu_m8"           = @{ ES = "  [8]  Ver apps instaladas";                         EN = "  [8]  View installed apps" }
    "menu_m9"           = @{ ES = "  [9]  Desinstalar app";                             EN = "  [9]  Uninstall app" }
    "menu_opt"          = @{ ES = "  -- OPTIMIZACION ------------------------------";   EN = "  -- OPTIMIZATION ------------------------------" }
    "menu_m10"          = @{ ES = "  [10] Gestionar bloatware";                         EN = "  [10] Manage bloatware" }
    "menu_m11"          = @{ ES = "  [11] Bloqueo de publicidad";                       EN = "  [11] Ad blocking" }
    "menu_util"         = @{ ES = "  -- UTILIDADES --------------------------------";   EN = "  -- UTILITIES ---------------------------------" }
    "menu_m12"          = @{ ES = "  [12] Info del dispositivo";                        EN = "  [12] Device info" }
    "menu_m13"          = @{ ES = "  [13] Captura de pantalla";                         EN = "  [13] Screenshot" }
    "menu_m14"          = @{ ES = "  [14] Idioma / Language";                           EN = "  [14] Idioma / Language" }
    "menu_m0"           = @{ ES = "  [0]  Salir";                                       EN = "  [0]  Exit" }
    "menu_prompt"       = @{ ES = "  Opcion: ";                                         EN = "  Option: " }
    "menu_bye"          = @{ ES = "`n  Hasta luego!`n";                                 EN = "`n  Goodbye!`n" }

    # -- Idioma
    "lang_title"        = @{ ES = "`n  [IDIOMA / LANGUAGE]`n";           EN = "`n  [IDIOMA / LANGUAGE]`n" }
    "lang_current_es"   = @{ ES = "  Idioma actual: Espanol";             EN = "  Current language: Spanish" }
    "lang_current_en"   = @{ ES = "  Current language: English";          EN = "  Current language: English" }
    "lang_opt1"         = @{ ES = "  [1]  Espanol";                       EN = "  [1]  Spanish" }
    "lang_opt2"         = @{ ES = "  [2]  English";                       EN = "  [2]  English" }
    "lang_opt0"         = @{ ES = "  [0]  Volver / Back";                 EN = "  [0]  Back / Volver" }
    "lang_prompt"       = @{ ES = "  Selecciona / Select: ";              EN = "  Select / Selecciona: " }
    "lang_set_es"       = @{ ES = "  OK  Idioma cambiado a Espanol.";     EN = "  OK  Language changed to Spanish." }
    "lang_set_en"       = @{ ES = "  OK  Language set to English.";       EN = "  OK  Language set to English." }

    # -- Adaptadores / Scan
    "adapters_title"    = @{ ES = "`n  Adaptadores de red disponibles:`n";  EN = "`n  Available network adapters:`n" }
    "adapters_virtual"  = @{ ES = " [VIRTUAL - omitir]";                    EN = " [VIRTUAL - skip]" }
    "adapters_pick"     = @{ ES = "  Selecciona tu adaptador WiFi/Ethernet real [1-{0}]: "; EN = "  Select your real WiFi/Ethernet adapter [1-{0}]: " }
    "adapters_none"     = @{ ES = "  No se encontro ningun adaptador activo.";              EN = "  No active network adapter found." }
    "adapters_fallback" = @{ ES = "  Entrada invalida, se usara el primero disponible.";    EN = "  Invalid input, using first available." }
    "scan_detecting"    = @{ ES = "`n  [SCAN] Selecciona la interfaz de red...";            EN = "`n  [SCAN] Select network interface..." }
    "scan_no_subnet"    = @{ ES = "  No se pudo detectar la subred automaticamente.";       EN = "  Could not detect subnet automatically." }
    "scan_manual_sub"   = @{ ES = "  Ingresa la subred manualmente (ej: 192.168.68.0/24)"; EN = "  Enter subnet manually (e.g.: 192.168.1.0/24)" }
    "scan_running"      = @{ ES = "`n  [SCAN] Escaneando {0} - puerto {1}...";              EN = "`n  [SCAN] Scanning {0} - port {1}..." }
    "scan_nmap"         = @{ ES = "  Usando nmap (rapido)...`n";                            EN = "  Using nmap (fast)...`n" }
    "scan_sweep"        = @{ ES = "  nmap no encontrado. Usando ping sweep paralelo...";    EN = "  nmap not found. Using parallel ping sweep..." }
    "scan_sweep2"       = @{ ES = "  Escaneando {0}.1-254 en puerto {1}...`n";              EN = "  Scanning {0}.1-254 on port {1}...`n" }
    "scan_none"         = @{ ES = "`n  No se encontraron dispositivos con ADB activo (puerto {0})."; EN = "`n  No devices found with ADB active (port {0})." }
    "scan_tip1"         = @{ ES = "  Activa 'Depuracion ADB/WiFi' en el TV Box.";          EN = "  Enable 'ADB/WiFi Debugging' on the TV Box." }
    "scan_tip2"         = @{ ES = "  Si es la primera vez usa opcion [3] con cable USB.`n"; EN = "  First time? Use option [3] with USB cable.`n" }
    "scan_found"        = @{ ES = "`n  Dispositivos encontrados con ADB activo:`n";         EN = "`n  Devices found with ADB active:`n" }
    "scan_pick"         = @{ ES = "  Selecciona [1-{0}] o 0 para cancelar";                EN = "  Select [1-{0}] or 0 to cancel" }

    # -- Conexion
    "conn_manual_title" = @{ ES = "`n  [CONECTAR MANUAL]";                  EN = "`n  [MANUAL CONNECT]" }
    "conn_ip"           = @{ ES = "  IP del dispositivo";                   EN = "  Device IP" }
    "conn_port"         = @{ ES = "  Puerto [{0}]";                         EN = "  Port [{0}]" }
    "conn_connecting"   = @{ ES = "`n  [ADB] Conectando a {0}...";          EN = "`n  [ADB] Connecting to {0}..." }
    "conn_ok"           = @{ ES = "  OK  {0}";                              EN = "  OK  {0}" }
    "conn_authorized"   = @{ ES = "  OK  Dispositivo autorizado y listo.";  EN = "  OK  Device authorized and ready." }
    "conn_auth_wait"    = @{ ES = "  >>  Acepta 'Permitir depuracion ADB' en la pantalla del TV Box."; EN = "  >>  Accept 'Allow ADB debugging' on the TV Box screen." }
    "conn_err"          = @{ ES = "  ERR {0}";                              EN = "  ERR {0}" }
    "conn_disconnected" = @{ ES = "`n  OK  Desconectado de {0}";            EN = "`n  OK  Disconnected from {0}" }
    "conn_not_conn"     = @{ ES = "`n  No hay dispositivo conectado.";      EN = "`n  No device connected." }

    # -- USB TCP
    "usb_title"         = @{ ES = "`n  [HABILITAR ADB WIFI] Conecta el TV Box por USB primero.`n"; EN = "`n  [ENABLE ADB WIFI] Connect the TV Box via USB first.`n" }
    "usb_none"          = @{ ES = "  No se detecto dispositivo USB.";       EN = "  No USB device detected." }
    "usb_found"         = @{ ES = "  Dispositivo USB: {0}";                 EN = "  USB device: {0}" }
    "usb_ok"            = @{ ES = "  OK  ADB escuchando en puerto {0}. Desconecta el USB y usa Scan."; EN = "  OK  ADB listening on port {0}. Disconnect USB and use Scan." }

    # -- Shell
    "shell_title"       = @{ ES = "`n  [SHELL] {0}";                        EN = "`n  [SHELL] {0}" }
    "shell_hint"        = @{ ES = "  Escribe 'exit' para volver al menu.`n"; EN = "  Type 'exit' to return to menu.`n" }
    "shell_prompt"      = @{ ES = "  shell > ";                             EN = "  shell > " }
    "adbcmd_title"      = @{ ES = "`n  [ADB CMD] {0}";                      EN = "`n  [ADB CMD] {0}" }
    "adbcmd_hint"       = @{ ES = "  Ej: reboot, logcat, bugreport. Escribe 'exit' para volver.`n"; EN = "  E.g.: reboot, logcat, bugreport. Type 'exit' to return.`n" }
    "adbcmd_prompt"     = @{ ES = "  adb > ";                               EN = "  adb > " }

    # -- APK Install
    "apk_title"         = @{ ES = "`n  [INSTALAR APK] Buscando en: {0}`n";  EN = "`n  [INSTALL APK] Searching in: {0}`n" }
    "apk_none"          = @{ ES = "  No se encontraron .apk en {0}";        EN = "  No .apk files found in {0}" }
    "apk_custom"        = @{ ES = "  Ingresa ruta completa del APK (o Enter para cancelar)"; EN = "  Enter full APK path (or Enter to cancel)" }
    "apk_notfound"      = @{ ES = "  Cancelado o archivo no encontrado.";   EN = "  Cancelled or file not found." }
    "apk_found"         = @{ ES = "  APKs encontrados:`n";                  EN = "  APKs found:`n" }
    "apk_manual_entry"  = @{ ES = "  [{0}] Ingresar ruta manualmente";      EN = "  [{0}] Enter path manually" }
    "apk_pick"          = @{ ES = "  Selecciona APK [1-{0}] o 0 para cancelar"; EN = "  Select APK [1-{0}] or 0 to cancel" }
    "apk_manual_path"   = @{ ES = "  Ruta completa del APK";                EN = "  Full APK path" }
    "apk_mode_title"    = @{ ES = "`n  Modo de instalacion:";               EN = "`n  Installation mode:" }
    "apk_mode1"         = @{ ES = "  [1] Normal";                           EN = "  [1] Normal" }
    "apk_mode2"         = @{ ES = "  [2] Reemplazar app existente (-r)";    EN = "  [2] Replace existing app (-r)" }
    "apk_mode3"         = @{ ES = "  [3] Fuentes externas + reemplazar (-r -d)"; EN = "  [3] Unknown sources + replace (-r -d)" }
    "apk_mode_prompt"   = @{ ES = "  Modo [1]";                             EN = "  Mode [1]" }
    "apk_installing"    = @{ ES = "`n  Instalando {0} en {1}...`n";         EN = "`n  Installing {0} on {1}...`n" }
    "apk_ok"            = @{ ES = "  OK  APK instalada correctamente.";     EN = "  OK  APK installed successfully." }
    "apk_err"           = @{ ES = "  ERR Error al instalar: {0}";           EN = "  ERR Installation error: {0}" }
    "apk_sources_tip"   = @{ ES = "  Verifica 'Origenes desconocidos' en Configuracion > Seguridad."; EN = "  Check 'Unknown sources' in Settings > Security." }

    # -- Packages
    "pkg_title"         = @{ ES = "`n  [PAQUETES]`n";            EN = "`n  [PACKAGES]`n" }
    "pkg_opt1"          = @{ ES = "  [1] Todas  [2] Solo terceros  [3] Buscar"; EN = "  [1] All  [2] Third-party only  [3] Search" }
    "pkg_prompt"        = @{ ES = "  Opcion [1]";                EN = "  Option [1]" }
    "pkg_search"        = @{ ES = "  Buscar";                    EN = "  Search" }

    # -- Uninstall
    "uninst_title"      = @{ ES = "`n  [DESINSTALAR] Cargando apps de terceros...`n"; EN = "`n  [UNINSTALL] Loading third-party apps...`n" }
    "uninst_none"       = @{ ES = "  Sin apps de terceros.";     EN = "  No third-party apps found." }
    "uninst_pick"       = @{ ES = "  Selecciona [1-{0}] o escribe el paquete"; EN = "  Select [1-{0}] or type package name" }
    "uninst_confirm"    = @{ ES = "  Desinstalar '{0}'? [s/N]";  EN = "  Uninstall '{0}'? [y/N]" }
    "uninst_yes"        = @{ ES = "s";                           EN = "y" }

    # -- Device Info
    "info_title"        = @{ ES = "`n  [INFO] {0}`n";            EN = "`n  [INFO] {0}`n" }
    "info_brand"        = @{ ES = "Marca";                       EN = "Brand" }
    "info_model"        = @{ ES = "Modelo";                      EN = "Model" }
    "info_name"         = @{ ES = "Nombre";                      EN = "Name" }
    "info_android"      = @{ ES = "Android";                     EN = "Android" }
    "info_sdk"          = @{ ES = "SDK";                         EN = "SDK" }
    "info_cpu"          = @{ ES = "CPU";                         EN = "CPU" }
    "info_serial"       = @{ ES = "Serie";                       EN = "Serial" }
    "info_storage"      = @{ ES = "`n  Almacenamiento:";         EN = "`n  Storage:" }
    "info_battery"      = @{ ES = "`n  Bateria:";                EN = "`n  Battery:" }

    # -- Screenshot
    "ss_title"          = @{ ES = "`n  [SCREENSHOT] Capturando..."; EN = "`n  [SCREENSHOT] Capturing..." }
    "ss_ok"             = @{ ES = "  OK  Guardado: {0}";            EN = "  OK  Saved: {0}" }
    "ss_err"            = @{ ES = "  ERR No se pudo capturar.";     EN = "  ERR Could not capture screenshot." }

    # -- Bloatware
    "blw_title"         = @{ ES = "`n  [BLOATWARE] {0}`n";                  EN = "`n  [BLOATWARE] {0}`n" }
    "blw_quick"         = @{ ES = "  -- Acceso rapido ---------------------------------"; EN = "  -- Quick access -----------------------------------" }
    "blw_q6"            = @{ ES = "  [6]  Eliminar com.nes.coreservice   (1 clic, sin root)"; EN = "  [6]  Remove com.nes.coreservice   (1 click, no root)" }
    "blw_manual"        = @{ ES = "  -- Opciones manuales -----------------------------"; EN = "  -- Manual options ---------------------------------" }
    "blw_o1"            = @{ ES = "  [1]  Deshabilitar paquete (disable-user)   - reversible";  EN = "  [1]  Disable package (disable-user)   - reversible" }
    "blw_o2"            = @{ ES = "  [2]  Desinstalar paquete para usuario 0    - permanente sin root"; EN = "  [2]  Uninstall package for user 0    - permanent, no root" }
    "blw_o3"            = @{ ES = "  [3]  Restaurar paquete desinstalado";       EN = "  [3]  Restore uninstalled package" }
    "blw_o4"            = @{ ES = "  [4]  Limpiar lista predefinida de bloatware"; EN = "  [4]  Clean predefined bloatware list" }
    "blw_o5"            = @{ ES = "  [5]  Ver paquetes deshabilitados";          EN = "  [5]  View disabled packages" }
    "blw_o0"            = @{ ES = "  [0]  Volver al menu";                       EN = "  [0]  Back to menu" }
    "blw_disable_title" = @{ ES = "`n  Deshabilitar paquete (disable-user)";     EN = "`n  Disable package (disable-user)" }
    "blw_disable_hint"  = @{ ES = "  El paquete se desactiva pero puede restaurarse.`n"; EN = "  Package is disabled but can be restored.`n" }
    "blw_pkg_prompt"    = @{ ES = "  Nombre del paquete (ej: com.nes.coreservice)"; EN = "  Package name (e.g.: com.nes.coreservice)" }
    "blw_disabled_ok"   = @{ ES = "  OK  {0}";                                  EN = "  OK  {0}" }
    "blw_uninst_title"  = @{ ES = "`n  Desinstalar para usuario 0 (permanente, sin root)"; EN = "`n  Uninstall for user 0 (permanent, no root)" }
    "blw_uninst_hint"   = @{ ES = "  El APK queda en el sistema pero no existe para ningun usuario.`n"; EN = "  The APK stays in firmware but is invisible to all users.`n" }
    "blw_uninst_confirm"= @{ ES = "  Desinstalar '{0}'? [s/N]";                 EN = "  Uninstall '{0}'? [y/N]" }
    "blw_uninst_ok"     = @{ ES = "  OK  Paquete eliminado correctamente.";     EN = "  OK  Package removed successfully." }
    "blw_restore_title" = @{ ES = "`n  Restaurar paquete desinstalado`n";       EN = "`n  Restore uninstalled package`n" }
    "blw_restore_pkg"   = @{ ES = "  Nombre del paquete a restaurar";           EN = "  Package name to restore" }
    "blw_restore_ok"    = @{ ES = "  OK  Paquete restaurado.";                  EN = "  OK  Package restored." }
    "blw_preset_title"  = @{ ES = "`n  Lista predefinida de bloatware comun:`n"; EN = "`n  Predefined common bloatware list:`n" }
    "blw_preset_mode"   = @{ ES = "  Modo de limpieza:";                        EN = "  Cleaning mode:" }
    "blw_preset_m1"     = @{ ES = "  [1] Deshabilitar todos (reversible)";      EN = "  [1] Disable all (reversible)" }
    "blw_preset_m2"     = @{ ES = "  [2] Desinstalar todos para usuario 0 (permanente)"; EN = "  [2] Uninstall all for user 0 (permanent)" }
    "blw_preset_mode_p" = @{ ES = "  Modo";                                     EN = "  Mode" }
    "blw_preset_confirm"= @{ ES = "  Procesar {0} paquetes? [s/N]";             EN = "  Process {0} packages? [y/N]" }
    "blw_preset_skip"   = @{ ES = "   SKIP (no instalado)";                     EN = "   SKIP (not installed)" }
    "blw_preset_done"   = @{ ES = "  Listo. Presiona Enter para continuar";     EN = "  Done. Press Enter to continue" }
    "blw_disabled_list" = @{ ES = "`n  Paquetes deshabilitados en el dispositivo:`n"; EN = "`n  Disabled packages on device:`n" }

    # -- Acceso rapido NES
    "nes_title"         = @{ ES = "`n  [ACCESO RAPIDO] Eliminar {0}`n";         EN = "`n  [QUICK ACCESS] Remove {0}`n" }
    "nes_desc1"         = @{ ES = "  Servicio de telemetria/spyware comun en TV Boxes genericos chinos."; EN = "  Telemetry/spyware service common in generic Chinese TV Boxes." }
    "nes_desc2"         = @{ ES = "  Su eliminacion es segura y no afecta el funcionamiento del dispositivo.`n"; EN = "  Its removal is safe and does not affect device functionality.`n" }
    "nes_not_found"     = @{ ES = "  INFO El paquete no esta instalado en este dispositivo."; EN = "  INFO Package is not installed on this device." }
    "nes_found"         = @{ ES = "  Paquete encontrado. Como deseas eliminarlo?`n"; EN = "  Package found. How do you want to remove it?`n" }
    "nes_opt1"          = @{ ES = "  [1]  Deshabilitar  (reversible - recomendado si no estas seguro)"; EN = "  [1]  Disable  (reversible - recommended if unsure)" }
    "nes_opt2"          = @{ ES = "  [2]  Desinstalar   (permanente - limpieza definitiva sin root)";   EN = "  [2]  Uninstall (permanent - definitive cleanup, no root)" }
    "nes_opt0"          = @{ ES = "  [0]  Cancelar";                            EN = "  [0]  Cancel" }
    "nes_disabled_ok"   = @{ ES = "  OK  {0} deshabilitado correctamente.";     EN = "  OK  {0} disabled successfully." }
    "nes_disabled_tip"  = @{ ES = "      Para restaurarlo usa la opcion [3] de este menu."; EN = "      To restore it use option [3] in this menu." }
    "nes_uninst_ok"     = @{ ES = "  OK  {0} eliminado permanentemente.";       EN = "  OK  {0} permanently removed." }

    # -- AdBlock
    "ads_title"         = @{ ES = "`n  [BLOQUEO DE PUBLICIDAD] {0}`n";   EN = "`n  [AD BLOCKING] {0}`n" }
    "ads_status_on"     = @{ ES = "  Estado DNS: ";                       EN = "  DNS Status: " }
    "ads_active"        = @{ ES = "ACTIVO  ->  {0}";                      EN = "ACTIVE  ->  {0}" }
    "ads_inactive"      = @{ ES = "Sin DNS bloqueador configurado";       EN = "No ad-blocking DNS configured" }
    "ads_o1"            = @{ ES = "  [1]  Activar DNS AdGuard       (dns.adguard.com)";         EN = "  [1]  Enable AdGuard DNS       (dns.adguard.com)" }
    "ads_o2"            = @{ ES = "  [2]  Activar DNS NextDNS        (requiere cuenta)";         EN = "  [2]  Enable NextDNS            (requires account)" }
    "ads_o3"            = @{ ES = "  [3]  Activar DNS Mullvad        (adblock.dns.mullvad.net)"; EN = "  [3]  Enable Mullvad DNS        (adblock.dns.mullvad.net)" }
    "ads_o4"            = @{ ES = "  [4]  Activar DNS ControlD       (freedns.controld.com)";   EN = "  [4]  Enable ControlD DNS       (freedns.controld.com)" }
    "ads_o5"            = @{ ES = "  [5]  DNS personalizado";              EN = "  [5]  Custom DNS" }
    "ads_o6"            = @{ ES = "  [6]  Desactivar DNS bloqueador";     EN = "  [6]  Disable ad-blocking DNS" }
    "ads_o7"            = @{ ES = "  [7]  Instalar AdAway (modo VPN, bloqueo avanzado)"; EN = "  [7]  Install AdAway (VPN mode, advanced blocking)" }
    "ads_o0"            = @{ ES = "  [0]  Volver al menu";                EN = "  [0]  Back to menu" }
    "ads_nextdns_hint"  = @{ ES = "`n  Registrate gratis en https://nextdns.io y copia tu ID.`n"; EN = "`n  Register for free at https://nextdns.io and copy your ID.`n" }
    "ads_nextdns_id"    = @{ ES = "  Tu ID de NextDNS (ej: abc123)";      EN = "  Your NextDNS ID (e.g.: abc123)" }
    "ads_custom_title"  = @{ ES = "`n  DNS privado personalizado`n";      EN = "`n  Custom private DNS`n" }
    "ads_custom_prompt" = @{ ES = "  Hostname del DNS (ej: mi.dns.com)";  EN = "  DNS hostname (e.g.: my.dns.com)" }
    "ads_disabled_ok"   = @{ ES = "`n  OK  DNS bloqueador desactivado. Usando DNS del router."; EN = "`n  OK  Ad-blocking DNS disabled. Using router DNS." }
    "ads_adaway_title"  = @{ ES = "`n  [ADAWAY] Instalacion via ADB`n";   EN = "`n  [ADAWAY] Installation via ADB`n" }
    "ads_adaway_hint1"  = @{ ES = "  AdAway en modo VPN filtra anuncios sin root.";              EN = "  AdAway in VPN mode filters ads without root." }
    "ads_adaway_hint2"  = @{ ES = "  Descarga el APK desde: https://adaway.org`n";              EN = "  Download the APK from: https://adaway.org`n" }
    "ads_adaway_found"  = @{ ES = "  APK encontrado: {0}";                EN = "  APK found: {0}" }
    "ads_adaway_inst"   = @{ ES = "  Instalar? [s/N]";                    EN = "  Install? [y/N]" }
    "ads_adaway_none"   = @{ ES = "  No se encontro adaway*.apk en {0}";  EN = "  adaway*.apk not found in {0}" }
    "ads_adaway_path"   = @{ ES = "  Ingresa la ruta del APK (o Enter para cancelar)"; EN = "  Enter APK path (or Enter to cancel)" }
    "ads_adaway_ok"     = @{ ES = "  OK  AdAway instalado. Abrelo y activa el modo VPN."; EN = "  OK  AdAway installed. Open it and enable VPN mode." }
    "ads_dns_ok"        = @{ ES = "  OK  DNS privado configurado: {0}";   EN = "  OK  Private DNS configured: {0}" }
    "ads_dns_tip"       = @{ ES = "  Los anuncios seran bloqueados a nivel de red en todo el dispositivo."; EN = "  Ads will be blocked at network level across the entire device." }
    "ads_dns_err"       = @{ ES = "  ERR No se pudo verificar la configuracion."; EN = "  ERR Could not verify the configuration." }

    # -- Health check / Red
    "net_lost"          = @{ ES = "  [OFF] Conexion perdida (cambio de red detectado)"; EN = "  [OFF] Connection lost (network change detected)" }
    "net_lost_detail"   = @{ ES = "        Reconecta el dispositivo con opcion [1] o [2]"; EN = "        Reconnect the device using option [1] or [2]" }
    "net_checking"      = @{ ES = "  Verificando conexion..."; EN = "  Checking connection..." }

    # -- Puerto
    "port_current"      = @{ ES = "  Puerto activo: {0}";                               EN = "  Active port: {0}" }
    "port_change_title" = @{ ES = "`n  [CAMBIAR PUERTO ADB]`n";                         EN = "`n  [CHANGE ADB PORT]`n" }
    "port_hint"         = @{ ES = "  Puerto por defecto: 5555. Android 11+ puede usar un puerto diferente."; EN = "  Default port: 5555. Android 11+ may use a different port." }
    "port_prompt"       = @{ ES = "  Nuevo puerto [{0}]: ";                              EN = "  New port [{0}]: " }
    "port_invalid"      = @{ ES = "  ERR Puerto invalido. Debe ser un numero entre 1024 y 65535."; EN = "  ERR Invalid port. Must be a number between 1024 and 65535." }
    "port_set"          = @{ ES = "  OK  Puerto cambiado a {0}. Se usara en las proximas conexiones."; EN = "  OK  Port changed to {0}. It will be used in future connections." }
    "port_conn_failed"  = @{ ES = "  ERR No se pudo conectar en puerto {0}.";            EN = "  ERR Could not connect on port {0}." }
    "port_try_other"    = @{ ES = "  Deseas intentar con otro puerto? [s/N]: ";          EN = "  Do you want to try a different port? [y/N]: " }
    "port_enter_other"  = @{ ES = "  Ingresa el puerto a probar: ";                      EN = "  Enter the port to try: " }
    "port_menu"         = @{ ES = "  [15] Cambiar puerto ADB [{0}]";                     EN = "  [15] Change ADB port [{0}]" }

    # -- NES disable directo y status
    "nes_disable_title" = @{ ES = "`n  [DESHABILITAR] com.nes.coreservice`n";          EN = "`n  [DISABLE] com.nes.coreservice`n" }
    "nes_disable_cmd"   = @{ ES = "  Ejecutando: pm disable-user com.nes.coreservice"; EN = "  Running: pm disable-user com.nes.coreservice" }
    "nes_disable_ok"    = @{ ES = "  OK  Servicio deshabilitado correctamente.";        EN = "  OK  Service disabled successfully." }
    "nes_disable_err"   = @{ ES = "  ERR No se pudo deshabilitar: {0}";                 EN = "  ERR Could not disable: {0}" }
    "nes_disable_na"    = @{ ES = "  INFO El paquete no esta instalado en este dispositivo."; EN = "  INFO Package is not installed on this device." }
    "nes_status_title"  = @{ ES = "`n  [STATUS] com.nes.coreservice`n";                EN = "`n  [STATUS] com.nes.coreservice`n" }
    "nes_status_cmd"    = @{ ES = "  Consultando estado del paquete...";                EN = "  Querying package state..." }
    "nes_status_ena"    = @{ ES = "  Estado:  ACTIVO / HABILITADO";                    EN = "  Status:  ACTIVE / ENABLED" }
    "nes_status_dis"    = @{ ES = "  Estado:  DESHABILITADO (disable-user)";           EN = "  Status:  DISABLED (disable-user)" }
    "nes_status_uninst" = @{ ES = "  Estado:  DESINSTALADO para usuario 0";            EN = "  Status:  UNINSTALLED for user 0" }
    "nes_status_none"   = @{ ES = "  Estado:  NO INSTALADO en este dispositivo";       EN = "  Status:  NOT INSTALLED on this device" }
    "nes_status_raw"    = @{ ES = "  Respuesta raw: {0}";                              EN = "  Raw response: {0}" }
    "blw_q7"            = @{ ES = "  [7]  Deshabilitar com.nes.coreservice  (1 clic)"; EN = "  [7]  Disable com.nes.coreservice  (1 click)" }

    # -- SmartTubeNext
    "stn_menu"          = @{ ES = "  [16] YouTube sin publicidad (SmartTubeNext)";      EN = "  [16] YouTube ad-free (SmartTubeNext)" }
    "stn_title"         = @{ ES = "`n  [SMARTTUBENEXT] YouTube sin publicidad`n";        EN = "`n  [SMARTTUBENEXT] YouTube ad-free`n" }
    "stn_desc1"         = @{ ES = "  App alternativa de YouTube para Android TV.";       EN = "  Alternative YouTube app for Android TV." }
    "stn_desc2"         = @{ ES = "  Bloquea publicidad, sin root, sin cuenta requerida.`n"; EN = "  Blocks ads, no root, no account required.`n" }
    "stn_checking"      = @{ ES = "  Consultando ultima version en GitHub...";           EN = "  Checking latest version on GitHub..." }
    "stn_found"         = @{ ES = "  Version encontrada: {0}";                           EN = "  Version found: {0}" }
    "stn_size"          = @{ ES = "  Tamano del APK: {0} MB";                            EN = "  APK size: {0} MB" }
    "stn_downloading"   = @{ ES = "`n  Descargando {0}...";                              EN = "`n  Downloading {0}..." }
    "stn_dl_ok"         = @{ ES = "  OK  Descargado en: {0}";                            EN = "  OK  Downloaded to: {0}" }
    "stn_dl_err"        = @{ ES = "  ERR Error al descargar. Verifica tu conexion.";     EN = "  ERR Download error. Check your connection." }
    "stn_api_err"       = @{ ES = "  ERR No se pudo consultar GitHub API.";              EN = "  ERR Could not reach GitHub API." }
    "stn_installing"    = @{ ES = "`n  Instalando SmartTubeNext en el dispositivo...`n"; EN = "`n  Installing SmartTubeNext on device...`n" }
    "stn_inst_ok"       = @{ ES = "  OK  SmartTubeNext instalado correctamente.";        EN = "  OK  SmartTubeNext installed successfully." }
    "stn_inst_tip"      = @{ ES = "  Abrelo desde el menu de apps del TV Box.";          EN = "  Open it from the TV Box app menu." }
    "stn_inst_err"      = @{ ES = "  ERR Error al instalar: {0}";                        EN = "  ERR Install error: {0}" }
    "stn_already"       = @{ ES = "  INFO SmartTubeNext ya esta instalado.";             EN = "  INFO SmartTubeNext is already installed." }
    "stn_update"        = @{ ES = "  Deseas actualizarlo a la ultima version? [s/N]: "; EN = "  Do you want to update to the latest version? [y/N]: " }
    "stn_opt1"          = @{ ES = "  [1]  Descargar e instalar ultima version";          EN = "  [1]  Download and install latest version" }
    "stn_opt2"          = @{ ES = "  [2]  Desinstalar SmartTubeNext";                    EN = "  [2]  Uninstall SmartTubeNext" }
    "stn_opt0"          = @{ ES = "  [0]  Volver al menu";                               EN = "  [0]  Back to menu" }
    "stn_uninst_ok"     = @{ ES = "  OK  SmartTubeNext desinstalado.";                   EN = "  OK  SmartTubeNext uninstalled." }
    "stn_uninst_err"    = @{ ES = "  ERR No se pudo desinstalar: {0}";                   EN = "  ERR Could not uninstall: {0}" }
    "stn_confirm"       = @{ ES = "  Descargar e instalar? [s/N]: ";                     EN = "  Download and install? [y/N]: " }
    "stn_progress"      = @{ ES = "  Progreso: {0}%";                                    EN = "  Progress: {0}%" }
    "blw_q8"            = @{ ES = "  [8]  Ver estado de com.nes.coreservice";          EN = "  [8]  Check com.nes.coreservice status" }
}

# -- Funcion T: obtiene el texto segun idioma activo --------
function T {
    param([string]$Key, [object[]]$Fmt = @())
    $entry = $script:Strings[$Key]
    if (-not $entry) { return "[$Key]" }
    $text = $entry[$script:LANG]
    if (-not $text) { $text = $entry["ES"] }
    if ($Fmt.Count -gt 0) {
        try { $text = $text -f $Fmt } catch { }
    }
    return $text
}

# ============================================================
#  FUNCIONES PRINCIPALES
# ============================================================

function Write-Color {
    param(
        [string]$Text,
        [ConsoleColor]$FG = [ConsoleColor]::White,
        [switch]$NoNewline
    )
    $prev = [Console]::ForegroundColor
    [Console]::ForegroundColor = $FG
    if ($NoNewline) { Write-Host $Text -NoNewline } else { Write-Host $Text }
    [Console]::ForegroundColor = $prev
}

function Test-Dependencies {
    if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
        Write-Color (T "dep_missing") Red
        Write-Color (T "dep_download") Cyan
        Write-Color "  https://developer.android.com/tools/releases/platform-tools" Cyan
        Write-Color (T "dep_path") Gray
        Read-Host (T "enter_to_exit")
        exit 1
    }
}

function Test-DeviceAlive {
    # Verifica si el dispositivo sigue respondiendo en la red actual
    if ($script:CONNECTED_DEVICE -eq "") { return $false }

    # Extraer IP y puerto del dispositivo conectado
    $parts = $script:CONNECTED_DEVICE -split ":"
    $ip    = $parts[0]
    $port  = if ($parts.Count -gt 1) { [int]$parts[1] } else { $ADB_PORT }

    # Verificar con TCP rapido (timeout 600ms)
    try {
        $tcp   = New-Object System.Net.Sockets.TcpClient
        $async = $tcp.BeginConnect($ip, $port, $null, $null)
        $alive = $async.AsyncWaitHandle.WaitOne(600, $false)
        $tcp.Close()
        if (-not $alive) { return $false }
    } catch { return $false }

    # Doble check: confirmar que adb lo reconoce como "device"
    $state = (adb -s $script:CONNECTED_DEVICE get-state 2>$null)
    return ("$state".Trim() -eq "device")
}

function Show-Banner {
    Clear-Host
    Write-Color "  +----------------------------------------------+" Cyan
    Write-Color (T "banner_line1") Cyan
    Write-Color (T "banner_line2") Cyan
    Write-Color "  +----------------------------------------------+" Cyan
    Write-Host ""

    if ($script:CONNECTED_DEVICE -ne "") {
        # Verificar si el dispositivo sigue vivo en la red actual
        $alive = Test-DeviceAlive
        if ($alive) {
            Write-Color (T "banner_on") Green -NoNewline
            Write-Color $script:CONNECTED_DEVICE White
            $model = (adb -s $script:CONNECTED_DEVICE shell getprop ro.product.model 2>$null)
            if ($model) {
                $model = "$model".Trim()
                Write-Color "$(T 'banner_model')$model" DarkGray
            }
        } else {
            # Dispositivo ya no responde - limpiar sesion automaticamente
            adb disconnect $script:CONNECTED_DEVICE 2>$null | Out-Null
            $script:CONNECTED_DEVICE = ""
            Write-Color (T "net_lost") Yellow
            Write-Color (T "net_lost_detail") DarkGray
        }
    } else {
        Write-Color (T "banner_off") Yellow
    }
    Write-Host ""
}

function Get-LocalSubnet {
    $candidates = @()
    $ipList = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.IPAddress -notmatch "^127\." -and $_.IPAddress -notmatch "^169\.254\." }

    foreach ($entry in $ipList) {
        $adapter = Get-NetAdapter -InterfaceIndex $entry.InterfaceIndex -ErrorAction SilentlyContinue
        $adpName = if ($adapter) { $adapter.Name } else { "Adapter $($entry.InterfaceIndex)" }
        $adpDesc = if ($adapter) { $adapter.InterfaceDescription } else { "" }
        $label   = $adpName
        if ("$adpName $adpDesc".ToLower() -match "vmware|vmnet|vbox|virtualbox|hyper-v|bluetooth|tunnel|loopback|isatap|teredo") {
            $label = "$adpName$(T 'adapters_virtual')"
        }
        $candidates += [PSCustomObject]@{ IP = $entry.IPAddress; Label = $label; Metric = $entry.InterfaceMetric }
    }
    $candidates = @($candidates | Sort-Object Metric)

    if ($candidates.Count -eq 0) { Write-Color (T "adapters_none") Red; return $null }

    Write-Color (T "adapters_title") Yellow
    for ($i = 0; $i -lt $candidates.Count; $i++) {
        Write-Color "  [$($i+1)] " White -NoNewline
        Write-Color "$($candidates[$i].IP)" Green -NoNewline
        Write-Color "   $($candidates[$i].Label)" DarkGray
    }
    Write-Host ""
    $pick = Read-Host (T "adapters_pick" @($candidates.Count))
    $idx  = ([int]$pick) - 1
    if ($idx -lt 0 -or $idx -ge $candidates.Count) {
        Write-Color (T "adapters_fallback") Yellow; $idx = 0
    }
    $ip = $candidates[$idx].IP
    $p  = $ip -split "\."
    return "$($p[0]).$($p[1]).$($p[2]).0/24"
}

function Get-IPFromText {
    param([string]$Text)
    if ($Text -match '(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})') { return $Matches[1] }
    return $null
}

function Invoke-PingSweep {
    param([string]$Base, [int]$Port)
    Write-Color (T "scan_sweep") Yellow
    Write-Color (T "scan_sweep2" @($Base, $Port)) DarkGray

    $found = [System.Collections.Concurrent.ConcurrentBag[string]]::new()
    $pool  = [RunspaceFactory]::CreateRunspacePool(1, 50)
    $pool.Open()
    $jobs  = @()

    1..254 | ForEach-Object {
        $ip  = "$Base.$_"
        $ps  = [PowerShell]::Create()
        $ps.RunspacePool = $pool
        [void]$ps.AddScript({
            param($targetIP, $targetPort, $bag)
            try {
                $tcp   = New-Object System.Net.Sockets.TcpClient
                $async = $tcp.BeginConnect($targetIP, $targetPort, $null, $null)
                $wait  = $async.AsyncWaitHandle.WaitOne(800, $false)
                if ($wait -and $tcp.Connected) { $bag.Add($targetIP) }
                $tcp.Close()
            } catch {}
        }).AddArgument($ip).AddArgument($Port).AddArgument($found)
        $jobs += @{ PS = $ps; Handle = $ps.BeginInvoke() }
    }
    foreach ($job in $jobs) { $job.PS.EndInvoke($job.Handle); $job.PS.Dispose() }
    $pool.Close(); $pool.Dispose()
    return @($found | Sort-Object)
}

function Invoke-NetworkScan {
    Write-Color (T "scan_detecting") Cyan
    $subnet = Get-LocalSubnet
    if (-not $subnet) {
        Write-Color (T "scan_no_subnet") Yellow
        $subnet = Read-Host (T "scan_manual_sub")
        if (-not $subnet) { return }
    }
    Write-Color (T "scan_running" @($subnet, $script:ACTIVE_PORT)) Cyan
    $found = @()

    if (Get-Command nmap -ErrorAction SilentlyContinue) {
        Write-Color (T "scan_nmap") DarkGray
        $nmapOut = nmap -p $script:ACTIVE_PORT --open -T4 $subnet 2>$null
        $currentIP = ""
        foreach ($line in $nmapOut) {
            if ($line -match "Nmap scan report for") {
                $raw = ($line -split " ")[-1]
                $ex  = Get-IPFromText $raw
                if ($ex) { $currentIP = $ex }
            }
            if ($line -match "open" -and $currentIP -ne "") {
                if ($found -notcontains $currentIP) { $found += $currentIP }
            }
        }
    } else {
        $base  = $subnet -replace "\.\d+/\d+$", ""
        $found = Invoke-PingSweep -Base $base -Port $script:ACTIVE_PORT
    }

    if ($found.Count -eq 0) {
        Write-Color (T "scan_none" @($script:ACTIVE_PORT)) Yellow
        Write-Color (T "scan_tip1") DarkGray
        Write-Color (T "scan_tip2") DarkGray
        Read-Host (T "press_enter")
        return
    }

    Write-Color (T "scan_found") Green
    for ($i = 0; $i -lt $found.Count; $i++) {
        Write-Color "  [$($i+1)] " White -NoNewline
        Write-Color "$($found[$i])" Green
    }
    Write-Host ""
    $choice = Read-Host (T "scan_pick" @($found.Count))
    if ($choice -eq "0" -or $choice -eq "") { return }
    $idx = ([int]$choice) - 1
    if ($idx -ge 0 -and $idx -lt $found.Count) { Connect-ADBDevice $found[$idx] $script:ACTIVE_PORT }
    else { Write-Color (T "invalid_option") Red; Start-Sleep 1 }
}

function Invoke-ManualConnect {
    Write-Color (T "conn_manual_title") Cyan
    Write-Color (T "port_current" @($script:ACTIVE_PORT)) DarkGray
    Write-Host ""
    $ip = Read-Host (T "conn_ip")
    if (-not $ip) { return }

    # Mostrar puerto activo como default, permitir cambiarlo
    Write-Color "  " -NoNewline
    $portInput = Read-Host (T "conn_port" @($script:ACTIVE_PORT))
    if ($portInput -eq "") {
        $port = $script:ACTIVE_PORT
    } else {
        $port = [int]$portInput
        # Guardar el nuevo puerto como activo
        $script:ACTIVE_PORT = $port
    }
    Connect-ADBDevice $ip $port
}

function Connect-ADBDevice {
    param([string]$IP, [int]$Port = $script:ACTIVE_PORT)

    while ($true) {
        $target = "${IP}:${Port}"
        Write-Color (T "conn_connecting" @($target)) Cyan
        $output    = adb connect $target 2>&1
        $outputStr = "$output".Trim()

        if ($outputStr -match "connected|already") {
            Write-Color (T "conn_ok" @($outputStr)) Green
            $script:CONNECTED_DEVICE = $target
            $script:ACTIVE_PORT      = $Port   # Guardar puerto exitoso como activo
            Start-Sleep 1
            $state = (adb -s $target get-state 2>$null)
            $state = "$state".Trim()
            if ($state -eq "device") { Write-Color (T "conn_authorized") Green }
            else { Write-Color (T "conn_auth_wait") Yellow }
            Write-Host ""; Read-Host (T "press_enter")
            return
        } else {
            Write-Color (T "conn_err" @($outputStr)) Red
            Write-Color (T "port_conn_failed" @($Port)) Yellow
            Write-Host ""

            # Ofrecer intentar con otro puerto
            $yesStr = T "uninst_yes"
            $retry  = Read-Host (T "port_try_other")
            if ($retry -eq $yesStr -or $retry -eq $yesStr.ToUpper()) {
                $newPortStr = Read-Host (T "port_enter_other")
                $parsed     = 0
                if ([int]::TryParse($newPortStr, [ref]$parsed) -and $parsed -ge 1024 -and $parsed -le 65535) {
                    $Port = $parsed
                    # Continuar el while con el nuevo puerto
                } else {
                    Write-Color (T "port_invalid") Red
                    Write-Host ""; Read-Host (T "press_enter")
                    $script:CONNECTED_DEVICE = ""
                    return
                }
            } else {
                $script:CONNECTED_DEVICE = ""
                Write-Host ""; Read-Host (T "press_enter")
                return
            }
        }
    }
}

function Disconnect-ADBDevice {
    if ($script:CONNECTED_DEVICE -eq "") {
        Write-Color (T "conn_not_conn") Yellow; Start-Sleep 1; return
    }
    adb disconnect $script:CONNECTED_DEVICE 2>&1 | Out-Null
    Write-Color (T "conn_disconnected" @($script:CONNECTED_DEVICE)) Green
    $script:CONNECTED_DEVICE = ""
    Start-Sleep 1
}

function Assert-Connection {
    if ($script:CONNECTED_DEVICE -eq "") {
        Write-Color (T "not_connected") Red; Start-Sleep 2; return $false
    }
    return $true
}

function Start-ADBShell {
    if (-not (Assert-Connection)) { return }
    Write-Color (T "shell_title" @($script:CONNECTED_DEVICE)) Cyan
    Write-Color (T "shell_hint") DarkGray
    while ($true) {
        Write-Color (T "shell_prompt") Green -NoNewline
        $cmd = Read-Host
        if ($cmd -eq "" -or $cmd -eq "exit" -or $cmd -eq "quit") { break }
        Write-Color "  ----------------------------------------" DarkGray
        Invoke-Expression "adb -s $($script:CONNECTED_DEVICE) shell $cmd"
        Write-Color "  ----------------------------------------`n" DarkGray
    }
}

function Start-ADBCommand {
    if (-not (Assert-Connection)) { return }
    Write-Color (T "adbcmd_title" @($script:CONNECTED_DEVICE)) Cyan
    Write-Color (T "adbcmd_hint") DarkGray
    while ($true) {
        Write-Color (T "adbcmd_prompt") Blue -NoNewline
        $cmd = Read-Host
        if ($cmd -eq "" -or $cmd -eq "exit" -or $cmd -eq "quit") { break }
        Write-Color "  ----------------------------------------" DarkGray
        Invoke-Expression "adb -s $($script:CONNECTED_DEVICE) $cmd"
        Write-Color "  ----------------------------------------`n" DarkGray
    }
}

function Install-APK {
    if (-not (Assert-Connection)) { return }
    Write-Color (T "apk_title" @($DOWNLOADS_DIR)) Cyan
    $apks = @(Get-ChildItem -Path $DOWNLOADS_DIR -Recurse -Filter "*.apk" -Depth 3 -ErrorAction SilentlyContinue)
    if ($apks.Count -eq 0) {
        Write-Color (T "apk_none" @($DOWNLOADS_DIR)) Yellow
        $customPath = Read-Host (T "apk_custom")
        if (-not $customPath -or -not (Test-Path $customPath)) {
            Write-Color (T "apk_notfound") Red; Start-Sleep 1; return
        }
        $apks = @(Get-Item $customPath)
    }
    Write-Color (T "apk_found") Green
    for ($i = 0; $i -lt $apks.Count; $i++) {
        $sz = [math]::Round($apks[$i].Length / 1MB, 2)
        Write-Color "  [$($i+1)] " White -NoNewline
        Write-Color "$($apks[$i].Name)" Yellow
        Write-Color "      $($apks[$i].FullName)  ($sz MB)" DarkGray
    }
    $extra = $apks.Count + 1
    Write-Color (T "apk_manual_entry" @($extra)) DarkGray
    Write-Host ""
    $choice = Read-Host (T "apk_pick" @($extra))
    if ($choice -eq "0" -or $choice -eq "") { return }
    $apkPath = ""
    if ([int]$choice -eq $extra) {
        $apkPath = Read-Host (T "apk_manual_path")
        if (-not (Test-Path $apkPath)) { Write-Color (T "apk_notfound") Red; Start-Sleep 1; return }
    } else {
        $idx = ([int]$choice) - 1
        if ($idx -ge 0 -and $idx -lt $apks.Count) { $apkPath = $apks[$idx].FullName }
        else { Write-Color (T "invalid_option") Red; Start-Sleep 1; return }
    }
    Write-Color (T "apk_mode_title") Cyan
    Write-Color (T "apk_mode1"); Write-Color (T "apk_mode2"); Write-Color (T "apk_mode3")
    $mode = Read-Host (T "apk_mode_prompt")
    if (-not $mode) { $mode = "1" }
    Write-Color (T "apk_installing" @((Split-Path $apkPath -Leaf), $script:CONNECTED_DEVICE)) Cyan
    switch ($mode) {
        "2"     { $resLines = @(adb -s $script:CONNECTED_DEVICE install -r "$apkPath" 2>&1) }
        "3"     { $resLines = @(adb -s $script:CONNECTED_DEVICE install -r -d "$apkPath" 2>&1) }
        default { $resLines = @(adb -s $script:CONNECTED_DEVICE install "$apkPath" 2>&1) }
    }
    $resFull = $resLines -join " "
    Write-Host ""
    foreach ($line in $resLines) {
        $lineStr = "$line".Trim()
        if ($lineStr -ne "") {
            if ($lineStr -match "Performing|Streaming") { Write-Color "  >> $lineStr" DarkGray }
            elseif ($lineStr -match "Success")          { Write-Color "  >> $lineStr" Green }
            elseif ($lineStr -match "Failure|Error|FAILED") { Write-Color "  >> $lineStr" Red }
            else { Write-Color "  >> $lineStr" DarkGray }
        }
    }
    Write-Host ""
    $installResult2 = Get-ADBInstallResult $resLines
    switch -Wildcard ($installResult2) {
        "ok"           { Write-Color (T "apk_ok") Green }
        "incompatible" { Write-Color "  ERR App incompatible. Desinstala la version anterior primero." Red }
        "downgrade"    { Write-Color "  ERR Version mas antigua. Usa modo [3] fuentes externas." Red }
        "sources"      { Write-Color (T "apk_sources_tip") Red }
        default {
            $errMsg2 = $installResult2 -replace "^error:",""
            $errMsg2 = if ($errMsg2) { $errMsg2 } else { "Error desconocido" }
            Write-Color "  ERR Error al instalar: $errMsg2" Red
            Write-Color (T "apk_sources_tip") Yellow
        }
    }
    Write-Host ""; Read-Host (T "press_enter")
}

function Show-Packages {
    if (-not (Assert-Connection)) { return }
    Write-Color (T "pkg_title") Cyan
    Write-Color (T "pkg_opt1")
    $opt = Read-Host (T "pkg_prompt")
    if (-not $opt) { $opt = "1" }
    Write-Color "  ----------------------------------------" DarkGray
    switch ($opt) {
        "1" { adb -s $script:CONNECTED_DEVICE shell pm list packages | Sort-Object }
        "2" { adb -s $script:CONNECTED_DEVICE shell pm list packages -3 | Sort-Object }
        "3" {
            $term = Read-Host (T "pkg_search")
            adb -s $script:CONNECTED_DEVICE shell pm list packages | Where-Object { $_ -match $term }
        }
    }
    Write-Color "  ----------------------------------------`n" DarkGray
    Read-Host (T "press_enter")
}

function Remove-APK {
    if (-not (Assert-Connection)) { return }
    Write-Color (T "uninst_title") Cyan
    $pkgs = @(
        adb -s $script:CONNECTED_DEVICE shell pm list packages -3 2>$null |
        Sort-Object |
        ForEach-Object { "$_".Trim() -replace "package:","" }
    )
    if ($pkgs.Count -eq 0) { Write-Color (T "uninst_none") Yellow; Start-Sleep 1; return }
    for ($i = 0; $i -lt $pkgs.Count; $i++) { Write-Color "  [$($i+1)] $($pkgs[$i])" }
    Write-Host ""
    $choice  = Read-Host (T "uninst_pick" @($pkgs.Count))
    $pkgName = ""
    if ($choice -match "^\d+$") {
        $idx = ([int]$choice) - 1
        if ($idx -ge 0 -and $idx -lt $pkgs.Count) { $pkgName = $pkgs[$idx] }
    } else { $pkgName = $choice }
    if (-not $pkgName) { return }
    $confirm = Read-Host (T "uninst_confirm" @($pkgName))
    $yesStr  = T "uninst_yes"
    if ($confirm -ne $yesStr -and $confirm -ne $yesStr.ToUpper()) { return }
    adb -s $script:CONNECTED_DEVICE uninstall $pkgName
    Write-Host ""; Read-Host (T "press_enter")
}

function Show-DeviceInfo {
    if (-not (Assert-Connection)) { return }
    Write-Color (T "info_title" @($script:CONNECTED_DEVICE)) Cyan
    Write-Color "  ----------------------------------------" DarkGray
    @(
        @("ro.product.brand",         (T "info_brand")),
        @("ro.product.model",         (T "info_model")),
        @("ro.product.name",          (T "info_name")),
        @("ro.build.version.release", (T "info_android")),
        @("ro.build.version.sdk",     (T "info_sdk")),
        @("ro.product.cpu.abi",       (T "info_cpu")),
        @("ro.serialno",              (T "info_serial"))
    ) | ForEach-Object {
        $val = (adb -s $script:CONNECTED_DEVICE shell getprop $_[0] 2>$null)
        Write-Host ("  {0,-22} {1}" -f "$($_[1]):", "$val".Trim())
    }
    Write-Color (T "info_storage") Cyan
    $df = adb -s $script:CONNECTED_DEVICE shell df /data 2>$null | Select-Object -Last 1
    Write-Host "  $df"
    Write-Color (T "info_battery") Cyan
    adb -s $script:CONNECTED_DEVICE shell dumpsys battery 2>$null |
        Where-Object { $_ -match "level|status|temperature" } |
        ForEach-Object { Write-Host "  $_" }
    Write-Host ""; Read-Host (T "press_enter")
}

function Take-Screenshot {
    if (-not (Assert-Connection)) { return }
    $ts   = Get-Date -Format "yyyyMMdd_HHmmss"
    $dir  = "$env:USERPROFILE\Pictures"
    $dest = "$dir\screenshot_$ts.png"
    New-Item -ItemType Directory $dir -Force | Out-Null
    Write-Color (T "ss_title") Cyan
    adb -s $script:CONNECTED_DEVICE shell screencap -p /sdcard/tmp_ss.png 2>$null
    adb -s $script:CONNECTED_DEVICE pull /sdcard/tmp_ss.png $dest 2>&1 | Out-Null
    adb -s $script:CONNECTED_DEVICE shell rm /sdcard/tmp_ss.png 2>$null
    if (Test-Path $dest) { Write-Color (T "ss_ok" @($dest)) Green; Start-Process $dest }
    else { Write-Color (T "ss_err") Red }
    Write-Host ""; Read-Host (T "press_enter")
}

function Enable-TCPIP {
    Write-Color (T "usb_title") Cyan
    $usb = adb devices 2>$null |
        Where-Object { $_ -match "device$" -and $_ -notmatch "List" } |
        ForEach-Object { ($_ -split "\s+")[0] } |
        Select-Object -First 1
    if (-not $usb) { Write-Color (T "usb_none") Red }
    else {
        Write-Color (T "usb_found" @($usb)) Green
        $p = Read-Host (T "conn_port" @($ADB_PORT))
        if (-not $p) { $p = $ADB_PORT }
        adb -s $usb tcpip ([int]$p)
        Write-Color (T "usb_ok" @($p)) Green
    }
    Write-Host ""; Read-Host (T "press_enter")
}

function Manage-Bloatware {
    if (-not (Assert-Connection)) { return }
    $presetList = @(
        "com.nes.coreservice","com.nes.otaservice","com.nes.activation",
        "com.smart.ota","com.adups.fota","com.adups.fota.sysoper",
        "com.rockchip.setbox","com.rockchip.gamestation",
        "com.android.browser","com.android.email"
    )
    while ($true) {
        Write-Color (T "blw_title" @($script:CONNECTED_DEVICE)) Cyan
        Write-Color (T "blw_quick") Yellow
        Write-Color (T "blw_q6")
        Write-Color (T "blw_q7")
        Write-Color (T "blw_q8")
        Write-Host ""
        Write-Color (T "blw_manual") Blue
        Write-Color (T "blw_o1"); Write-Color (T "blw_o2"); Write-Color (T "blw_o3")
        Write-Color (T "blw_o4"); Write-Color (T "blw_o5"); Write-Color (T "blw_o0")
        Write-Host ""
        Write-Color (T "menu_prompt") Cyan -NoNewline
        $opt = Read-Host

        switch ($opt) {
            "6" {
                $pkg = "com.nes.coreservice"
                Write-Color (T "nes_title" @($pkg)) Yellow
                Write-Color (T "nes_desc1") DarkGray
                Write-Color (T "nes_desc2") DarkGray
                $chk = adb -s $script:CONNECTED_DEVICE shell pm list packages 2>$null |
                    Where-Object { $_ -match "com\.nes\.coreservice" }
                if (-not $chk) {
                    Write-Color (T "nes_not_found") Cyan
                    Write-Host ""; Read-Host (T "press_enter"); break
                }
                Write-Color (T "nes_found") Green
                Write-Color (T "nes_opt1"); Write-Color (T "nes_opt2"); Write-Color (T "nes_opt0")
                Write-Host ""; Write-Color (T "menu_prompt") Cyan -NoNewline
                $sub = Read-Host; Write-Host ""
                switch ($sub) {
                    "1" {
                        $res = adb -s $script:CONNECTED_DEVICE shell pm disable-user $pkg 2>&1
                        if ("$res" -match "disabled") {
                            Write-Color (T "nes_disabled_ok" @($pkg)) Green
                            Write-Color (T "nes_disabled_tip") DarkGray
                        } else { Write-Color (T "conn_err" @($res)) Red }
                    }
                    "2" {
                        $res = adb -s $script:CONNECTED_DEVICE shell pm uninstall -k --user 0 $pkg 2>&1
                        if ("$res" -match "Success") {
                            Write-Color (T "nes_uninst_ok" @($pkg)) Green
                            Write-Color (T "nes_disabled_tip") DarkGray
                        } else { Write-Color (T "conn_err" @($res)) Red }
                    }
                    "0" { break }
                    default { Write-Color (T "invalid_option") Red }
                }
                Write-Host ""; Read-Host (T "press_enter")
            }
            "7" {
                # Deshabilitar com.nes.coreservice directamente con disable-user
                $pkg = "com.nes.coreservice"
                Write-Color (T "nes_disable_title") Yellow
                Write-Color (T "nes_disable_cmd") DarkGray
                Write-Host ""

                $chk = adb -s $script:CONNECTED_DEVICE shell pm list packages 2>$null |
                    Where-Object { $_ -match "com\.nes\.coreservice" }

                if (-not $chk) {
                    Write-Color (T "nes_disable_na") Cyan
                } else {
                    $res = adb -s $script:CONNECTED_DEVICE shell pm disable-user $pkg 2>&1
                    Write-Host ""
                    if ("$res" -match "disabled") {
                        Write-Color (T "nes_disable_ok") Green
                        Write-Color "  Comando ejecutado: pm disable-user $pkg" DarkGray
                    } else {
                        Write-Color (T "nes_disable_err" @($res)) Red
                    }
                }
                Write-Host ""; Read-Host (T "press_enter")
            }
            "8" {
                # Mostrar estado actual de com.nes.coreservice
                $pkg = "com.nes.coreservice"
                Write-Color (T "nes_status_title") Yellow
                Write-Color (T "nes_status_cmd") DarkGray
                Write-Host ""

                # Verificar si existe en la lista de paquetes (con o sin -d)
                $allPkgs  = adb -s $script:CONNECTED_DEVICE shell pm list packages -a 2>$null
                $disPkgs  = adb -s $script:CONNECTED_DEVICE shell pm list packages -d 2>$null
                $enaPkgs  = adb -s $script:CONNECTED_DEVICE shell pm list packages -e 2>$null

                $inAll  = $allPkgs  | Where-Object { $_ -match "com\.nes\.coreservice" }
                $inDis  = $disPkgs  | Where-Object { $_ -match "com\.nes\.coreservice" }
                $inEna  = $enaPkgs  | Where-Object { $_ -match "com\.nes\.coreservice" }

                # Obtener estado detallado via dumpsys
                $dump = adb -s $script:CONNECTED_DEVICE shell dumpsys package com.nes.coreservice 2>$null
                $stateRaw = $dump | Where-Object { $_ -match "enabledState|pkgFlags" } | Select-Object -First 2

                Write-Color "  ----------------------------------------" DarkGray
                Write-Color "  Paquete: com.nes.coreservice" White

                if (-not $inAll) {
                    Write-Color (T "nes_status_none") Yellow
                } elseif ($inDis) {
                    Write-Color (T "nes_status_dis") Green
                } elseif ($inEna) {
                    Write-Color (T "nes_status_ena") Red
                } else {
                    # Puede estar desinstalado para usuario 0 pero presente en firmware
                    $user0 = $dump | Where-Object { $_ -match "User 0:" } | Select-Object -First 1
                    if ("$user0" -match "stopped=true|not installed") {
                        Write-Color (T "nes_status_uninst") Green
                    } else {
                        Write-Color (T "nes_status_ena") Red
                    }
                }

                # Mostrar detalle raw si hay datos
                if ($stateRaw) {
                    Write-Host ""
                    Write-Color "  Detalle:" DarkGray
                    $stateRaw | ForEach-Object { Write-Color "  $($_.Trim())" DarkGray }
                }

                Write-Color "  ----------------------------------------" DarkGray
                Write-Host ""; Read-Host (T "press_enter")
            }
            "1" {
                Write-Color (T "blw_disable_title") Yellow
                Write-Color (T "blw_disable_hint") DarkGray
                $pkg = Read-Host (T "blw_pkg_prompt")
                if (-not $pkg) { break }
                $res = adb -s $script:CONNECTED_DEVICE shell pm disable-user $pkg 2>&1
                Write-Host ""
                if ("$res" -match "disabled") { Write-Color (T "blw_disabled_ok" @($res)) Green }
                else { Write-Color (T "conn_err" @($res)) Red }
                Write-Host ""; Read-Host (T "press_enter")
            }
            "2" {
                Write-Color (T "blw_uninst_title") Yellow
                Write-Color (T "blw_uninst_hint") DarkGray
                $pkg = Read-Host (T "blw_pkg_prompt")
                if (-not $pkg) { break }
                $confirm = Read-Host (T "blw_uninst_confirm" @($pkg))
                $yesStr  = T "uninst_yes"
                if ($confirm -ne $yesStr -and $confirm -ne $yesStr.ToUpper()) { break }
                $res = adb -s $script:CONNECTED_DEVICE shell pm uninstall -k --user 0 $pkg 2>&1
                Write-Host ""
                if ("$res" -match "Success") { Write-Color (T "blw_uninst_ok") Green }
                else { Write-Color (T "conn_err" @($res)) Red }
                Write-Host ""; Read-Host (T "press_enter")
            }
            "3" {
                Write-Color (T "blw_restore_title") Yellow
                $pkg = Read-Host (T "blw_restore_pkg")
                if (-not $pkg) { break }
                $res = adb -s $script:CONNECTED_DEVICE shell pm install-existing $pkg 2>&1
                Write-Host ""
                if ("$res" -match "Success|installed") { Write-Color (T "blw_restore_ok") Green }
                else { Write-Color (T "conn_err" @($res)) Red }
                Write-Host ""; Read-Host (T "press_enter")
            }
            "4" {
                Write-Color (T "blw_preset_title") Yellow
                foreach ($p in $presetList) { Write-Color "  $p" DarkGray }
                Write-Host ""
                Write-Color (T "blw_preset_mode") Cyan
                Write-Color (T "blw_preset_m1"); Write-Color (T "blw_preset_m2")
                $mode    = Read-Host (T "blw_preset_mode_p")
                $confirm = Read-Host (T "blw_preset_confirm" @($presetList.Count))
                $yesStr  = T "uninst_yes"
                if ($confirm -ne $yesStr -and $confirm -ne $yesStr.ToUpper()) { break }
                Write-Host ""
                foreach ($p in $presetList) {
                    Write-Color "  >> $p" DarkGray -NoNewline
                    if ($mode -eq "2") { $res = adb -s $script:CONNECTED_DEVICE shell pm uninstall -k --user 0 $p 2>&1 }
                    else               { $res = adb -s $script:CONNECTED_DEVICE shell pm disable-user $p 2>&1 }
                    if ("$res" -match "Success|disabled") { Write-Color "   OK" Green }
                    else { Write-Color (T "blw_preset_skip") DarkGray }
                }
                Write-Host ""; Read-Host (T "blw_preset_done")
            }
            "5" {
                Write-Color (T "blw_disabled_list") Yellow
                Write-Color "  ----------------------------------------" DarkGray
                adb -s $script:CONNECTED_DEVICE shell pm list packages -d | Sort-Object |
                    ForEach-Object { Write-Host "  $_" }
                Write-Color "  ----------------------------------------`n" DarkGray
                Read-Host (T "press_enter")
            }
            "0" { return }
            default { Write-Color (T "invalid_option") Red; Start-Sleep -Milliseconds 700 }
        }
    }
}

function Set-PrivateDNS {
    param([string]$DnsHost)
    Write-Host ""
    adb -s $script:CONNECTED_DEVICE shell settings put global private_dns_mode hostname 2>$null
    adb -s $script:CONNECTED_DEVICE shell settings put global private_dns_specifier $DnsHost 2>$null
    $verify = (adb -s $script:CONNECTED_DEVICE shell settings get global private_dns_specifier 2>$null)
    $verify = "$verify".Trim()
    if ($verify -eq $DnsHost) {
        Write-Color (T "ads_dns_ok" @($DnsHost)) Green
        Write-Color (T "ads_dns_tip") DarkGray
    } else { Write-Color (T "ads_dns_err") Red }
    Write-Host ""; Read-Host (T "press_enter")
}

function Manage-AdBlock {
    if (-not (Assert-Connection)) { return }
    while ($true) {
        $curMode = (adb -s $script:CONNECTED_DEVICE shell settings get global private_dns_mode 2>$null)
        $curDns  = (adb -s $script:CONNECTED_DEVICE shell settings get global private_dns_specifier 2>$null)
        $curMode = "$curMode".Trim(); $curDns = "$curDns".Trim()

        Write-Color (T "ads_title" @($script:CONNECTED_DEVICE)) Cyan
        Write-Color (T "ads_status_on") White -NoNewline
        if ($curMode -eq "hostname" -and $curDns -ne "" -and $curDns -ne "null") {
            Write-Color (T "ads_active" @($curDns)) Green
        } else { Write-Color (T "ads_inactive") Yellow }

        Write-Host ""
        Write-Color (T "menu_opt") Blue
        Write-Color (T "ads_o1"); Write-Color (T "ads_o2"); Write-Color (T "ads_o3")
        Write-Color (T "ads_o4"); Write-Color (T "ads_o5"); Write-Color (T "ads_o6")
        Write-Color (T "ads_o7"); Write-Color (T "ads_o0")
        Write-Host ""; Write-Color (T "menu_prompt") Cyan -NoNewline
        $opt = Read-Host

        switch ($opt) {
            "1" { Set-PrivateDNS "dns.adguard.com" }
            "2" {
                Write-Color (T "ads_nextdns_hint") Yellow
                $id = Read-Host (T "ads_nextdns_id")
                if ($id) { Set-PrivateDNS "$id.dns.nextdns.io" }
            }
            "3" { Set-PrivateDNS "adblock.dns.mullvad.net" }
            "4" { Set-PrivateDNS "freedns.controld.com" }
            "5" {
                Write-Color (T "ads_custom_title") Yellow
                $dns = Read-Host (T "ads_custom_prompt")
                if ($dns) { Set-PrivateDNS $dns }
            }
            "6" {
                adb -s $script:CONNECTED_DEVICE shell settings put global private_dns_mode opportunistic 2>$null
                adb -s $script:CONNECTED_DEVICE shell settings delete global private_dns_specifier 2>$null
                Write-Color (T "ads_disabled_ok") Green
                Write-Host ""; Read-Host (T "press_enter")
            }
            "7" {
                Write-Color (T "ads_adaway_title") Cyan
                Write-Color (T "ads_adaway_hint1") DarkGray
                Write-Color (T "ads_adaway_hint2") DarkGray
                $apkPath = ""
                $adaway  = @(Get-ChildItem -Path $DOWNLOADS_DIR -Filter "*adaway*" -Recurse -Depth 3 -ErrorAction SilentlyContinue)
                if ($adaway.Count -gt 0) {
                    Write-Color (T "ads_adaway_found" @($adaway[0].Name)) Green
                    $yesStr  = T "uninst_yes"
                    $confirm = Read-Host (T "ads_adaway_inst")
                    if ($confirm -eq $yesStr -or $confirm -eq $yesStr.ToUpper()) { $apkPath = $adaway[0].FullName }
                } else {
                    Write-Color (T "ads_adaway_none" @($DOWNLOADS_DIR)) Yellow
                    $apkPath = Read-Host (T "ads_adaway_path")
                }
                if ($apkPath -and (Test-Path $apkPath)) {
                    $res = adb -s $script:CONNECTED_DEVICE install -r "$apkPath" 2>&1
                    Write-Host ""
                    if ("$res" -match "Success") { Write-Color (T "ads_adaway_ok") Green }
                    else { Write-Color (T "conn_err" @($res)) Red }
                    Write-Host ""; Read-Host (T "press_enter")
                }
            }
            "0" { return }
            default { Write-Color (T "invalid_option") Red; Start-Sleep -Milliseconds 700 }
        }
    }
}

function Select-Port {
    Write-Color (T "port_change_title") Cyan
    Write-Color (T "port_hint") DarkGray
    Write-Host ""
    Write-Color (T "port_current" @($script:ACTIVE_PORT)) White
    Write-Host ""
    $input = Read-Host (T "port_prompt" @($script:ACTIVE_PORT))
    if ($input -eq "") { return }
    $parsed = 0
    if ([int]::TryParse($input, [ref]$parsed) -and $parsed -ge 1024 -and $parsed -le 65535) {
        $script:ACTIVE_PORT = $parsed
        Write-Color (T "port_set" @($parsed)) Green
    } else {
        Write-Color (T "port_invalid") Red
    }
    Write-Host ""; Start-Sleep 1
}

function Select-Language {
    Write-Color (T "lang_title") Cyan
    if ($script:LANG -eq "ES") { Write-Color (T "lang_current_es") White }
    else { Write-Color (T "lang_current_en") White }
    Write-Host ""
    Write-Color (T "lang_opt1"); Write-Color (T "lang_opt2"); Write-Color (T "lang_opt0")
    Write-Host ""
    Write-Color (T "lang_prompt") Cyan -NoNewline
    $opt = Read-Host
    switch ($opt) {
        "1" { $script:LANG = "ES"; Write-Color (T "lang_set_es") Green; Start-Sleep 1 }
        "2" { $script:LANG = "EN"; Write-Color (T "lang_set_en") Green; Start-Sleep 1 }
        "0" { return }
        default { Write-Color (T "invalid_option") Red; Start-Sleep -Milliseconds 700 }
    }
}

# -- Menu principal ------------------------------------------
function Get-ADBInstallResult {
    param([string[]]$Lines)
    $full = ($Lines -join " ").Trim()

    # Exito explicito
    if ($full -match "Success") { return "ok" }

    # Error explicito
    if ($full -match "INSTALL_FAILED_UPDATE_INCOMPATIBLE") { return "incompatible" }
    if ($full -match "INSTALL_FAILED_VERSION_DOWNGRADE")   { return "downgrade" }
    if ($full -match "INSTALL_FAILED_USER_RESTRICTED|INSTALL_FAILED_UNKNOWN_SOURCES") { return "sources" }
    if ($full -match "INSTALL_FAILED_ALREADY_EXISTS")      { return "ok" }  # ya instalado = ok
    if ($full -match "INSTALL_FAILED|Failure|Exception")   { return "error:$full" }

    # Si solo hay lineas informativas sin error explicito = exito silencioso
    $realLines = $Lines | Where-Object {
        $l = "$_".Trim()
        $l -ne "" -and $l -notmatch "^Performing|^Streaming|^\[|^adb"
    }
    if (-not $realLines) { return "ok" }

    # Cualquier otra cosa, devolver el texto como error
    return "error:$full"
}

function Install-SmartTubeNext {
    if (-not (Assert-Connection)) { return }

    $pkg     = "com.liskovsoft.videomanager"
    $dlDir   = $DOWNLOADS_DIR
    $yesStr  = T "uninst_yes"

    while ($true) {
        Write-Color (T "stn_title") Cyan
        Write-Color (T "stn_desc1") DarkGray
        Write-Color (T "stn_desc2") DarkGray

        # Verificar si ya esta instalado
        $installed = adb -s $script:CONNECTED_DEVICE shell pm list packages 2>$null |
            Where-Object { $_ -match [regex]::Escape($pkg) }

        if ($installed) {
            Write-Color (T "stn_already") Cyan
            Write-Host ""
        }

        Write-Color (T "stn_opt1")
        Write-Color (T "stn_opt2")
        Write-Color (T "stn_opt0")
        Write-Host ""
        Write-Color (T "menu_prompt") Cyan -NoNewline
        $opt = Read-Host

        switch ($opt) {
            "1" {
                # -- Detectar arquitectura del dispositivo
                $cpuAbi = (adb -s $script:CONNECTED_DEVICE shell getprop ro.product.cpu.abi 2>$null)
                $cpuAbi = "$cpuAbi".Trim()
                Write-Color "  CPU detectada: $cpuAbi" DarkGray

                # Determinar que APK descargar segun arquitectura
                # armeabi-v7a = 32-bit ARM  -> smarttube_stable_armeabi_v7a.apk
                # arm64-v8a   = 64-bit ARM  -> smarttube_stable.apk (universal/arm64)
                # x86_64      = emulador    -> smarttube_stable.apk
                $is32bit = $cpuAbi -match "armeabi-v7a|armeabi"

                # -- Consultar ultima version en GitHub API
                Write-Color (T "stn_checking") DarkGray
                try {
                    $apiUrl  = "https://api.github.com/repos/yuliskov/SmartTube/releases/latest"
                    $headers = @{ "User-Agent" = "ADB-WiFi-Manager"; "Accept" = "application/vnd.github.v3+json" }
                    $release = Invoke-RestMethod -Uri $apiUrl -Headers $headers -TimeoutSec 15 -ErrorAction Stop

                    # Obtener todos los APKs disponibles
                    $allApks = $release.assets | Where-Object { $_.name -match "\.apk$" }

                    if ($is32bit) {
                        # Para armeabi-v7a: buscar APK especifico de 32-bit
                        $asset = $allApks | Where-Object {
                            $_.name -match "armeabi_v7a|arm_v7|armv7|arm-v7"
                        } | Select-Object -First 1

                        # Fallback: APK que diga "arm" sin "arm64"
                        if (-not $asset) {
                            $asset = $allApks | Where-Object {
                                $_.name -match "arm" -and $_.name -notmatch "arm64|aarch64"
                            } | Select-Object -First 1
                        }

                        # Ultimo fallback: universal
                        if (-not $asset) {
                            $asset = $allApks | Where-Object {
                                $_.name -notmatch "beta|x86|arm64|aarch64"
                            } | Select-Object -First 1
                        }

                        if ($asset) {
                            Write-Color "  APK seleccionado: $($asset.name) (32-bit compatible)" Green
                        }
                    } else {
                        # Para arm64 / x86_64: APK universal o arm64
                        $asset = $allApks | Where-Object {
                            $_.name -notmatch "beta|armeabi_v7a|arm_v7|armv7|arm-v7|x86$"
                        } | Select-Object -First 1
                    }

                    # Fallback final: primer APK disponible
                    if (-not $asset) {
                        $asset = $allApks | Select-Object -First 1
                    }

                    if (-not $asset) {
                        Write-Color (T "stn_api_err") Red
                        Write-Host ""; Read-Host (T "press_enter"); break
                    }

                    $version = $release.tag_name
                    $dlUrl   = $asset.browser_download_url
                    $sizeMB  = [math]::Round($asset.size / 1MB, 1)
                    $fname   = $asset.name
                    $dlPath  = Join-Path $dlDir $fname

                    Write-Color (T "stn_found"  @($version)) Green
                    Write-Color "  APK: $fname" DarkGray
                    Write-Color (T "stn_size"   @($sizeMB)) DarkGray
                    Write-Host ""

                    # Si ya existe el archivo descargado, ofrecer reusar
                    $skipDl = $false
                    if (Test-Path $dlPath) {
                        Write-Color "  Archivo ya descargado: $fname" Cyan
                        $reuse = Read-Host "  Usar archivo existente? [s/N]"
                        if ($reuse -eq $yesStr -or $reuse -eq $yesStr.ToUpper()) {
                            $skipDl = $true
                        }
                    }

                    $confirm = Read-Host (T "stn_confirm")
                    if ($confirm -ne $yesStr -and $confirm -ne $yesStr.ToUpper()) { break }

                    if (-not $skipDl) {
                        # -- Descargar con barra de progreso
                        Write-Color (T "stn_downloading" @($fname)) Cyan
                        try {
                            $wc = New-Object System.Net.WebClient
                            $wc.Headers.Add("User-Agent", "ADB-WiFi-Manager")

                            # Progreso de descarga
                            $lastPct = -1
                            Register-ObjectEvent $wc DownloadProgressChanged -Action {
                                $pct = $Event.SourceEventArgs.ProgressPercentage
                                if ($pct -ne $script:lastDlPct) {
                                    $script:lastDlPct = $pct
                                    Write-Host -NoNewline "`r  Progreso: $pct%   "
                                }
                            } | Out-Null

                            $wc.DownloadFile($dlUrl, $dlPath)
                            Write-Host ""
                            $wc.Dispose()
                        } catch {
                            Write-Host ""
                            Write-Color (T "stn_dl_err") Red
                            Write-Host ""; Read-Host (T "press_enter"); break
                        }

                        if (-not (Test-Path $dlPath)) {
                            Write-Color (T "stn_dl_err") Red
                            Write-Host ""; Read-Host (T "press_enter"); break
                        }
                        Write-Color (T "stn_dl_ok" @($dlPath)) Green
                    }

                    # -- Instalar via ADB
                    # Capturar todas las lineas del output (incluyendo "Performing Streamed Install")
                    Write-Color (T "stn_installing") Cyan
                    $resLines = @(adb -s $script:CONNECTED_DEVICE install -r "$dlPath" 2>&1)
                    $resFull  = $resLines -join " "

                    # Mostrar cada linea del output de adb en pantalla
                    foreach ($line in $resLines) {
                        $lineStr = "$line".Trim()
                        if ($lineStr -ne "") {
                            if ($lineStr -match "Performing|Streaming") {
                                Write-Color "  >> $lineStr" DarkGray
                            } elseif ($lineStr -match "Success") {
                                Write-Color "  >> $lineStr" Green
                            } elseif ($lineStr -match "Failure|Error|FAILED") {
                                Write-Color "  >> $lineStr" Red
                            } else {
                                Write-Color "  >> $lineStr" DarkGray
                            }
                        }
                    }
                    Write-Host ""

                    $installResult = Get-ADBInstallResult $resLines
                    switch -Wildcard ($installResult) {
                        "ok" {
                            # Verificar que el paquete realmente quedo instalado
                            Write-Color "  Verificando instalacion en el dispositivo..." DarkGray
                            Start-Sleep 2
                            $pkgCheck = adb -s $script:CONNECTED_DEVICE shell pm list packages 2>$null |
                                Where-Object { $_ -match "com\.liskovsoft\.videomanager" }

                            # Verificar con reintentos - pm list puede tardar en actualizarse
                        $pkgFound  = $false
                        $pkgNames  = @("com.liskovsoft.videomanager","com.liskovsoft.smarttube","com.liskovsoft")
                        $maxTries  = 4

                        for ($t = 1; $t -le $maxTries; $t++) {
                            $allPkgs = adb -s $script:CONNECTED_DEVICE shell pm list packages -a 2>$null
                            foreach ($pn in $pkgNames) {
                                if ($allPkgs | Where-Object { $_ -match [regex]::Escape($pn) }) {
                                    $pkgFound = $true; break
                                }
                            }
                            if ($pkgFound) { break }
                            if ($t -lt $maxTries) {
                                Write-Color "  Reintento $t/$maxTries..." DarkGray
                                Start-Sleep 2
                            }
                        }

                        if ($pkgFound) {
                                Write-Color (T "stn_inst_ok") Green
                                Write-Color (T "stn_inst_tip") DarkGray
                            } else {
                                # Ultimo intento: buscar cualquier paquete liskovsoft
                                $lsk = adb -s $script:CONNECTED_DEVICE shell pm list packages -a 2>$null |
                                    Where-Object { $_ -match "liskovsoft" }
                                if ($lsk) {
                                    Write-Color "  OK  Instalado como: $lsk" Green
                                    Write-Color (T "stn_inst_tip") DarkGray
                                } else {
                                    Write-Color "  WARN No se pudo confirmar. Revisa el menu de apps del TV Box." Yellow
                                    Write-Color "  Si aparece SmartTube en las apps, la instalacion fue exitosa." DarkGray
                                }
                            }
                        }
                        "incompatible" { Write-Color "  ERR App incompatible. Usa opcion [2] para desinstalar primero." Red }
                        "downgrade"    { Write-Color "  ERR Version mas antigua. Usa opcion [2] para desinstalar primero." Red }
                        "sources"      { Write-Color "  ERR Activa 'Origenes desconocidos' en Configuracion > Seguridad." Red }
                        default {
                            $errMsg = $installResult -replace "^error:",""
                            $errMsg = if ($errMsg) { $errMsg } else { "Error desconocido" }
                            Write-Color "  ERR Error al instalar: $errMsg" Red
                        }
                    }

                } catch {
                    Write-Color (T "stn_api_err") Red
                    Write-Color "  $_" DarkGray
                }
                Write-Host ""; Read-Host (T "press_enter")
            }
            "2" {
                $confirm = Read-Host "  Desinstalar SmartTubeNext? [s/N]"
                if ($confirm -eq $yesStr -or $confirm -eq $yesStr.ToUpper()) {
                    $res = adb -s $script:CONNECTED_DEVICE uninstall $pkg 2>&1
                    Write-Host ""
                    if ("$res" -match "Success") { Write-Color (T "stn_uninst_ok") Green }
                    else { Write-Color (T "stn_uninst_err" @($res)) Red }
                    Write-Host ""; Read-Host (T "press_enter")
                }
            }
            "0" { return }
            default { Write-Color (T "invalid_option") Red; Start-Sleep -Milliseconds 700 }
        }
    }
}

function Show-MainMenu {
    while ($true) {
        Show-Banner
        Write-Color (T "menu_conn") Blue
        Write-Color (T "menu_m1"); Write-Color (T "menu_m2")
        Write-Color (T "menu_m3"); Write-Color (T "menu_m4")
        Write-Host ""
        Write-Color (T "menu_cmd") Blue
        Write-Color (T "menu_m5"); Write-Color (T "menu_m6")
        Write-Host ""
        Write-Color (T "menu_apk") Blue
        Write-Color (T "menu_m7"); Write-Color (T "menu_m8"); Write-Color (T "menu_m9")
        Write-Host ""
        Write-Color (T "menu_opt") Blue
        Write-Color (T "menu_m10"); Write-Color (T "menu_m11")
        Write-Color (T "stn_menu")
        Write-Host ""
        Write-Color (T "menu_util") Blue
        Write-Color (T "menu_m12"); Write-Color (T "menu_m13"); Write-Color (T "menu_m14")
        Write-Color (T "port_menu" @($script:ACTIVE_PORT))
        Write-Host ""
        Write-Color (T "menu_m0") Red
        Write-Host ""
        Write-Color (T "menu_prompt") Cyan -NoNewline
        $opt = Read-Host

        switch ($opt) {
            "1"  { Invoke-NetworkScan }
            "2"  { Invoke-ManualConnect }
            "3"  { Enable-TCPIP }
            "4"  { Disconnect-ADBDevice }
            "5"  { Start-ADBShell }
            "6"  { Start-ADBCommand }
            "7"  { Install-APK }
            "8"  { Show-Packages }
            "9"  { Remove-APK }
            "10" { Manage-Bloatware }
            "11" { Manage-AdBlock }
            "12" { Show-DeviceInfo }
            "13" { Take-Screenshot }
            "14" { Select-Language }
            "15" { Select-Port }
            "16" { Install-SmartTubeNext }
            "0"  {
                Write-Color (T "menu_bye") DarkGray
                if ($script:CONNECTED_DEVICE -ne "") {
                    adb disconnect $script:CONNECTED_DEVICE 2>$null | Out-Null
                }
                exit 0
            }
            default { Write-Color (T "invalid_option") Red; Start-Sleep -Milliseconds 700 }
        }
    }
}

# -- Entry point ---------------------------------------------
Test-Dependencies
Show-MainMenu
