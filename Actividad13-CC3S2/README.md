### Actividad: Escribiendo infraestructura como código en un entorno local con Terraform

####  Contexto

Imagina que gestionas docenas de entornos de desarrollo locales para distintos proyectos (app1, app2, ...). En lugar de crear y parchear manualmente cada carpeta, construirás un generador en Python que produce automáticamente:

* **`network.tf.json`** (variables y descripciones)
* **`main.tf.json`** (recursos que usan esas variables)

Después verás cómo Terraform identifica cambios, remedia desvíos manuales y permite migrar configuraciones legacy a código. Todo sin depender de proveedores en la nube, Docker o APIs externas.


#### Fase 0: Preparación 

1. **Revisa** el [laboratorio 5](https://github.com/kapumota/Curso-CC3S2/tree/main/labs/Laboratorio5)  :

   ```
   modules/simulated_app/
     ├─ network.tf.json
     └─ main.tf.json
   generate_envs.py
   ```
2. **Verifica** que puedes ejecutar:

   ```bash
   python generate_envs.py
   cd environments/app1
   terraform init
   ```
3. **Objetivo**: conocer la plantilla base y el generador en Python.

####  Fase 1: Expresando el cambio de infraestructura

* **Concepto**
Cuando cambian variables de configuración, Terraform los mapea a **triggers** que, a su vez, reconcilian el estado (variables ->triggers ->recursos).

* **Actividad**

  - Modifica en `modules/simulated_app/network.tf.json` el `default` de `"network"` a `"lab-net"`.
  - Regenera `environments/app1` con `python generate_envs.py`.
  - `terraform plan` observa que **solo** cambia el trigger en `null_resource`.

* **Pregunta**

  * ¿Cómo interpreta Terraform el cambio de variable?
     
      Terraform maneja el cambio de la variable network como un cambio en el atributo “triggers” del recurso null_resource. Mantiene un estado de los valores actuales de cada recurso, y cuando se detecta un cambio entre el estado y la configuración, al aplicar ‘terraform plan’ se genera un plan que mostrará los atributos exactos a cambiar. En este proyecto, al modificar solo el valor de una variable que se usa como trigger, Terraform sabe que únicamente necesita actualizar ese valor, evitando recrear todo el recurso.


  * ¿Qué diferencia hay entre modificar el JSON vs. parchear directamente el recurso?

      Cuando modificamos network.tf.json los cambios que hagamos se realizarán también en todos los entornos que depende de el, esto lo podemos apreciar volviendo a ejecutar generate_envs.py y observando como los cambios se aplicaron en los entornos que dependen del json. Además nos brinda una mejor trazabilidad, versionamiento y reproducibilidad. En cambio parchear directamente el recurso, el cambio solo se da en el entorno donde se está parcheando, esto crea una desviación(drift) respecto a la plantilla, entonces al regenerar los entornos desde la plantilla, el parche puede sobreescribirse y  además se pierde trazabilidad.

      
  * ¿Por qué Terraform no recrea todo el recurso, sino que aplica el cambio "in-place"?
  
      Terraform busca optimizar para hacer solo los cambios mínimos necesarios, ya que el recurso null_resource está diseñado específicamente para responder a cambios en sus triggers. Solo se está cambiando el atributo trigger.network y no la estructura fundamental del recurso, por lo que se mantiene cualquier estado o dependencia del recurso intacto. Así en el plan solo aparece la actualización del campo triggers, en lugar de destruir y recrear todo.


  * ¿Qué pasa si editas directamente `main.tf.json` en lugar de la plantilla de variables?

      Si editamos directamente main.tf.json de modules/simulated_app/ tendríamos que modificar cada aparición de una variable de la plantilla de variables (por ejemplo var.name), esto estaría propenso a errores como nombrar distinto a la misma variable, además obteniendo un bajo retorno de inversión ROI temporal, debido a que tendríamos que modificar directamente cada aparición de esta variable en el main.tf.json.

      En el otro caso, si editamos directamente main.tf.json de alguno de los entornos creados por generate_envs.py: Introducimos la desincronización, por lo que rompemos la idempotencia del script al no tener entornos uniformes. También, destruimos el determinismo del sistema: no podremos garantizar que después de “terraform apply” se genere el mismo estado que en los otros entornos. También perdemos la trazabilidad de las modificaciones.

#### Procedimiento

1. En `modules/simulated_app/network.tf.json`, cambia:

   ```diff
     "network": [
       {
   -     "default": "net1",
   +     "default": "lab-net",
         "description": "Nombre de la red local"
       }
     ]
   ```

   ```terraform
   (venv) diegodev@HPavilion:~/Desktop/Computer-Science/ds-practice/Actividad13-CC3S2/environments/app1$ cat network.tf.json 
   {
      "variable": [
         {
               "name": [
                  {
                     "type": "string",
                     "default": "hello-world",
                     "description": "Nombre del servidor local"
                  }
               ]
         },
         {
               "network": [
                  {
                     "type": "string",
                     "default": "lab-net",
                     "description": "Nombre de la red local"
                  }
               ]
         }
      ]
   ```

2. Regenera **solo** el app1:

   ```bash
   python generate_envs.py
   cd environments/app1
   terraform plan
   ```

   ```terraform
   (venv) diegodev@HPavilion:~/Desktop/Computer-Science/ds-practice/Actividad13-CC3S2/environments/app1$ terraform plan
   null_resource.app1: Refreshing state... [id=2815780140718114779]

   Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
   -/+ destroy and then create replacement

   Terraform will perform the following actions:

   # null_resource.app1 must be replaced
   -/+ resource "null_resource" "app1" {
         ~ id       = "2815780140718114779" -> (known after apply)
         ~ triggers = { # forces replacement
            ~ "network" = "local-network" -> "lab-net"
               # (1 unchanged element hidden)
         }
      }

   Plan: 1 to add, 0 to change, 1 to destroy.
   ```

   Observa que el **plan** indica:

   > \~ null\_resource.app1: triggers.network: "net1" -> "lab-net"

#### Fase 2: Entendiendo la inmutabilidad
Para simular un `drift` modificaremos el estado real de nuestra infraestructura en el archivo `terraform.tfstate` de manera directa (out-of-band changes) esto generara una desviacion del estado deseado que fue definido en nuestros archivos de configuracion
de terraform.
 
#### A. Remediación de 'drift' (out-of-band changes)

1. **Simulación**

   ```bash
   cd environments/app2
   # edita manualmente terraform.tfstate: cambiar "name":"hello-world" ->"hacked-app"
   ```
```terraform
{
  "version": 4,
  "terraform_version": "1.12.1",
  "serial": 4,
  "lineage": "ee537465-8634-cec9-cf29-afd33f8e4eb3",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "null_resource",
      "name": "app2",
      "provider": "provider[\"registry.terraform.io/hashicorp/null\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "id": "6820114600451844981",
            "triggers": {
              "name": "hacked-app",
              "network": "local-network"
            }
          },
          "sensitive_attributes": [],
          "identity_schema_version": 0
        }
      ]
    }
  ],
  "check_results": null
}
```


2. Ejecuta:

   ```bash
   terraform plan
   ```

    Verás un plan que propone **revertir** ese cambio.
    
```terraform
(venv) diegodev@HPavilion:~/Desktop/Computer-Science/ds-practice/Actividad13-CC3S2/environments/app2$ terraform apply
null_resource.app2: Refreshing state... [id=7967616035934440214]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # null_resource.app2 must be replaced
-/+ resource "null_resource" "app2" {
      ~ id       = "7967616035934440214" -> (known after apply)
      ~ triggers = { # forces replacement
          ~ "name"    = "hacked-app" -> "hello-world"
            # (1 unchanged element hidden)
        }
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

3. **Aplica**

   ```bash
   terraform apply
   ```
    
```terraform
{
  "version": 4,
  "terraform_version": "1.12.1",
  "serial": 4,
  "lineage": "ee537465-8634-cec9-cf29-afd33f8e4eb3",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "null_resource",
      "name": "app2",
      "provider": "provider[\"registry.terraform.io/hashicorp/null\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "id": "6820114600451844981",
            "triggers": {
              "name": "hello-world",
              "network": "local-network"
            }
          },
          "sensitive_attributes": [],
          "identity_schema_version": 0
        }
      ]
    }
  ],
  "check_results": null
}
```
Podemos verificar que vuelve a "hello-world".

  

#### B. Migrando a IaC

  
*  **Mini-reto**

1. Crea en un nuevo directorio `legacy/` un simple `run.sh` + `config.cfg` con parámetros (p.ej. puerto, ruta).

  

```

echo 'PORT=8080' > legacy/config.cfg

echo '#!/bin/bash' > legacy/run.sh

echo 'echo "Arrancando $PORT"' >> legacy/run.sh

chmod +x legacy/run.sh

```

2. Escribe un script Python que:

* Lea `config.cfg` y `run.sh`.

* Genere **automáticamente** un par `network.tf.json` + `main.tf.json` equivalente.

Para ello creamos el script python `legacy_to_tf.py` y lo ejecutamos.
```terraform
(venv) diegodev@HPavilion:~/Desktop/Computer-Science/ds-practice/Actividad13-CC3S2$ python3 legacy_to_tf.py 
==> terraform init
Initializing the backend...
Initializing provider plugins...
- Finding latest version of hashicorp/null...
- Installing hashicorp/null v3.2.4...
- Installed hashicorp/null v3.2.4 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

==> terraform plan

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # null_resource.legacy-server will be created
  + resource "null_resource" "legacy-server" {
      + id       = (known after apply)
      + triggers = {
          + "port" = "8080"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take
exactly these actions if you run "terraform apply" now.

Configuracion terraform generada en 'legacy/tf_env/'

```
Podemos observar con terraform plan que el resultado es igual al script legacy y ademas se genero la carpeta `legacy/tf_env/` que contiene `network.tf.json` + `main.tf.json` 

#### Fase 3: Escribiendo código limpio en IaC 

| Conceptos                       | Ejercicio rápido                                                                                               |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------------- |
| **Control de versiones comunica contexto** | - Haz 2 commits: uno que cambie `default` de `name`; otro que cambie `description`. Revisar mensajes claros. |
| **Linting y formateo**                     | - Instala `jq`. Ejecutar `jq . network.tf.json > tmp && mv tmp network.tf.json`. ¿Qué cambió?                 |
| **Nomenclatura de recursos**               | - Renombra en `main.tf.json` el recurso `null_resource` a `local_server`. Ajustar generador Python.           |
| **Variables y constantes**                 | - Añade variable `port` en `network.tf.json` y usarla en el `command`. Regenerar entorno.                     |
| **Parametrizar dependencias**              | - Genera `env3` de modo que su `network` dependa de `env2` (p.ej. `net2-peered`). Implementarlo en Python.    |
| **Mantener en secreto**                    | - Marca `api_key` como **sensitive** en el JSON y leerla desde `os.environ`, sin volcarla en disco.           |

#### Fase 4: Integración final y discusión

1. **Recorrido** por:

   * Detección de drift (*remediation*).
   * Migración de legacy.
   * Estructura limpia, módulos, variables sensibles.
2. **Preguntas abiertas**:

   * ¿Cómo extenderías este patrón para 50 módulos y 100 entornos?

      Implementaría un sistema jerárquico donde cada módulo tenga su propio directorio en `modules/` con sus respectivos `network.tf.json` y `main.tf.json`. El script `generate_envs.py` se modificaría para recibir configuración desde un archivo YAML o JSON centralizado que mapee qué módulos usa cada entorno. Usaría herencia de configuraciones con variables comunes a nivel global y específicas por módulo y organizaría los entornos de esta forma (dev/staging/prod) en subdirectorios. También agregaría validación automática con `terraform validate`.

   * ¿Qué prácticas de revisión de código aplicarías a los `.tf.json`?

      Aplicaría validación automática con `jq` para verificar sintaxis JSON correcta antes de commits, uso de `terraform fmt -check` en CI/CD para asegurar formato consistente, y pruebas con `terraform validate` para detectar referencias inválidas. Implementaría pre-commit hooks que ejecuten estos linters automáticamente. En code reviews, verificaría que los cambios en `modules/` sean intencionales ya que afectan todos los entornos, que las variables tengan descripciones claras, y que no se hardcodeen valores sensibles.

   * ¿Cómo gestionarías secretos en producción (sin Vault)?

      Bueno los gestionaría mediante variables de entorno del sistema operativo, marcándolas como `sensitive = true` en `network.tf.json` para que Terraform no las imprima en logs. Para múltiples entornos, usaría archivos `.env` por entorno que se cargan automáticamente al ejecutar el generador. En CI/CD, los secretos se inyectarían como variables de entorno encriptadas del propio sistema de CI.

   * ¿Qué workflows de revisión aplicarías a los JSON generados?

      Implementaría un workflow donde primero se revisa el cambio en la plantilla base (`modules/`), luego se ejecuta `generate_envs.py` en una rama de feature, y se valida con `terraform plan` en al menos 2-3 entornos representativos antes del merge. Usaría GitHub Actions para automatizar la generación y validación en cada PR, mostrando el diff de archivos generados como comentario en el PR. No commitearía directamente los archivos en `environments/` sino que los generaría on-demand o en deployment time. Si se commitean, usaría `.gitattributes` para marcarlos como generados automáticamente, y el review se enfocaría en verificar consistencia entre todos los entornos.