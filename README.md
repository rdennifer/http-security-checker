# HTTP Security Checker - Version 1.0

HTTP Security Checker es una herramienta de línea de comandos para probar métodos HTTP habilitados y verificar cabeceras de seguridad en servidores web. Es útil para identificar configuraciones de seguridad y posibles vulnerabilidades en aplicaciones web.

## Características

- Prueba métodos HTTP comunes (OPTIONS, TRACE, PUT, DELETE, GET, HEAD, POST, PATCH, CONNECT).
- Verifica la presencia de cabeceras de seguridad esenciales.
- Proporciona un resumen de los resultados en un formato fácil de leer con colores para indicar el nivel de riesgo.
- Proporciona recomendaciones basadas en los resultados.

## Requisitos

- `curl` debe estar instalado en tu sistema.
- Se recomienda tener privilegios de superusuario para una mejor precisión de los resultados.

## Instalación

### En Kali Linux

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/tuusuario/http-security-checker.git
   cd http-security-checker
## Dar permisos de ejecución al script:
chmod +x check_http_methods.sh
## En Windows
## Instalar Git Bash (si no lo tienes).

## Clonar el repositorio usando Git Bash:
git clone https://github.com/tuusuario/http-security-checker.git
cd http-security-checker
## Dar permisos de ejecución al script:

chmod +x check_http_methods.sh
### Nota: En Windows, es recomendable usar Git Bash o WSL (Windows Subsystem for Linux) para ejecutar el script.

# Uso En Kali Linux y Windows
## Navegar al directorio del script:
cd http-security-checker
## Ejecutar el script:
./check_http_methods.sh
# Ingresar la URL del servidor a probar cuando se solicite.

Ejemplo de Salida
=================================================================================
HTTP Security Checker - Version 1.0

Ingrese la URL del servidor a probar: https://example.com

Probando métodos HTTP en https://example.com
================================
Métodos HTTP habilitados:
- OPTIONS: Habilitado - Código de respuesta: 200
- HEAD: Habilitado - Código de respuesta: 404
- PUT: Habilitado - Código de respuesta: 403
- GET: Habilitado - Código de respuesta: 404
- POST: Habilitado - Código de respuesta: 404
- DELETE: Habilitado - Código de respuesta: 403

Métodos HTTP no habilitados:
- TRACE: No habilitado - Código de respuesta: 405
- PATCH: No habilitado - Código de respuesta: 501
- CONNECT: No habilitado - Código de respuesta: 400
================================

Verificando cabeceras de seguridad en https://example.com
================================
Cabeceras de seguridad presentes:
- Strict-Transport-Security: Presente
- X-Content-Type-Options: Presente
- X-Frame-Options: Presente
- X-XSS-Protection: Presente
- Content-Security-Policy: Presente
- Referrer-Policy: Presente

Cabeceras de seguridad ausentes:
- Permissions-Policy: Ausente
- Expect-CT: Ausente
- Feature-Policy: Ausente
- Cross-Origin-Embedder-Policy: Ausente
- Cross-Origin-Opener-Policy: Ausente
- Cross-Origin-Resource-Policy: Ausente
================================

Verificando detalles de SSL en https://example.com
================================
SSL Details: 
- SSL connection using TLSv1.2 / ECDHE-RSA-AES256-GCM-SHA384 / prime256v1 / RSASSA-PSS
================================

Leyenda de colores:
- Rojo: Alto riesgo
- Naranja: Riesgo medio
- Verde: Sin problemas
================================

Descripción de métodos HTTP:
- TRACE: Puede ser explotado para ataques de Cross-Site Tracing (XST). Debe ser deshabilitado en producción.
- CONNECT: Utilizado para túneles a través de proxies HTTP. Puede ser explotado para ataques y generalmente debe ser deshabilitado.
- OPTIONS: Permite al cliente ver los métodos HTTP permitidos por el servidor.
- HEAD: Similar a GET, pero solo solicita los encabezados de la respuesta. Generalmente seguro.
- PUT: Permite subir archivos al servidor. Debe estar protegido para evitar cargas maliciosas.
- GET: Método común para solicitar recursos. Generalmente seguro, pero debe ser monitoreado para evitar abuso.
- POST: Utilizado para enviar datos al servidor, como formularios. Debe estar protegido contra inyecciones y abusos.
- PATCH: Utilizado para aplicar modificaciones parciales a un recurso. Debe estar restringido y monitoreado.
- DELETE: Permite eliminar recursos en el servidor. Debe estar restringido para evitar eliminaciones no autorizadas.
================================

Descripción de códigos de respuesta:
- 200: OK - Solicitud exitosa.
- 204: No Content - Solicitud exitosa pero sin contenido.
- 401: Unauthorized - No autorizado.
- 403: Forbidden - Prohibido.
- 404: Not Found - No encontrado.
- 405: Method Not Allowed - Método no permitido.
- 501: Not Implemented - No implementado.
================================

Recomendaciones:
- Para los métodos habilitados que presentan riesgos (como PUT y DELETE), considere deshabilitarlos o asegurar su uso con autenticación adecuada y controles de acceso.
- Las cabeceras de seguridad faltantes deben ser añadidas para mejorar la protección contra diversos ataques web.
================================

Fin de la prueba.
