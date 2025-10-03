### **Actividad 7: Explorando estrategias de fusión en Git**

1. ¿Cuándo evitarías --ff en un equipo y por qué?
Evitaría --ff cuando se necesita dejar registro claro de la integración de ramas, por ejemplo en proyectos colaborativos, para identificar fácilmente cuándo se fusionó una rama y mantener trazabilidad.

2. ¿Qué ventajas de trazabilidad aporta --no-ff? ¿Qué problemas surgen con exceso de merges?
--no-ff permite ver en el historial el punto exacto de integración y los padres del merge, facilitando auditoría y seguimiento. El exceso de merges puede hacer el historial más difícil de leer y seguir, generando ruido innecesario.

3. ¿Cuándo conviene usar squash? ¿Qué se pierde respecto a merges estándar?
Conviene usar squash para mantener el historial principal limpio, especialmente al integrar ramas con muchos commits pequeños. Se pierde el detalle de los commits individuales y la relación directa de la rama en el DAG.

4. Conflictos reales con no-fast-forward:
Para resolver el conflicto, edité el archivo afectado, eliminando las marcas de conflicto y dejando el contenido final que crei pertinente. Es recomendable hacer PRs pequeños y usar pruebas automáticas para evitar conflictos frecuentes, ademas asi el equipo sabra que archivos se estan y decidir si aceptarlo o no.

5. Comparar historiales tras cada método:
El DAG con fast-forward es lineal y simple. Con no-ff aparecen los puntos de integración (merge commits). Squash muestra solo el commit final en la rama principal, ocultando los detalles intermedios. Para trabajo individual prefiero fast-forward, en equipo o con auditoría estricta es mejor no-ff para mantener trazabilidad.

6. Revertir una fusión (solo si HEAD es un merge commit):
Usar git revert en vez de git reset cuando se necesita deshacer una fusión sin modificar el historial, especialmente cuando este trabajando en un repo compartido. Git revert crea un nuevo commit que revierte los cambios del merge, manteniendo la trazabilidad.

7. Sesgos de resolución y normalización (algoritmo ORT):
Al realizar la actividad propuesta, se demuestra cómo Git permite resolver conflictos automáticamente mediante opciones de estrategia (-X) durante un merge, según las prioridades del desarrollador o del equipo.
Por ejemplo, utilicé -X ours para priorizar los cambios de la rama actual (main), ya que en ese contexto esos cambios eran más relevantes y debían preservarse sobre los de la rama que se estaba integrando.
