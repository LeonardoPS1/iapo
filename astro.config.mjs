// @ts-check
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://iapo.cl',
  output: 'static',
  integrations: [
    sitemap({
      lastmod: new Date(),
      changefreq: 'weekly',
      priority: 0.7,
      // Note: @astrojs/sitemap automatically uses `lastmod` from frontmatter if present
      // For blog posts, it reads `pubDate` or `lastmod` from the collection entry
      filter: (page) => !page.includes('/suscribir') && !page.includes('/search'),
    }),
  ],
});
