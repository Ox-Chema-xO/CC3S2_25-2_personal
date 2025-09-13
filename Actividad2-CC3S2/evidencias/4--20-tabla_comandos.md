# Comando -> Resultado esperado

| Comando | Resultado esperado |
|---|---|
| `PORT=8080 MESSAGE="Hola CC3S2" RELEASE="v1" python3 app.py` | La app escucha en :8080, hace logs JSON a stdout y responde JSON con `message` y `release`. |
| `curl -v http://127.0.0.1:8080/` | Muestra solicitud/respuesta con cabeceras, código 200 y cuerpo JSON. |
| `curl -i -X POST http://127.0.0.1:8080/` | Devuelve 405 Method Not Allowed (la ruta '/' solo acepta GET). |
| `ss -ltnp | grep :8080` | Socket TCP en LISTEN con el PID del proceso Python. |
| `dig +short miapp.local` | Devuelve 127.0.0.1 (por entrada en /etc/hosts). |
| `getent hosts miapp.local` | Resolución vía NSS; muestra 127.0.0.1. |
| `openssl s_client -connect miapp.local:443 -servername miapp.local -brief` | Handshake TLSv1.2/1.3 con certificado autofirmado; SNI correcto. |
| `curl -k https://miapp.local/` | Respuesta 200 con JSON; `-k` omite validación de CA por ser autofirmado. |
| `journalctl -u nginx -n 50` | Últimas líneas del servicio Nginx (si systemd). |
| `tail -f evidencias/4--01-app-stdout.log | head -n 5` | Demuestra logs como flujo redirigible por pipeline. |
