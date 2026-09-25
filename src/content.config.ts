import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const blog = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/blog' }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    pilar: z.enum(['salud', 'automatizacion', 'ia-general']),
    tags: z.array(z.string()).default([]),
    draft: z.boolean().default(false),
  }),
});

const rankingItem = z.object({
  rank: z.number(),
  name: z.string(),
  url: z.string().url(),
  metricNumber: z.number(),
  metricDisplay: z.string(),
  language: z.string().optional(),
  origin: z.string().optional(),
  description: z.string(),
  why: z.string(),
});

const rankings = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/rankings' }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    snapshotDate: z.coerce.date(),
    edition: z.number(),
    draft: z.boolean().default(false),
    lists: z.array(
      z.object({
        kind: z.enum(['repos', 'skills', 'mcp']),
        label: z.string(),
        window: z.string(),
        source: z.string().url(),
        items: z.array(rankingItem),
      })
    ),
    method: z.object({
      windows: z.array(z.string()),
      warnings: z.array(z.string()),
      sources: z.array(
        z.object({ label: z.string(), url: z.string().url() })
      ),
    }),
  }),
});

export const collections = { blog, rankings };
