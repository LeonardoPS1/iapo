---
title: "Repos de la semana #1: 3 herramientas que probamos este mes"
description: "LiteLLM, Open WebUI y Langfuse: para qué sirven y cuándo realmente las necesitas en un stack de IA self-hosted."
pubDate: 2026-08-21
pilar: "ia-general"
tags: ["repos", "self-hosted", "llm", "observabilidad"]
draft: false
---

Primera entrega de "Repos de la semana": herramientas que probamos con carga real este mes, no solo un `git clone` de fin de semana. Esta vez tres piezas que resuelven problemas distintos de un stack de IA self-hosted.

## LiteLLM — un proxy único para todos tus modelos

Si trabajas con más de un proveedor de modelos (OpenAI, Anthropic, modelos locales vía Ollama, OpenRouter), terminas escribiendo código distinto para cada API. LiteLLM expone una única interfaz compatible con el formato de OpenAI y traduce hacia atrás según el proveedor real detrás.

En la práctica, esto significa que puedes cambiar de modelo en producción editando una línea de configuración, no reescribiendo la integración. Útil especialmente si estás evaluando qué modelo conviene para cada tarea sin comprometerte a una sola API.

## Open WebUI — interfaz de chat para tus modelos locales

Si ya tienes Ollama corriendo en tu VPS, Open WebUI te da una interfaz de chat completa (parecida a ChatGPT) apuntando a esos modelos locales. La usamos para dar acceso interno al equipo a los modelos que corremos self-hosted, sin exponer una API cruda ni que cada persona tenga que usar la terminal.

Soporta múltiples usuarios, historial de conversaciones y RAG básico sobre documentos propios — suficiente para uso interno sin necesitar una plataforma completa.

## Langfuse — observabilidad para lo que construyes con LLMs

Cuando un flujo con IA falla en producción (un prompt que empieza a alucinar, una latencia que se dispara), necesitas ver qué pasó paso a paso — no solo el log genérico de la aplicación. Langfuse registra cada llamada a un modelo: el prompt exacto, la respuesta, latencia, costo y metadata de la sesión.

Es la diferencia entre "el bot respondió mal ayer" y poder ver exactamente qué prompt se envió, qué contexto tenía, y cuánto costó esa llamada específica.

---

*¿Usas alguna de estas o tienes otra que deberíamos probar? Cuéntanos — y si quieres más curaduría como esta, [súbete a la newsletter](/#suscribir).*