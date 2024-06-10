#!/bin/bash
# Licensed under the MIT License - see the LICENSE file for details

# Colores
RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner de encabezado
echo -e "${BLUE}================================================================================="
echo -e "HTTP Security Checker - Version 1.0"
echo -e "=================================================================================${NC}"

# Función para validar la URL
validate_url() {
    if [[ "$1" =~ ^https?:// ]]; then
        return 0
    else
        return 1
    fi
}

# Solicitar al usuario que ingrese la URL del servidor a probar
while true; do
    read -p "Ingrese la URL del servidor a probar: " URL
    if validate_url "$URL"; then
        break
    else
        echo -e "${RED}URL no válida. Debe comenzar con http:// o https://${NC}"
        read -p "¿Desea intentar de nuevo? (s/n): " choice
        case "$choice" in 
            s|S ) continue ;;
            n|N ) echo "Saliendo..."; exit 1 ;;
            * ) echo -e "${RED}Respuesta no válida. Saliendo...${NC}"; exit 1 ;;
        esac
    fi
done

# Lista completa de métodos HTTP a probar y sus explicaciones
METHODS=("OPTIONS" "TRACE" "PUT" "DELETE" "GET" "HEAD" "POST" "PATCH" "CONNECT")
METHODS_DESCRIPTIONS=(
    "Permite al cliente ver los métodos HTTP permitidos por el servidor."
    "Puede ser explotado para ataques de Cross-Site Tracing (XST). Debe ser deshabilitado en producción."
    "Permite subir archivos al servidor. Debe estar protegido para evitar cargas maliciosas."
    "Permite eliminar recursos en el servidor. Debe estar restringido para evitar eliminaciones no autorizadas."
    "Método común para solicitar recursos. Generalmente seguro, pero debe ser monitoreado para evitar abuso."
    "Similar a GET, pero solo solicita los encabezados de la respuesta. Generalmente seguro."
    "Utilizado para enviar datos al servidor, como formularios. Debe estar protegido contra inyecciones y abusos."
    "Utilizado para aplicar modificaciones parciales a un recurso. Debe estar restringido y monitoreado."
    "Utilizado para túneles a través de proxies HTTP. Puede ser explotado para ataques y generalmente debe ser deshabilitado."
)

# Función para probar un método HTTP
test_http_method() {
    METHOD=$1
    RESPONSE=$(curl -sk -X "$METHOD" -I -L "$URL" 2>&1)
    RESPONSE_CODE=$(echo "$RESPONSE" | grep HTTP/ | tail -n 1 | awk '{print $2}')
    if [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "204" || "$RESPONSE_CODE" == "401" || "$RESPONSE_CODE" == "403" || "$RESPONSE_CODE" == "404" ]]; then
        echo -e "${BLUE}$METHOD${NC}: ${RED}Habilitado${NC} - Código de respuesta: ${BLUE}$RESPONSE_CODE${NC}" >> enabled_methods.txt
    else
        echo -e "${BLUE}$METHOD${NC}: ${GREEN}No habilitado${NC} - Código de respuesta: ${BLUE}$RESPONSE_CODE${NC}" >> disabled_methods.txt
    fi
}

# Lista de cabeceras de seguridad a verificar
HEADERS=("Strict-Transport-Security" "X-Content-Type-Options" "X-Frame-Options" "X-XSS-Protection" "Content-Security-Policy" "Referrer-Policy" "Permissions-Policy" "Expect-CT" "Feature-Policy" "Cross-Origin-Embedder-Policy" "Cross-Origin-Opener-Policy" "Cross-Origin-Resource-Policy")

# Función para comprobar cabeceras de seguridad
check_security_headers() {
    RESPONSE=$(curl -sk -I -L "$URL" 2>/dev/null)
    echo "$RESPONSE" > response_headers.txt
    for HEADER in "${HEADERS[@]}"; do
        HEADER_VALUE=$(grep -i "$HEADER" response_headers.txt)
        if [ ! -z "$HEADER_VALUE" ]; then
            echo -e "${BLUE}$HEADER${NC}: ${GREEN}Presente${NC} - ${HEADER_VALUE}" >> present_headers.txt
        else
            echo -e "${BLUE}$HEADER${NC}: ${RED}Ausente${NC}" >> absent_headers.txt
        fi
    done
}

# Función para comprobar detalles SSL
check_ssl_details() {
    RESPONSE=$(curl -sk -v "$URL" 2>&1 | grep "SSL connection using")
    echo -e "${BLUE}SSL Details${NC}: $RESPONSE" >> ssl_details.txt
}

# Limpiar archivos temporales
rm -f enabled_methods.txt disabled_methods.txt present_headers.txt absent_headers.txt response_headers.txt ssl_details.txt

# Probar todos los métodos HTTP
echo -e "${BLUE}Probando métodos HTTP en $URL${NC}"
echo "================================"
for i in "${!METHODS[@]}"; do
    test_http_method "${METHODS[$i]}"
done

# Mostrar resultados de métodos HTTP
echo -e "${BLUE}Métodos HTTP habilitados:${NC}"
if [ -f enabled_methods.txt ]; then
    cat enabled_methods.txt
else
    echo -e "${GREEN}No se encontraron métodos habilitados.${NC}"
fi
echo "--------------------------------"
echo -e "${BLUE}Métodos HTTP no habilitados:${NC}"
if [ -f disabled_methods.txt ]; then
    cat disabled_methods.txt
else
    echo -e "${RED}No se encontraron métodos no habilitados.${NC}"
fi

# Verificar cabeceras de seguridad
echo "================================"
echo -e "${BLUE}Verificando cabeceras de seguridad en $URL${NC}"
echo "================================"
check_security_headers

# Mostrar resultados de cabeceras de seguridad
echo -e "${BLUE}Cabeceras de seguridad presentes:${NC}"
if [ -f present_headers.txt ]; then
    cat present_headers.txt
else
    echo -e "${RED}No se encontraron cabeceras presentes.${NC}"
fi
echo "--------------------------------"
echo -e "${BLUE}Cabeceras de seguridad ausentes:${NC}"
if [ -f absent_headers.txt ]; then
    cat absent_headers.txt
else
    echo -e "${GREEN}No se encontraron cabeceras ausentes.${NC}"
fi

# Verificar detalles SSL
echo "================================"
echo -e "${BLUE}Verificando detalles de SSL en $URL${NC}"
echo "================================"
check_ssl_details
if [ -f ssl_details.txt ]; then
    cat ssl_details.txt
else
    echo -e "${RED}No se encontraron detalles de SSL.${NC}"
fi

# Limpiar archivos temporales
rm -f enabled_methods.txt disabled_methods.txt present_headers.txt absent_headers.txt response_headers.txt ssl_details.txt


# Leyenda de colores
echo -e "${BLUE}Leyenda de colores:${NC}"
echo -e "${RED}Rojo:${NC} Alto riesgo"
echo -e "${ORANGE}Naranja:${NC} Riesgo medio"
echo -e "${GREEN}Verde:${NC} Sin problemas"
echo "================================"

# Descripción de métodos HTTP
echo -e "${BLUE}Descripción de métodos HTTP:${NC}"
echo -e "${RED}TRACE:${NC} Puede ser explotado para ataques de Cross-Site Tracing (XST). Debe ser deshabilitado en producción."
echo -e "${ORANGE}CONNECT:${NC} Utilizado para túneles a través de proxies HTTP. Puede ser explotado para ataques y generalmente debe ser deshabilitado."
echo -e "${GREEN}OPTIONS:${NC} Permite al cliente ver los métodos HTTP permitidos por el servidor."
echo -e "${GREEN}HEAD:${NC} Similar a GET, pero solo solicita los encabezados de la respuesta. Generalmente seguro."
echo -e "${RED}PUT:${NC} Permite subir archivos al servidor. Debe estar protegido para evitar cargas maliciosas."
echo -e "${GREEN}GET:${NC} Método común para solicitar recursos. Generalmente seguro, pero debe ser monitoreado para evitar abuso."
echo -e "${ORANGE}POST:${NC} Utilizado para enviar datos al servidor, como formularios. Debe estar protegido contra inyecciones y abusos."
echo -e "${ORANGE}PATCH:${NC} Utilizado para aplicar modificaciones parciales a un recurso. Debe estar restringido y monitoreado."
echo -e "${RED}DELETE:${NC} Permite eliminar recursos en el servidor. Debe estar restringido para evitar eliminaciones no autorizadas."
echo "================================"

# Descripción de códigos de respuesta
echo -e "${BLUE}Descripción de códigos de respuesta:${NC}"
echo -e "${GREEN}200:${NC} OK - Solicitud exitosa."
echo -e "${GREEN}204:${NC} No Content - Solicitud exitosa pero sin contenido."
echo -e "${RED}401:${NC} Unauthorized - No autorizado."
echo -e "${RED}403:${NC} Forbidden - Prohibido."
echo -e "${RED}404:${NC} Not Found - No encontrado."
echo -e "${ORANGE}405:${NC} Method Not Allowed - Método no permitido."
echo -e "${ORANGE}501:${NC} Not Implemented - No implementado."
echo "================================"

# Recomendaciones
echo -e "${BLUE}Recomendaciones:${NC}"
echo "Para los métodos habilitados que presentan riesgos (como PUT y DELETE), considere deshabilitarlos o asegurar su uso con autenticación adecuada y controles de acceso."
echo "Las cabeceras de seguridad faltantes deben ser añadidas para mejorar la protección contra diversos ataques web."
echo "================================"

# Fin de la prueba
echo -e "${BLUE}Fin de la prueba.${NC}"
