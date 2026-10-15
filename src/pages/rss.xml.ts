import type { APIRoute } from 'astro';
import { getCollection } from 'astro:content';

const escapeXml = (value: string) =>
  value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');

export const GET: APIRoute = async ({ site }) => {
  const base = site ?? new URL('https://iapo.cl');

  const blog = (await getCollection('blog', ({ data }) => !data.draft)).map((entry) => ({
    title: entry.data.title,
    description: entry.data.description,
    pubDate: entry.data.pubDate,
    url: new URL(`/blog/${entry.id}/`, base).href,
  }));

  const extra = (await getCollection('extra', ({ data }) => !data.draft)).map((entry) => ({
    title: entry.data.title,
    description: entry.data.description,
    pubDate: entry.data.pubDate,
    url: new URL(`/extra/${entry.id}/`, base).href,
  }));

  const items = [...blog, ...extra].sort((a, b) => b.pubDate.getTime() - a.pubDate.getTime());
  const lastBuildDate = items[0]?.pubDate.toUTCString() ?? new Date().toUTCString();

  const body = `<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>iapo.cl</title>
    <link>${base.href}</link>
    <description>IA aplicada a lo que hacés todos los días. Menos hype, más iapo.</description>
    <language>es-cl</language>
    <lastBuildDate>${lastBuildDate}</lastBuildDate>
    <atom:link href="${new URL('/rss.xml', base).href}" rel="self" type="application/rss+xml" />
${items
  .map(
    (item) => `    <item>
      <title>${escapeXml(item.title)}</title>
      <link>${item.url}</link>
      <guid isPermaLink="true">${item.url}</guid>
      <pubDate>${item.pubDate.toUTCString()}</pubDate>
      <description>${escapeXml(item.description)}</description>
    </item>`
  )
  .join('\n')}
  </channel>
</rss>
`;

  return new Response(body, {
    headers: { 'Content-Type': 'application/xml; charset=utf-8' },
  });
};
