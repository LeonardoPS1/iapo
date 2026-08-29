const fs = require('fs');
const html = fs.readFileSync('dist/blog/n8n-ollama-flujo-calificacion-leads/index.html', 'utf8');
const regex = /<script type="application\/ld\+json">([\s\S]*?)<\/script>/g;
let match;
while ((match = regex.exec(html)) !== null) {
  console.log('--- JSON-LD ---');
  console.log(match[1]);
}