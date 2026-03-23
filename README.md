# 📺 ADB WiFi Manager — TV Box Tool v4

Herramienta de línea de comandos para conectar, controlar, limpiar e instalar aplicaciones en TV Boxes y dispositivos Android vía ADB sobre WiFi. **Sin root. Sin cables después del primer uso.**

> **Autor:** Tony Reel  
> **Archivo:** `adb-wifi-manager.ps1`  
> **Idiomas:** Español / English  
> **Requisito único:** `adb` en el PATH del sistema

---

## 📋 Tabla de contenidos

1. [Requisitos e instalación](#1-requisitos-e-instalación)
2. [Primer uso — Habilitar ADB en el dispositivo](#2-primer-uso--habilitar-adb-en-el-dispositivo)
3. [Cómo ejecutar el script](#3-cómo-ejecutar-el-script)
4. [Pantalla principal](#4-pantalla-principal)
5. [CONEXIÓN — Opciones 1 a 4](#5-conexión--opciones-1-a-4)
6. [COMANDOS — Opciones 5 y 6](#6-comandos--opciones-5-y-6)
7. [APKs — Opciones 7 a 9](#7-apks--opciones-7-a-9)
8. [OPTIMIZACIÓN — Opciones 10, 11 y 16](#8-optimización--opciones-10-11-y-16)
9. [UTILIDADES — Opciones 12 a 15](#9-utilidades--opciones-12-a-15)
10. [Solución de problemas](#10-solución-de-problemas)

---

## 1. Requisitos e instalación

### Descargar Android Platform Tools

```
https://dl.google.com/android/repository/platform-tools-latest-windows.zip
```

Extrae el ZIP en una ruta fija sin espacios, por ejemplo `C:\platform-tools\`. Dentro debe quedar `adb.exe` en `C:\platform-tools\adb.exe`.

### Agregar al PATH (PowerShell como Administrador)

```powershell
[System.Environment]::SetEnvironmentVariable(
    "Path",
    $env:Path + ";C:\platform-tools",
    [System.EnvironmentVariableTarget]::Machine
)
```

Cierra y vuelve a abrir PowerShell.

### Verificar instalación

```powershell
adb version
# Android Debug Bridge version 1.0.41
```

### nmap (opcional)

Si está instalado, el scan de red tarda ~5 segundos. Sin nmap usa ping sweep paralelo (~15 segundos). Descarga desde `https://nmap.org/download`.

---

## 2. Primer uso — Habilitar ADB en el dispositivo

### Android 11 o mayor — Depuración inalámbrica

1. Ir a **Configuración → Acerca del dispositivo** y tocar **Número de compilación** 7 veces para activar las opciones de desarrollador

2. Ir a **Configuración → Opciones de desarrollador** y activar **Depuración inalámbrica**

3. La pantalla mostrará la IP y puerto:
   ```
   Depuración inalámbrica
   192.168.68.106:XXXXX
   ```

4. Tocar **"Emparejar dispositivo con código"** — aparece un puerto de emparejamiento y un código de 6 dígitos

5. En PowerShell ejecutar:
   ```powershell
   adb pair 192.168.68.106:PUERTO_EMPAREJAMIENTO
   # Ingresar el código de 6 dígitos cuando lo pida
   ```

6. Conectar con el puerto principal:
   ```powershell
   adb connect 192.168.68.106:PUERTO_PRINCIPAL
   ```

> ⚠️ En Android 11+ el puerto cambia con cada reinicio. Usa la opción **[15]** del script para actualizarlo. Para evitarlo, asigna IP fija al dispositivo desde el router (reserva DHCP por MAC).

---

### Android 10 o menor

**Opción A — Directo por WiFi**

1. **Configuración → Opciones de desarrollador → Depuración USB → Activar**
2. Anotar la IP del dispositivo en **Configuración → Red → WiFi**
3. Usar la opción **[2] Conectar por IP manual** con puerto `5555`

**Opción B — Activar desde USB (primera vez)**

1. Conectar el dispositivo al PC con cable USB
2. Activar **Depuración USB** en Opciones de desarrollador
3. Usar la opción **[3] Habilitar ADB WiFi desde USB** del script
4. Desconectar el cable

---

### TiVo Stream 4K y Google TV

Este tipo de dispositivos tiene restricciones adicionales. Antes de instalar APKs externos:

1. **Configuración → Privacidad → Seguridad y restricciones**
2. Activar **Fuentes desconocidas**
3. O ir a **Configuración → Apps → Acceso especial → Instalar apps desconocidas** y habilitar para ADB

---

## 3. Cómo ejecutar el script

### Método 1 — Sin cambiar configuración del sistema

```powershell
powershell -ExecutionPolicy Bypass -File "C:\ruta\adb-wifi-manager.ps1"
```

### Método 2 — Permitir scripts para el usuario (una sola vez)

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
.\adb-wifi-manager.ps1
```

### Método 3 — Acceso directo con doble clic

Crea un archivo `ADB Manager.bat` en la misma carpeta del script:

```bat
@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0adb-wifi-manager.ps1"
pause
```

---

## 4. Pantalla principal

Al iniciar se muestra el banner con el estado de conexión actual:

```
  +----------------------------------------------+
  |        ADB WiFi Manager - TV Box Tool        |
  |              by Tony Reel  v4            |
  +----------------------------------------------+

  [ON]  Conectado: 192.168.68.106:5555
        Modelo: TiVo Stream 4K

  -- CONEXION ----------------------------------
  [1]  Escanear red y conectar
  [2]  Conectar por IP manual
  [3]  Habilitar ADB WiFi desde USB
  [4]  Desconectar dispositivo

  -- COMANDOS ----------------------------------
  [5]  Shell interactivo (adb shell)
  [6]  Comando ADB directo

  -- APKs --------------------------------------
  [7]  Instalar APK desde Descargas
  [8]  Ver apps instaladas
  [9]  Desinstalar app

  -- OPTIMIZACION ------------------------------
  [10] Gestionar bloatware
  [11] Bloqueo de publicidad
  [16] YouTube sin publicidad (SmartTubeNext)

  -- UTILIDADES --------------------------------
  [12] Info del dispositivo
  [13] Captura de pantalla
  [14] Idioma / Language
  [15] Cambiar puerto ADB [5555]

  [0]  Salir

  Opcion:
```

### Detección automática de conexión perdida

Cada vez que vuelves al menú el script verifica si el dispositivo sigue respondiendo. Si cambias de red, el dispositivo se apaga o el puerto cambia, limpia la sesión automáticamente:

```
  [OFF] Conexion perdida (cambio de red detectado)
        Reconecta el dispositivo con opcion [1] o [2]
```

---

## 5. CONEXIÓN — Opciones 1 a 4

### `[1]` Escanear red y conectar

Muestra todos los adaptadores de red disponibles. Los adaptadores virtuales (VMware, VirtualBox, Hyper-V) aparecen marcados como `[VIRTUAL - omitir]`.

```
  Adaptadores de red disponibles:

  [1] 192.168.68.109   Wi-Fi
  [2] 192.168.78.1     VMware Network Adapter VMnet8 [VIRTUAL - omitir]

  Selecciona tu adaptador WiFi o Ethernet real [1-2]: 1

  [SCAN] Escaneando 192.168.68.0/24 - puerto 5555...

  Dispositivos encontrados con ADB activo:

  [1] 192.168.68.106

  Selecciona [1-1] o 0 para cancelar: 1

  [ADB] Conectando a 192.168.68.106:5555...
  OK  connected to 192.168.68.106:5555
  OK  Dispositivo autorizado y listo.
```

---

### `[2]` Conectar por IP manual

Muestra el puerto activo como valor por defecto. Presiona Enter para usarlo o escribe otro.

```
  [CONECTAR MANUAL]
  Puerto activo: 5555

  IP del dispositivo: 192.168.68.106
  Puerto [5555]:              ← Enter usa 5555
```

Si la conexión **falla**, ofrece probar con otro puerto sin salir del menú:

```
  ERR failed to connect to 192.168.68.106:5555
  No se pudo conectar en puerto 5555.

  Deseas intentar con otro puerto? [s/N]: s
  Ingresa el puerto a probar: 37621

  [ADB] Conectando a 192.168.68.106:37621...
  OK  connected to 192.168.68.106:37621
```

Si la conexión es exitosa con el nuevo puerto, lo guarda automáticamente para el resto de la sesión.

---

### `[3]` Habilitar ADB WiFi desde USB

Detecta el dispositivo USB y ejecuta `adb tcpip 5555`. Necesario la primera vez en Android 10 o menor.

```
  Dispositivo USB detectado: ABC123DEF456
  Puerto TCP/IP [5555]:
  OK  ADB escuchando en puerto 5555. Desconecta el USB y usa Scan.
```

### `[4]` Desconectar

Ejecuta `adb disconnect` y limpia la sesión activa.

---

## 6. COMANDOS — Opciones 5 y 6

### `[5]` Shell interactivo

Escribe comandos **sin prefijo**. Escribe `exit` para volver al menú.

```
  shell > pm list packages -3
  shell > am start -n com.android.settings/.Settings
  shell > input keyevent 26
  shell > getprop ro.product.cpu.abi
  shell > exit
```

**Referencia de comandos útiles:**

| Comando | Descripción |
|---|---|
| `pm list packages` | Todos los paquetes |
| `pm list packages -3` | Solo apps de terceros |
| `pm list packages -d` | Solo paquetes deshabilitados |
| `pm disable-user com.pkg` | Deshabilitar app |
| `pm uninstall -k --user 0 com.pkg` | Desinstalar sin root |
| `pm install-existing com.pkg` | Restaurar desinstalado |
| `am start -n com.pkg/.Activity` | Abrir app |
| `input keyevent 26` | Encender/apagar pantalla |
| `wm size` | Ver resolución |
| `getprop ro.product.cpu.abi` | Arquitectura del CPU |
| `getprop ro.build.version.release` | Versión Android |
| `settings get global private_dns_specifier` | Ver DNS activo |
| `reboot` | Reiniciar |

---

### `[6]` Comando ADB directo

Para comandos que incluyen el prefijo `shell` o son comandos directos de ADB. Escribe `exit` para volver.

```
  adb > shell pm disable-user com.nes.coreservice
  adb > shell pm uninstall -k --user 0 com.adups.fota
  adb > reboot
  adb > logcat -s ActivityManager
  adb > exit
```

> **Diferencia entre `[5]` y `[6]`:**
> - Opción `[5]` escribes: `pm disable-user com.pkg`
> - Opción `[6]` escribes: `shell pm disable-user com.pkg`

---

## 7. APKs — Opciones 7 a 9

### `[7]` Instalar APK desde Descargas

Busca todos los `.apk` en `%USERPROFILE%\Downloads` (hasta 3 niveles). Los lista con nombre y tamaño.

```
  APKs encontrados:

  [1] Netflix_v8.5.apk     (45.2 MB)
  [2] MiXplorer_v6.60.apk  (12.8 MB)
  [3] Ingresar ruta manualmente

  Selecciona APK [1-3] o 0 para cancelar: 1

  Modo de instalacion:
  [1] Normal
  [2] Reemplazar app existente (-r)
  [3] Fuentes externas + reemplazar (-r -d)
  Modo [1]:

  >> Performing Streamed Install
  >> Success

  OK  APK instalada correctamente.
```

**Cuándo usar cada modo:**

| Modo | Flag | Cuándo |
|---|---|---|
| Normal | — | Primera instalación |
| Reemplazar | `-r` | Actualizar app existente |
| Fuentes externas | `-r -d` | TV Box rechaza la instalación o downgrade |

---

### `[8]` Ver apps instaladas

```
  [1] Todas  [2] Solo terceros  [3] Buscar
```

### `[9]` Desinstalar app

Lista apps de terceros y permite desinstalar por número o escribiendo el nombre del paquete.

---

## 8. OPTIMIZACIÓN — Opciones 10, 11 y 16

### `[10]` Gestionar bloatware

Elimina aplicaciones de fábrica no deseadas sin root.

```
  -- Acceso rapido ---------------------------------
  [6]  Eliminar com.nes.coreservice   (1 clic, sin root)
  [7]  Deshabilitar com.nes.coreservice  (1 clic)
  [8]  Ver estado de com.nes.coreservice

  -- Opciones manuales -----------------------------
  [1]  Deshabilitar paquete (disable-user)   - reversible
  [2]  Desinstalar paquete para usuario 0    - permanente sin root
  [3]  Restaurar paquete desinstalado
  [4]  Limpiar lista predefinida de bloatware
  [5]  Ver paquetes deshabilitados
  [0]  Volver al menu
```

---

#### `[6]` Eliminar com.nes.coreservice — acceso rápido

Verifica si está instalado y ofrece dos modos de eliminación:

```
  Paquete encontrado. Como deseas eliminarlo?

  [1]  Deshabilitar  (reversible - recomendado si no estas seguro)
  [2]  Desinstalar   (permanente - limpieza definitiva sin root)
  [0]  Cancelar
```

---

#### `[7]` Deshabilitar com.nes.coreservice — un clic

Ejecuta directamente `pm disable-user com.nes.coreservice`. Sin preguntas.

```
  Ejecutando: pm disable-user com.nes.coreservice
  OK  Servicio deshabilitado correctamente.
```

Si el paquete no está instalado en el dispositivo lo informa y no hace nada.

---

#### `[8]` Ver estado de com.nes.coreservice

Consulta el estado real del paquete con tres niveles de verificación.

```
  ----------------------------------------
  Paquete: com.nes.coreservice
  Estado:  DESHABILITADO (disable-user)

  Detalle:
  enabledState=2
  ----------------------------------------
```

| Estado | Significado |
|---|---|
| `ACTIVO / HABILITADO` 🔴 | El servicio corre normalmente |
| `DESHABILITADO (disable-user)` 🟢 | Deshabilitado con opción `[7]` |
| `DESINSTALADO para usuario 0` 🟢 | Eliminado con opción `[6]` modo desinstalar |
| `NO INSTALADO en este dispositivo` 🟡 | El dispositivo no tiene ese paquete |

---

#### `[1]` Deshabilitar paquete manualmente

Ingresa cualquier nombre de paquete para deshabilitarlo.

```
  Nombre del paquete: com.adups.fota
  OK  Package com.adups.fota new state: disabled-user
```

#### `[2]` Desinstalar para usuario 0

Elimina el paquete para todos los usuarios sin root. El APK queda en el firmware pero invisible.

#### `[3]` Restaurar paquete

Reactiva un paquete desinstalado con `pm install-existing`.

#### `[4]` Limpiar lista predefinida

Procesa automáticamente esta lista en un solo paso:

| Paquete | Descripción |
|---|---|
| `com.nes.coreservice` | Telemetría y tracking NES |
| `com.nes.otaservice` | Actualizaciones forzadas NES |
| `com.nes.activation` | Activación y monitoreo NES |
| `com.smart.ota` | OTA de fabricantes genéricos |
| `com.adups.fota` | Spyware FOTA (muy común en dispositivos chinos) |
| `com.adups.fota.sysoper` | Componente auxiliar de FOTA |
| `com.rockchip.setbox` | Configuración Rockchip |
| `com.rockchip.gamestation` | Tienda de juegos Rockchip |
| `com.android.browser` | Navegador AOSP básico |
| `com.android.email` | Cliente de email AOSP |

Los paquetes no instalados se omiten automáticamente con `SKIP`.

---

#### Diferencia entre deshabilitar y desinstalar

| Operación | Comando ADB | Reversible |
|---|---|---|
| Deshabilitar | `pm disable-user com.pkg` | Sí — opción `[3]` |
| Desinstalar usuario 0 | `pm uninstall -k --user 0 com.pkg` | Sí — opción `[3]` |
| Restaurar | `pm install-existing com.pkg` | — |

---

### `[11]` Bloqueo de publicidad

```
  Estado DNS: ACTIVO  ->  dns.adguard.com

  [1]  Activar DNS AdGuard       (dns.adguard.com)
  [2]  Activar DNS NextDNS        (requiere cuenta)
  [3]  Activar DNS Mullvad        (adblock.dns.mullvad.net)
  [4]  Activar DNS ControlD       (freedns.controld.com)
  [5]  DNS personalizado
  [6]  Desactivar DNS bloqueador
  [7]  Instalar AdAway (modo VPN, bloqueo avanzado)
```

El estado DNS actual se muestra cada vez que entras al submenú.

#### Método 1 — DNS privado (opciones 1-5)

Redirige todo el tráfico DNS del dispositivo por un servidor que filtra publicidad. Funciona en todas las apps. Permanente, sobrevive reinicios.

| DNS | Servidor | Bloquea |
|---|---|---|
| AdGuard | `dns.adguard.com` | Ads + trackers |
| NextDNS | `tuID.dns.nextdns.io` | Personalizable (cuenta gratis en nextdns.io) |
| Mullvad | `adblock.dns.mullvad.net` | Ads + malware |
| ControlD | `freedns.controld.com` | Ads + trackers |

> **¿Por qué no bloquea los anuncios de YouTube?** Los anuncios de YouTube vienen del mismo dominio que el video (`googlevideo.com`). Bloquear ese dominio también bloquearía los videos. Para YouTube sin publicidad usar la opción **[16]**.

#### Método 2 — AdAway modo VPN (opción 7)

Crea una VPN local que filtra DNS sin root. Complementa el DNS privado con listas más detalladas.

1. Descargar APK desde `https://adaway.org`
2. Guardarlo en `%USERPROFILE%\Downloads\` con `adaway` en el nombre
3. Seleccionar opción `[7]` — el script lo detecta y lo instala automáticamente
4. Abrir AdAway en el TV Box y activar **modo VPN**

---

### `[16]` YouTube sin publicidad — SmartTubeNext

App alternativa de YouTube para Android TV. Bloquea publicidad completamente, sin root, sin cuenta requerida.

```
  [SMARTTUBENEXT] YouTube sin publicidad

  App alternativa de YouTube para Android TV.
  Bloquea publicidad, sin root, sin cuenta requerida.

  [1]  Descargar e instalar ultima version
  [2]  Desinstalar SmartTubeNext
  [0]  Volver al menu
```

#### Proceso de instalación automática

Al seleccionar `[1]` el script realiza todo el proceso sin intervención manual:

**Paso 1 — Detectar arquitectura del dispositivo**
```
  CPU detectada: armeabi-v7a
```

El script lee `ro.product.cpu.abi` del dispositivo conectado para elegir el APK correcto:

| CPU detectada | APK descargado |
|---|---|
| `armeabi-v7a` (TiVo Stream 4K, dispositivos 32-bit) | `smarttube_stable_armeabi_v7a.apk` |
| `arm64-v8a` (TV Boxes modernos, 64-bit) | `smarttube_stable.apk` |
| Otro | APK universal como fallback |

**Paso 2 — Consultar última versión en GitHub**
```
  Consultando ultima version en GitHub...
  Version encontrada: v19.08.03
  APK: SmartTube_stable_31.17_armeabi-v7a.apk
  Tamano del APK: 26.1 MB
```

Si el archivo ya fue descargado antes ofrece reutilizarlo sin volver a descargar.

**Paso 3 — Descarga con progreso en tiempo real**
```
  Descargando SmartTube_stable_31.17_armeabi-v7a.apk...
  Progreso: 67%
```

**Paso 4 — Instalación y verificación real**
```
  Instalando SmartTubeNext en el dispositivo...
  >> Performing Streamed Install

  Verificando instalacion en el dispositivo...
  OK  SmartTubeNext instalado correctamente.
  Abrelo desde el menu de apps del TV Box.
```

La verificación busca el paquete instalado con hasta **4 reintentos** y **3 variantes del nombre** del paquete para confirmar que realmente quedó instalado. Si por alguna razón no puede confirmarlo muestra:

```
  WARN No se pudo confirmar. Revisa el menu de apps del TV Box.
  Si aparece SmartTube en las apps, la instalacion fue exitosa.
```

#### Desinstalar SmartTubeNext

Usar la opción `[2]` del submenú.

---

## 9. UTILIDADES — Opciones 12 a 15

### `[12]` Info del dispositivo

```
  Marca:                 eSTREAM4K
  Modelo:                TiVo Stream 4K
  Nombre:                SEI400TV
  Android:               12
  SDK:                   31
  CPU:                   armeabi-v7a
  Serie:                 E33WDG202902425

  Almacenamiento:
  /dev/block/data  4363156  2226640  1038788  69% /data/user/0

  Bateria:
    status: 2
    level: 50
    temperature: 40
```

---

### `[13]` Captura de pantalla

Captura la pantalla del dispositivo, la descarga y la abre automáticamente.

```
  [SCREENSHOT] Capturando...
  OK  Guardado: C:\Users\Tony Reel\Pictures\screenshot_20250321_142530.png
```

Ruta: `%USERPROFILE%\Pictures\screenshot_YYYYMMDD_HHMMSS.png`

---

### `[14]` Idioma / Language

Cambia el idioma de toda la interfaz. El título siempre aparece en ambos idiomas.

```
  [IDIOMA / LANGUAGE]

  Idioma actual: Espanol

  [1]  Espanol
  [2]  English
  [0]  Volver / Back

  Selecciona / Select:
```

Al cambiar, todos los menús, mensajes, confirmaciones y errores cambian inmediatamente.

---

### `[15]` Cambiar puerto ADB

El puerto activo se muestra siempre en el menú: `[15] Cambiar puerto ADB [5555]`.

```
  [CAMBIAR PUERTO ADB]
  Puerto por defecto: 5555. Android 11+ puede usar un puerto diferente.

  Puerto activo: 5555
  Nuevo puerto [5555]: 37621
  OK  Puerto cambiado a 37621. Se usara en las proximas conexiones.
```

El puerto activo se usa en el scan, conexión manual y todas las operaciones. Si una conexión es exitosa con un puerto diferente al configurado, ese puerto se guarda automáticamente.

---

## 10. Solución de problemas

### Error al ejecutar el script — política de ejecución

```powershell
powershell -ExecutionPolicy Bypass -File adb-wifi-manager.ps1
```

### `adb` no encontrado

```powershell
# Arch Linux
sudo pacman -S android-tools

# Verificar en Windows
adb version
# Si no responde, revisar que C:\platform-tools esté en el PATH
```

### El scan no detecta el dispositivo

Verificar que el puerto ADB esté abierto:

```powershell
Test-NetConnection -ComputerName 192.168.68.106 -Port 5555
# TcpTestSucceeded debe ser True
```

Si es `False`: ADB WiFi no está activo. Usar opción `[3]` con USB o activarlo en Opciones de desarrollador. Si el scan sigue sin encontrarlo aunque el puerto esté abierto, usar opción `[2]` con la IP directamente.

### Dispositivo conectado pero dice `unauthorized`

Buscar en la pantalla del dispositivo el diálogo **"Permitir depuración ADB"** y seleccionar **Siempre permitir desde este equipo**.

### Error `connection refused`

```powershell
adb kill-server
adb start-server
adb connect 192.168.68.106:5555
```

### La conexión se pierde al cambiar de red

El script lo detecta automáticamente al volver al menú y limpia la sesión. Usar `[1]` o `[2]` para reconectar.

### Android 11+ — el puerto cambia tras cada reinicio

1. En el dispositivo: **Configuración → Opciones de desarrollador → Depuración inalámbrica** — anotar el nuevo puerto
2. En el script: opción **`[15]`** para actualizar el puerto
3. Luego opción **`[2]`** para conectar

### APK no instala — `INSTALL_FAILED_FROM_UNKNOWN_SOURCES`

**Configuración → Seguridad → Orígenes desconocidos → Activar**

En TiVo y Google TV: **Configuración → Apps → Acceso especial → Instalar apps desconocidas**

### APK no instala — `INSTALL_FAILED_VERSION_DOWNGRADE`

Usar modo **`[3] Fuentes externas + reemplazar (-r -d)`** en la pantalla de instalación.

### SmartTubeNext dice instalado pero no aparece en las apps

El TiVo Stream 4K y dispositivos Google TV a veces requieren que actives explícitamente los orígenes desconocidos antes de instalar. Ver sección [TiVo Stream 4K y Google TV](#tivo-stream-4k-y-google-tv). Luego reintentar con la opción `[16]` → `[1]`.

### `pm uninstall` falla en paquetes del sistema

Algunos paquetes del sistema no permiten desinstalación sin root. Usar opción **`[1] Deshabilitar`** como alternativa segura.

---

## 📁 Archivos generados

```
%USERPROFILE%\
├── Downloads\               ← APKs descargados (SmartTubeNext, AdAway, etc.)
└── Pictures\                ← Capturas de pantalla
    └── screenshot_*.png
```

---

## 📜 Licencia

Uso libre para fines personales y educativos.  
## Créditos

- [`tccplus`](https://github.com/jslegendre/tccplus) por jslegendre

Si puedes regalame un caffe 

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://paypal.me/yaba09)

