# Reporte--Actividad 2: HTTP, DNS, TLS y 12-Factor
Se logra aprender sobre despliegues seguros y reproducibles combinando aplicación (HTTP), resolución de nombres (DNS), cifrado en tránsito (TLS) y buenas prácticas12-Factor (variables de entorno, port binding y logs a stdout).

## 1. HTTP: Fundamentos y herramientas

### 1.1 Levantamiento de la aplicacion

La aplicacion Flask se ejecuta exitosamente con variables de entorno segun 12-Factor:
**Evidencia:** `evidencias/4--01-app-stdout.log`

### 1.2 Inspeccion con curl

#### Solicitud GET exitosa:
**Comando:** `curl -v http://127.0.0.1:8080/`  
**Evidencia:** `evidencias/4--02-curl-v.txt`

#### Solicitud POST no soportada:
**Comando:** `curl -i -X POST http://127.0.0.1:8080/`  
**Evidencia:** `evidencias/4--03-curl-i-post.txt`

### 1.3 Puerto abierto

**Comando:** `ss -ltnp | grep :8080`  
**Evidencia:** `evidencias/4--04-ss-port-8080.txt`

**Que campos cambian si actualizas MESSAGE/RELEASE sin reiniciar el proceso?**

**Evidencia:** `evidencias/4--05-env-change-explanation.txt`

## 2. DNS: Nombres, registros y cache

### 2.1 Configuracion de hosts local

Se agrega la entrada `127.0.0.1 miapp.local` a `/etc/hosts` para resolver el dominio localmente.

**Evidencia:** `evidencias/4--06-hosts-setup.txt`

### 2.2 Comprobacion de resolucion

#### dig +short:
**Comando:** `dig +short miapp.local`  
**Evidencia:** `evidencias/4--07-dig-miapp.txt`  

#### getent hosts:
**Comando:** `getent hosts miapp.local`  
**Evidencia:** `evidencias/4--08-getent-miapp.txt`  

### 2.3 TTL/Cache conceptual
**Comando:** `dig example.com A +ttlunits`  
**Evidencia:** `evidencias/4--09-ttl-demo.txt`

**Que diferencia hay entre /etc/hosts y una zona DNS autoritativa?**

**Evidencia:** `evidencias/4--10-hosts-vs-authoritative.txt`

## 3. TLS: Seguridad en transito con Nginx

### 3.1 Certificado de laboratorio

**Evidencia:** `evidencias/4--11-cert-paths.txt`


### 3.2 Configuracion de Nginx

**Evidencia:** `evidencias/4--12-nginx-test.txt`

### 3.3 Validacion del handshake TLS

**Comando:** `openssl s_client -connect miapp.local:443 -servername miapp.local -brief`  
**Evidencia:** `evidencias/4--13-s_client-brief.txt`

### 3.4 Prueba con curl

**Comando:** `curl -k https://miapp.local/`  
**Evidencia:** `evidencias/4--15-curl-k-body.json`

### 3.5 Puertos y logs

**Puertos abiertos:**  
**Evidencia:** `evidencias/4--16-ss-ports-443-8080.txt`

**Logs de Nginx:**  
**Evidencia:** `evidencias/4--17-nginx-journalctl.txt`

## 4. 12-Factor App: Port binding, configuracion y logs

### 4.1 Port binding
La aplicacion escucha en el puerto establecido por la variable `PORT`.

### 4.2 Configuracion por entorno
Uso de variables `MESSAGE`, `RELEASE` y `PORT`.

### 4.3 Logs a stdout
**Comando:** `tail -f evidencias/4--01-app-stdout.log | head -n 5`  
**Evidencia:** `evidencias/4--18-logs-pipeline-sample.txt`

**Por que no archivos de log?**  
**Evidencia:** `evidencias/4--19-why-stdout-12factor.txt`

## 5. Operacion reproducible

### 5.1 Tabla de comandos y resultados esperados
**Evidencia:** `evidencias/4--20-tabla_comandos.md`
