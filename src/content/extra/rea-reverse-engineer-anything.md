---
title: "REA, el repositorio que enseña a la IA a desarmar cualquier app y tiene a GitHub en llamas"
headline: "240.000 estrellas en días: la IA aprendió a desarmar apps"
intro: "REA, un proyecto open source que conecta agentes de IA con herramientas de ingeniería inversa, es el repo del momento. ¿Qué hace de verdad y por qué tiene a medio mundo discutiendo sobre copyright?"
description: "Qué es REA (Reverse Engineer Anything), por qué explotó en GitHub, qué dicen Hacker News, Reddit y YouTube, y qué significa para el futuro del software."
pubDate: 2026-10-14
featured: true
draft: false
sources:
  - label: "Repositorio oficial: morluto/rea (GitHub)"
    url: "https://github.com/morluto/rea"
  - label: "Sitio oficial: rea.tools"
    url: "https://rea.tools"
  - label: "Paquete npm: rea-agents"
    url: "https://www.npmjs.com/package/rea-agents"
  - label: "OneDigital: REA permite ingeniería inversa de apps y binarios con agentes de IA vía MCP"
    url: "https://onedigital.mx/2026/10/14/rea-ingenieria-inversa-agentes-ia-mcp/"
  - label: "ChainCatcher / KuCoin News: REA supera las 100 mil estrellas en una semana"
    url: "https://www.kucoin.com/es/news/flash/open-source-ai-reverse-engineering-tool-rea-surpasses-100k-github-stars-in-a-week"
  - label: "KuCoin News: controversias legales y técnicas de REA"
    url: "https://www.kucoin.com/news/flash/ai-reverse-engineering-tool-rea-surges-by-100-000-stars-in-a-week-sparking-legal-and-technical-controversies"
  - label: "Hacker News: hilo «REA Reverse – Engineer Anything»"
    url: "https://news.ycombinator.com/item?id=50028275"
  - label: "Hacker News: Ask HN sobre el repo REA"
    url: "https://news.ycombinator.com/item?id=50034003"
  - label: "DEV Community: «AI Cloned Your App Overnight. Now What?»"
    url: "https://dev.to/max_quimby/ai-cloned-your-app-overnight-now-what-3i4p"
  - label: "Medium: «Reverse Engineer Anything Went Viral»"
    url: "https://medium.com/@info.booststash/reverse-engineer-anything-went-viral-the-calendly-clone-demos-are-a-different-trick-dc9511769f5e"
  - label: "Kingy.ai: ¿Puede la ingeniería inversa con IA reemplazar a Adobe?"
    url: "https://kingy.ai/blog/ai-reverse-engineering-artcraft-adobe/"
  - label: "Redreamality: REA, PhotoCraft, chardet y Malus lado a lado"
    url: "https://redreamality.com/blog/ai-reverse-engineering-clean-room-rewrite-licensing"
  - label: "YouTube: «Probé el repo viral de GitHub que hace ingeniería inversa de cualquier app»"
    url: "https://www.youtube.com/watch?v=LivJcQQ1RpY"
---

**EXTRA.** En una sola semana, un repositorio casi desconocido pasó de [menos de 10 mil estrellas el 6 de octubre a más de 100 mil el 12](https://www.kucoin.com/es/news/flash/open-source-ai-reverse-engineering-tool-rea-surpasses-100k-github-stars-in-a-week), según el reporte de ChainCatcher. Hoy [supera las 240 mil estrellas y los 59 mil forks](https://github.com/morluto/rea). Se llama **REA**, por *Reverse Engineer Anything*, y su idea es tan simple como incómoda: que un agente de IA pueda abrir una app por dentro, entender cómo funciona una función y explicártelo con evidencia.

## ¿Qué es REA, exactamente?

REA es un servidor MCP —el protocolo que permite a los agentes de IA usar herramientas externas— publicado con licencia MIT por el desarrollador morluto. Conecta agentes como Claude Code, Codex, Cursor o Gemini CLI con herramientas de análisis que ya existían (Hopper, Ghidra, IDA, JADX) y las usa para inspeccionar binarios nativos, apps JavaScript y Electron, ensamblados .NET, APKs de Android, sitios web y hasta firmware. Según su [README](https://github.com/morluto/rea), el análisis corre en local y cada conclusión llega con la evidencia y las limitaciones que la respaldan.

Ojo con el titular fácil: REA no es un botón mágico de «clonar app». Un [análisis publicado en Medium](https://medium.com/@info.booststash/reverse-engineer-anything-went-viral-the-calendly-clone-demos-are-a-different-trick-dc9511769f5e) lo describe como un arnés de descompilación, no como un clonador de apps en un solo prompt. El agente hace las preguntas, REA reúne la evidencia y recién ahí el agente puede explicar o reimplementar una función.

Instalarlo es un solo comando, según el README oficial: `npx rea-agents setup`.

## La promesa que lo encendió

El README invita a algo muy concreto: ves una función que te gusta en una app, le pides a tu agente que la investigue con REA, te la explica con evidencia y hasta puede construir una versión para tu propio proyecto. Los casos de estudio oficiales son técnicos y modestos: reconstruir el cálculo de paneo de sonido del clásico DX-Ball (validado contra 3.205 casos del código original), seguir el puente del portapapeles de Notion en Electron y recuperar el cálculo del anillo de balas de TH04, un juego de PC-98. Los tienes en [rea.tools](https://rea.tools).

## Cómo pasó de desconocido a fenómeno

- **Nació en abril**, pero estuvo meses casi sin atención, según [ChainCatcher](https://www.kucoin.com/es/news/flash/open-source-ai-reverse-engineering-tool-rea-surpasses-100k-github-stars-in-a-week).
- **11 y 13 de octubre:** el 11 sumó más de 30 mil estrellas en un solo día, y el 13 sumó [45.327 más hasta llegar a 161.865](https://redreamality.com/blog/ai-reverse-engineering-clean-room-rewrite-licensing).
- **8 de octubre:** el creador de contenido Matthew Berman sentenció en X que el software ya estaba «terminado» y enlazó el repo, según [Kingy.ai](https://kingy.ai/blog/ai-reverse-engineering-artcraft-adobe/). Ese mismo análisis aclara que no hay evidencia de que REA se haya usado para construir ArtCraft, los clones open source de apps de Adobe que aparecieron en la misma ola de noticias.
- **Hacker News:** el [hilo principal](https://news.ycombinator.com/item?id=50028275) rondó los 800 puntos y superó los 300 comentarios.
- **YouTube:** ya hay videos de prueba, como [este en español](https://www.youtube.com/watch?v=LivJcQQ1RpY) donde un creador lo pone a trabajar.
- **Reddit:** los hilos mezclan entusiasmo con dudas sobre qué hace realmente la herramienta, según el mismo análisis de Kingy.ai.

## Lo que dice la comunidad

**Los entusiastas** ven una barrera que cae. Un artículo en [DEV Community](https://dev.to/max_quimby/ai-cloned-your-app-overnight-now-what-3i4p) sostiene que el escudo de «es demasiado difícil de reconstruir» se acaba de romper, y menciona que Thales lanzó un producto pensado para defender software contra la ingeniería inversa asistida por IA.

**Los cautos** miran el lado legal. En Hacker News hay comentaristas que ven a REA como excelente para apps personales y software abandonado, pero advierten que publicar resultados derivados de código propietario descompilado puede terminar mal. Según [KuCoin News](https://www.kucoin.com/news/flash/ai-reverse-engineering-tool-rea-surges-by-100-000-stars-in-a-week-sparking-legal-and-technical-controversies), algunos llaman a esta práctica «lavado de propiedad intelectual», y un proyecto que replica apps de Adobe prohibió a su equipo usar Ghidra y REA por miedo a demandas.

**Los irónicos** también tuvieron su momento: en un [Ask HN](https://news.ycombinator.com/item?id=50034003) alguien respondió con sarcasmo proponiendo «liberar» el software propietario de las grandes empresas, ya que según el argumento viral el software «vale cero».

## La zona gris legal

REA es open source y legal; lo que se haga con él es otra conversación. Su propio disclaimer lo plantea para investigación lícita, educación, interoperabilidad, preservación de software y análisis de software propio o con autorización. Los análisis consultados señalan los riesgos habituales: cláusulas de licencia que prohíben descompilar, secretos comerciales y las interfaces que copian demasiado a otro producto.

El análisis de Medium sugiere un camino más seguro: en vez de «clonar Calendly», escribir qué tres cosas necesitas de Calendly, porque así describes funciones en lugar de copiar pantallas. Y según KuCoin, el derecho de autor protege cómo está escrito el código, no la funcionalidad en sí. Nada de esto es asesoría legal.

## ¿Y ahora qué?

Si compilar u ofuscar deja de ser una barrera confiable, la discusión se mueve hacia lo que no se puede leer en un binario: los datos, el servicio, la confianza, la integración, el soporte y la velocidad para mejorar el producto. Otros análisis bajan el tono: para la mayoría de quienes ven los tutoriales virales de «clonar» apps conocidas, REA ni siquiera es la herramienta relevante.

## La pregunta del millón

Si cualquier función visible puede ser entendida y reconstruida por un agente en cuestión de minutos, ¿qué protege realmente a un software?

**¿Estamos ante el fin del software como lo conocemos, o solo ante el fin de las excusas para no mejorarlo?** Cuéntanos qué piensas en los comentarios.

---

*Nota informativa. Cifras de GitHub al 14 de octubre de 2026; pueden cambiar. No constituye asesoría legal.*
