# Medición de iapo.cl — diseño

**Fecha:** 2026-09-26
**Estado:** implementado
**Decisión:** Cloudflare Web Analytics + Google Search Console

## Por qué estas dos

iapo.cl es un sitio estático (Astro, `output: 'static'`) detrás de Cloudflare
(`iapo.cl` resuelve a rangos de edge). Eso hace que Cloudflare Web Analytics sea
la opción de menor costo posible: se inyecta en el edge, no requiere una línea
de código, no agrega dependencias al bundle y es cookieless.

Alternativas consideradas:

| Opción | Por qué no |
|---|---|
| Plausible | €9/mes, y requiere proxy o script propio |
| Umami self-hosteado | Infra nueva que mantener, y hay que agregar el script al repo |
| GA4 | Requiere banner de consentimiento en Chile; agrega ~45 kB |

Si Cloudflare se queda corto, Umami self-hosteado es el siguiente escalón
natural: da Goals reales y no depende de que el sitio siga proxeado.

## Consentimiento: sin banner

La Ley 19.628 exige consentimiento para tratar datos personales. La analítica de
Cloudflare es agregada, no guarda la IP y no crea identificador persistente, así
que se activa sin banner de consentimiento.

La contrapartida es que `/privacidad` tenía que dejar de prometer lo contrario.
Decía textualmente que el sitio "no utiliza cookies de seguimiento ni servicios
de analítica", y en Seguridad que "no almacena datos personales en servidores
propios". Eso es una declaración legal, no texto decorativo: mientras siga
así, medir sin consentir sería una declaración falsa, no un detalle de redacción.

## Fase 1 — Search Console

Sin código. Es la única fuente de datos de terceros (Google) que nos envía nada.

1. Crear la propiedad de tipo **dominio** para `iapo.cl`.
2. Copiar el registro TXT y pegarlo en DNS de Cloudflare.
3. Enviar `https://iapo.cl/sitemap-index.xml`.

Aporta: páginas indexadas, consultas de búsqueda, CTR, posición media.

## Fase 2 — Cloudflare Web Analytics

Sin código. Se activa desde el panel (Web Analytics → Setup) y el beacon se
inyecta en el edge. No requiere deploy.

Aporta: páginas vistas, visitantes, referrer, país, dispositivo.

### Aviso importante

Cloudflare no tiene Goals. El panel **no** va a reportar "N suscripciones al
boletín". Ese número vive en Brevo. Cruzar ambos a mano es la fricción real de
esta opción, y es lo que justifica considerar Umami más adelante.

## Fase 3 — Atribución del boletín

Cloudflare no sabe quién se suscribió. Para eso hay que instrumentar el paso de
las otras dos piezas.

El formulario de Brevo vive en un iframe en `src/pages/index.astro`, dentro de
`<section id="suscribir">`. Brevo expone un parámetro `ref` que se mapea a un
atributo del contacto si se crea el campo oculto y se marca como parámetro de
query en Brevo.

Solo hay dos CTAs de suscripción en todo el sitio:

| Ubicación | Qué hizo |
|---|---|
| `src/layouts/Ranking.astro:150` | `/#suscribir` → `/#suscribir?ref=${Astro.url.pathname}` |
| `src/pages/index.astro:81` | Sin cambios. Es un ancla, y un cambio de fragmento conserva el query string, así que el `ref` llega solo |

El script (`initSubscribeRef`, en el `<script>` de `index.astro`) resuelve el
valor con esta precedencia:

1. `?ref=` de la URL, si está.
2. El `pathname` del `document.referrer`, si el hostname es `iapo.cl` o
   termina en `.iapo.cl`.
3. `directo`.

Se engancha al listener de `astro:page-load` que ya existía (junto a
`initIndex`), para re-ejecutarse en cada navegación SPA. Un flag
`data-ref-applied` evita reescribir el `src` dos veces sobre el mismo elemento.

## Fase 4 — Medir el contenido automático

Los rankings los genera el agente semanal (`.opencode/agent/weekly-ranking.md`).
Cada edición es una página nueva con URL nueva, así que en Search Console se
ven como páginas nuevas. Con las fases 1 y 2 se puede seguir el tráfico de
`/rankings/*` por separado del resto.

## Qué se cambió en el repo

| Archivo | Cambio |
|---|---|
| `src/pages/privacidad.astro` | Declara la analítica agregada, nombra a Cloudflare como procesador, corrige la sección de Seguridad, actualiza la fecha |
| `src/layouts/Ranking.astro` | El CTA lleva `?ref=` con el pathname |
| `src/pages/index.astro` | `data-subscribe-embed` en el iframe + `initSubscribeRef()` |

`aviso-legal.astro` y `terminos.astro` no se tocaron: ya dicen genéricamente que
el sitio "enlaza a servicios y sitios de terceros", lo que cubre a Cloudflare y
a Brevo.

## Qué hace falta fuera del repo

- Crear en Brevo el campo oculto `ref` mapeado al query param del formulario.
- Activar Web Analytics en el panel de Cloudflare.
- Verificar la propiedad en Search Console.

## Riesgos y límites

- **El `ref` viaja en la URL.** Si alguien comparte `iapo.cl/?ref=/rankings/...`
  en redes, el dato se infla. Para el volumen de este sitio es aceptable.
- **El beacon depende del edge.** Si el sitio dejara de servirse por Cloudflare,
  las métricas dejan de llegar sin ningún aviso.
- **Sin Goals en Cloudflare.** Ver la Fase 2.
- **El blog no tiene CTA al boletín.** Solo la home y los rankings llevan a
  suscribirse, así que el tráfico del blog al boletín no es medible hoy. Es
  trabajo de producto, fuera de este diseño.
