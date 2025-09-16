#### Parte teórica

1. **Introducción a DevOps: ¿Qué es y qué no es?**
   Explica DevOps desde el código hasta la producción, diferenciándolo de waterfall. Discute "you build it, you run it" en el laboratorio, y separa mitos (ej. solo herramientas) vs realidades (CALMS, feedback, métricas, gates).

   * *Tip:* Piensa en ejemplos concretos: ¿cómo se vería un gate de calidad en tu Makefile?

   DevOps es cultura, fomenta un ambiente colaborativo entre QA, desarrollo y operaciones, terminando así con los silos organizacionales. Se basa en integración continua, entregables pequeños y específicos, lo que permite identificar y corregir fácilmente errores. A diferencia de Waterfall, que es secuencial, los entregables son grandes y no existe ese ambiente colaborativo, lo que puede ocasionar tener que rehacer gran parte del proyecto, etc.

   El gate que implementaría en el Makefile principalmente ejecutaría todos los tests para verificar que pasen correctamente y así poder avanzar de forma segura, por ejemplo, hacia el despliegue.

2. **Marco CALMS en acción:**
   Describe cada pilar y su integración en el laboratorio (ej. Automation con Makefile, Measurement con endpoints de salud). Propón extender Sharing con runbooks/postmortems en equipo.


3. **Visión cultural de DevOps y paso a DevSecOps:**
   Analiza colaboración para evitar silos, y evolución a DevSecOps (integrar seguridad como cabeceras TLS, escaneo dependencias en CI/CD).
   Propón escenario retador: fallo certificado y mitigación cultural. Señala 3 controles de seguridad sin contenedores y su lugar en CI/CD.

   DevOps elimina silos mediante colaboración continua entre QA, desarrollo y operaciones, evitando el anti-patrón "throw over the wall" donde desarrollo entrega código "gigantesco" sin contexto,  aumentando el MTTR.

   Para evolucionar a DevSecOps, considero que la seguridad se debe integrar desde el inicio, usando por ejemplo los siguientes controles de seguridad: SAST y DAST.


4. **Metodología 12-Factor App:**
   Elige 4 factores (incluye config por entorno, port binding, logs como flujos) y explica implementación en laboratorio.
   Reto: manejar la ausencia de estado (statelessness) con servicios de apoyo (backing services).

   Config: Separar configuración del código usando variables de entorno
    - Por ejemplo, usar .env files para múltiples ambientes
      
   Port binding: Servicio se autocontiene y expone puerto
    - Evitar harcodear puertos y usar los definidos en las variable de entorno
      
   Logs: Tratar logs como flujos de eventos a stdout/stderr
    - Por ejemplo usando console.log() hacia stdout, capturado por orquestador y así evitando escribir logs en archivos locales que se pierden al reiniciar
      
   Processes: Ejecutar como procesos stateless
