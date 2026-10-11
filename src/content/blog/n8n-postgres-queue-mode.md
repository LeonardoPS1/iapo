---
title: "n8n en producción: de SQLite a PostgreSQL con workers"
description: "Por qué n8n sigue usando SQLite aunque configures Postgres, y qué cambiar para que realmente escale con workers."
pubDate: 2026-09-18
pilar: "automatizacion"
tags: ["n8n", "postgresql", "docker", "self-hosted"]
draft: false
---

n8n arranca con SQLite por defecto. Para probar flujos está bien; para producción —con varios flujos corriendo en paralelo, webhooks entrantes y ejecuciones largas— conviene PostgreSQL y un modo de ejecución con workers. El problema es que migrar tiene una trampa que nos tomó un rato encontrar.

## La trampa: configurar Postgres no basta

Puedes definir host, usuario y contraseña de Postgres en las variables de entorno y n8n seguirá usando SQLite sin avisarte. El motor de base de datos solo cambia si defines explícitamente:

```
DB_TYPE=postgresdb
```

Junto con el resto de las variables `DB_POSTGRESDB_*` (host, puerto, base de datos, usuario, contraseña). Sin `DB_TYPE`, las demás se ignoran y todo sigue escribiéndose en el archivo SQLite local, lo que se nota recién cuando intentas escalar o cuando revisas la base y está vacía.

## Modo queue: main, workers y Redis

Con Postgres funcionando, el siguiente paso es separar la instancia principal (editor y webhooks) de los workers que ejecutan los flujos:

- `EXECUTIONS_MODE=queue` en todas las instancias.
- Redis como cola de trabajos (`QUEUE_BULL_REDIS_HOST` y variables asociadas).
- Uno o más workers, que levantan con el mismo contenedor pero arrancando en modo worker.

Un detalle crítico: **todas las instancias deben compartir el mismo `N8N_ENCRYPTION_KEY`**. Si el worker tiene una clave distinta a la instancia principal, no puede descifrar las credenciales guardadas y los flujos fallan al ejecutarse aunque en el editor se vean correctos.

## Cómo verificar que quedó bien

- Revisa que las tablas de n8n existan en Postgres (no solo la conexión).
- Ejecuta un flujo manualmente y confirma en los logs que lo tomó un worker, no la instancia principal.
- Reinicia el contenedor principal y comprueba que flujos y credenciales siguen ahí.

---

*¿Corriendo n8n self-hosted? [Súbete a la newsletter](/#suscribir) para más notas técnicas como esta.*