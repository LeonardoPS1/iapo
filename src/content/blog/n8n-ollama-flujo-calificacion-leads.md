---
title: "n8n + Ollama: el flujo de calificación de leads que usamos en producción"
description: "Cómo conectamos un webhook de WhatsApp con un modelo local para filtrar leads antes de que lleguen a un humano — y qué hacer cuando el modelo se equivoca."
pubDate: 2026-08-28
pilar: "automatizacion"
tags: ["n8n", "ollama", "whatsapp", "automatizacion"]
draft: false
---

Cuando un lead entra por WhatsApp, alguien tiene que decidir si es un paciente real preguntando por una hora, o alguien preguntando algo que no corresponde (spam, consultas fuera de horario, mensajes de proveedores). Automatizar ese primer filtro es uno de los flujos que más tiempo nos ahorra, y es más simple de lo que parece.

## La arquitectura

El flujo corre en n8n con cuatro pasos:

1. **Webhook**: recibe el mensaje entrante desde Evolution API (o Meta Cloud API, según el ambiente).
2. **Nodo IF**: filtra ruido obvio antes de gastar una llamada a un modelo — mensajes vacíos, duplicados, o de números ya bloqueados.
3. **Ollama LLM Chain**: clasifica el mensaje. Le pedimos al modelo que devuelva una categoría fija (`consulta_paciente`, `spam`, `otro`) más un motivo breve, nunca texto libre sin estructura.
4. **HTTP Request**: postea el resultado de vuelta a Evolution API o al sistema de gestión, dependiendo de la categoría.

## Por qué un modelo local para este paso específico

Para clasificación de intención —una tarea acotada y repetitiva— usamos Ollama con `llama3.1:8b` corriendo en el mismo VPS, no una API externa. Dos razones prácticas:

- **Costo**: este nodo se ejecuta en cada mensaje entrante. A volumen, una API de pago por token para una tarea de clasificación simple es gasto que no se justifica.
- **Latencia**: el modelo local responde dentro del mismo datacenter, sin el viaje de ida y vuelta a una API externa. Para un flujo que el paciente está esperando en tiempo real, esa diferencia se nota.

Esto no aplica a todo — para generación de texto más compleja (redactar una respuesta completa, resumir una ficha larga) sí preferimos un modelo más grande vía API. La regla que seguimos: tareas de clasificación acotada → modelo local; generación abierta → modelo más grande.

## Dónde falla, y qué hacemos al respecto

El modelo se equivoca en los bordes: un mensaje ambiguo a veces se clasifica como `otro` cuando era una consulta real. No tratamos de resolver esto ajustando el prompt hasta la perfección — en vez de eso, cualquier mensaje que caiga en `otro` pasa a una cola de revisión humana con un timeout de 15 minutos antes de descartarse. El modelo reduce el volumen que un humano tiene que mirar; no reemplaza la decisión final en los casos dudosos.

Esa cola de revisión es, en la práctica, lo que hace que el flujo sea confiable en producción y no solo una demo bonita.

---

*¿Estás armando algo parecido? En [Aicore Agency](/sobre) construimos justo este tipo de flujos — revisa [los casos de estudio](/casos) o [súbete a la newsletter](/#suscribir) para más detalles técnicos como este.*