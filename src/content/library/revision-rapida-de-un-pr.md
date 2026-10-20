---
kind: prompt
title: Revisión rápida de un PR antes de aprobar
description: Pasa un diff por el filtro de bugs reales, no de estilo, antes de dar el visto bueno.
pilar: ia-general
order: 6
---

Revisá este diff como si fueras a aprobarlo y algo se te fuera a romper en
producción.

Diff:
{{diff}}

Respondé con esta estructura y nada más:

RIESGO — alto, medio o bajo, en una línea
BUGS — comportamiento incorrecto concreto, con archivo y línea
SUPUESTOS — qué asume este código sobre datos externos que no está validando
PRUEBAS FALTANTES — qué caso no está cubierto

No comentes nombres, formato ni preferencias de estilo: eso lo resuelve el
linter. Si no encontrás bugs, decilo en una línea y no inventes hallazgos para
llenar la respuesta.
