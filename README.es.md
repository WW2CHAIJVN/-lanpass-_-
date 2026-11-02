# lanpass

[简体中文](README.md) | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | **Español** | [Français](README.fr.md)

> Cuando el Grupo Hogar desaparece, la detección de red falla y el acceso de invitado está bloqueado por defecto — lanpass sigue permitiendo que Windows 7 / 10 / 11 se vean entre sí.

<img src="https://img.shields.io/badge/Windows-7%20%7C%2010%20%7C%2011-0078D6?style=flat-square&logo=windows&logoColor=white" alt="Platform">
<img src="https://img.shields.io/badge/License-MIT-3DA639?style=flat-square" alt="License">
<img src="https://img.shields.io/badge/dependencies-zero-success?style=flat-square" alt="Dependencies">

## El problema

Un aula de informática: decenas de PC, un solo switch, una sola subred. Pero la carpeta «Red» no muestra nada.

Hay dos capas de causas.

**Capa superficial**: el Grupo Hogar llegó en Windows 7 y fue **eliminado en Windows 10 1803**. Win7 y Win10/11 no comparten ningún mecanismo.

**Causa raíz**: desde Windows 10 1709, `AllowInsecureGuestAuth` vale 0 por defecto. Win10/11 rechaza todo acceso SMB anónimo. Aunque sortees el Grupo Hogar y te conectes por IP, verás *«Las directivas de seguridad de su organización bloquean el acceso de invitado sin autenticar»*.

**Arreglar solo el Grupo Hogar no sirve. El bloqueo está en la autenticación SMB.**

## Características

| | |
|---|---|
| **Cero dependencias** | Solo `mshta` / `cmd` / `net` / `ping` / `arp` integrados. Sin .NET, VC++, Java, Python ni Node |
| **Sin servicios de detección** | Funciona aunque Grupo Hogar, Detección de red, Computer Browser, SSDP y DNS estén caídos |
| **Entre versiones** | Win7 / Win10 / Win11 en ambos sentidos |
| **Dos roles** | Cliente de profesor para toda la clase, cliente de alumno para entregar con un clic |
| **Autocorrección** | Escribe 4 valores de registro que resuelven el bloqueo de acceso de invitado |
| **Detección activa** | Tabla ARP + ping a toda la subred, sin servicios del sistema |
| **Memoria de equipos** | Lista en caché, arranque instantáneo |
| **Bajo consumo** | 34 MB de RAM, 0% de CPU en reposo, sin sondeo |

## Inicio rápido

1. Copia la carpeta a cada PC
2. PC del profesor: ejecuta `教师端.exe`; PC del alumno: `学生端.exe`
3. Pulsa «配置共享» (Configurar recurso compartido) y acepta el UAC
4. Profesor: pulsa «刷新学生机» (Actualizar alumnos). ¿Lista vacía? Pulsa «全段扫描» (Escaneo completo)
5. Pulsa «打开» (Abrir) en la fila del alumno

¿Sin unidad D:? Cambia `D:\lan-share` por una ruta existente en `setup-share.bat` y `app.hta`.

## Interfaz

| Profesor | Alumno |
|---|---|
| ![](docs/screenshots/teacher.png) | ![](docs/screenshots/student.png) |

## Más

- [Preguntas frecuentes, 27 entradas (chino)](docs/QRA.txt)
- [Notas de seguridad](docs/SECURITY.md)
- [Instrucciones de compilación](BUILD.md)

## Notas técnicas

La detección lee la tabla ARP local (capa 2, independiente de los servicios de Windows). Si ARP está vacía, un ping a toda la subred (254 direcciones, 32 en paralelo, unos 4 segundos) la rellena. El ping solo sirve para llenar la tabla ARP, no para esperar respuestas ICMP.

La interfaz es un HTA renderizado por el `mshta.exe` integrado (modo de compatibilidad IE8). Todo el código es HTML + JScript en texto plano y se puede auditar.

## Licencia

MIT
