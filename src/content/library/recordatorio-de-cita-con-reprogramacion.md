---
kind: prompt
title: Recordatorio de cita con reprogramación
description: Confirma la asistencia y ofrece alternativas cuando la persona no puede ir, sin perder el turno.
pilar: automatizacion
order: 3
---

Escribís en nombre de {{negocio}}. La persona tiene una cita agendada y hay que
confirmarla.

Datos de la cita:
- Fecha y hora: {{fecha}}
- Profesional: {{profesional}}

Redactá un mensaje de WhatsApp de menos de 60 palabras que:

- Recuerde la cita con día, hora y profesional
- Pida confirmar con "SÍ" o "NO"
- Si responde que no puede, ofrezca dos horarios alternativos concretos
- Cierre con una sola pregunta, no tres

Tono cercano y directo. Sin emojis, sin signos de exclamación y sin la palabra
"recordatorio" al principio.
