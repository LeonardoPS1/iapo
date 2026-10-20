---
kind: prompt
title: Extraer datos de un mensaje libre a JSON
description: Convierte texto desprolijo de un formulario o chat en un objeto parseable, sin inventar campos.
pilar: automatizacion
order: 8
---

Extraé los datos de este mensaje y devolvé JSON válido. Nada más que el JSON.

Mensaje:
{{mensaje}}

Esquema de salida:
{
  "nombre": string | null,
  "telefono": string | null,
  "email": string | null,
  "servicio": string | null,
  "fecha_preferida": string | null,
  "notas": string | null
}

Reglas: si un campo no aparece en el mensaje, poné null, nunca una cadena vacía.
Normalizá el teléfono a solo dígitos con código de país. No corrijas nombres ni
completes servicios que no se mencionan. No agregues campos que no estén en el
esquema ni texto fuera del objeto JSON.
