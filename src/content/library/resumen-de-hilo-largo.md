---
kind: prompt
title: Resumen de hilo largo en decisiones y pendientes
description: Convierte una conversación extensa en las decisiones tomadas y lo que quedó sin resolver.
pilar: ia-general
order: 5
---

Te paso una conversación larga. Quiero saber qué se decidió y qué quedó
abierto, sin volver a leer todo.

Conversación:
{{hilo}}

Devolvé exactamente dos listas:

DECISIONES — una línea por decisión, con quién la tomó si se menciona
PENDIENTES — una línea por tema abierto, con quién quedó a cargo si se menciona

Reglas: si algo se propuso pero nadie confirmó, va en PENDIENTES. Si una decisión
se revisó después, conservá solo la versión final. No agregues opiniones ni
recomendaciones, y no inventes responsables que no aparezcan en el texto.
