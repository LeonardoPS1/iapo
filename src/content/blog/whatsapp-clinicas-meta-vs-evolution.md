---
title: "Cómo automatizamos WhatsApp para clínicas: Meta Cloud API vs. Evolution API"
description: "La diferencia real entre ambas opciones cuando el WhatsApp de tu negocio no puede darse el lujo de un baneo."
pubDate: 2026-08-14
pilar: "automatizacion"
tags: ["whatsapp", "n8n", "clinicas", "automatizacion"]
---

Si estás automatizando WhatsApp para un negocio real —no un prototipo—, en algún momento te vas a topar con esta decisión: **Meta Cloud API** (la API oficial de Meta) o **Evolution API** (un gateway no oficial, basado en Baileys, que simula un cliente de WhatsApp Web).

La respuesta corta: usa Evolution API en desarrollo, y migra a Meta Cloud API antes de tocar producción con clientes reales. Acá el porqué.

## El problema de fondo

Evolution API no habla con la API oficial de WhatsApp. Simula ser un WhatsApp Web más, usando la librería Baileys para conectarse por el protocolo interno de la app. Eso significa:

- **Riesgo de ban permanente.** Meta detecta patrones de automatización y puede banear el número sin aviso ni apelación real. Para un negocio que depende de ese número para agendar pacientes, es un riesgo que no vale la pena correr en producción.
- **Sin garantías de disponibilidad.** Al no ser una integración oficial, cualquier cambio en el protocolo interno de WhatsApp puede romper la conexión de un día para otro.

A cambio, Evolution API tiene una ventaja enorme en fase de desarrollo: **cero fricción de setup**. No necesitas verificación de negocio en Meta Business Manager, no esperas aprobación de plantillas de mensajes, y puedes tener un flujo de prueba corriendo en minutos. Por eso la seguimos usando en ambientes de desarrollo.

## Por qué Meta Cloud API para producción

Meta Cloud API es la API oficial. El trade-off es el inverso: más fricción de setup (verificación de negocio, revisión de plantillas para mensajes fuera de la ventana de 24 horas), pero:

- El número no corre riesgo de ban por uso automatizado, porque es el uso *previsto* de la API.
- Tienes SLA real y soporte oficial.
- Es el camino obligado si vas a escalar a más de un número o cliente — que es exactamente donde estamos con la migración a multi-tenant.

## Cómo lo estructuramos

En nuestro flujo, el bot de calificación de leads corre sobre **n8n + Ollama**, distinto del bot operativo interno de gestión de citas. Esto separa dos responsabilidades que conviene no mezclar:

1. **Bot de calificación** (cara al paciente final): recibe el primer contacto, hace preguntas de triage, deriva a agendamiento. Este es el que va sobre Meta Cloud API porque es tráfico de clientes reales, sin margen para un ban.
2. **Bot operativo interno**: notificaciones, recordatorios, tareas internas del equipo. Acá el riesgo de un corte temporal es mucho más tolerable, así que sigue corriendo sobre Evolution API en desarrollo.

## La lección práctica

Si estás evaluando esto para tu propio proyecto, la pregunta que realmente importa no es "¿cuál API es mejor?" sino **"¿qué pasa el día que se cae?"**. Si la respuesta es "pierdo la única vía de contacto de mis pacientes", no hay vuelta: vas con la API oficial, aunque el setup sea más lento.

---

*¿Estás evaluando automatizar WhatsApp para tu clínica o negocio? En [Aicore Agency](/sobre) construimos justamente esto — revisa [los casos de estudio](/casos) o [súbete a la newsletter](/#suscribir) para los próximos artículos técnicos.*
