#!/usr/bin/env bash
set -euo pipefail
trap 'echo "[ERROR] Falló en línea $LINENO" >&2' ERR

mkdir -p reports

# TODO: HTTP — guarda headers y explica código en 2–3 líneas al final del archivo
{
  echo "== curl -I google.com =="
  curl -Is https://google.com | sed '/^\r$/d'
  echo
  echo "Explicación: Código HTTP 301 significa que la URL solicitada ha sido movida permanentemente a una nueva ubicación que es indica en location."
  echo "Los headers muestran información del servidor como content-type, content-security-policy-report-only, date."
} > reports/http.txt

# TODO: DNS — muestra A/AAAA/MX y comenta TTL
{
  echo "== A ==";    dig A google.com +noall +answer
  echo "== AAAA =="; dig AAAA google.com +noall +answer
  echo "== MX ==";   dig MX google.com +noall +answer
  echo
  echo "Los registros A y AAAA proporcionan IPs para la resolución de nombres, permitiendo la conectividad tanto en IPv4 como en IPv6."
  echo "Un TTL bajo aumenta consultas DNS, permite actualizaciones rápidas, pero puede aumentar la carga en los servidores DNS."
  echo "Un TTL alto reduce la frecuencia de consultas a los servidores DNS, pero los cambios en los registros pueden tardar más en propagarse."
} > reports/dns.txt

# TODO: TLS — registra versión TLS
{
  echo "== TLS via curl -Iv =="
  curl -Iv https://google.com 2>&1 | sed -n '1,20p'
} > reports/tls.txt

# TODO: Puertos locales — lista y comenta riesgos
{
  echo "== ss -tuln =="
  ss -tuln || true
  echo
  echo "Riesgos: Puertos abiertos innecesarios aumentan el rango de ataques como malware, accesos no autorizados o ataques DoS."
} > reports/sockets.txt

echo "Reportes generados en ./reports"
