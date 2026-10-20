import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const pilar = z.enum(['salud', 'automatizacion', 'ia-general']);

const blog = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/blog' }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    pilar,
    tags: z.array(z.string()).default([]),
    draft: z.boolean().default(false),
  }),
});

const extra = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/extra' }),
  schema: z.object({
    title: z.string(),
    headline: z.string(),
    intro: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    featured: z.boolean().default(false),
    sources: z
      .array(z.object({ label: z.string(), url: z.string().url() }))
      .default([]),
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
      sources: z.array(z.object({ label: z.string(), url: z.string().url() })),
    }),
  }),
});

/**
 * Curated library: prompts, repos and cases share one collection so the schema
 * and the loader live in one place. Each page filters by `kind`.
 */
const library = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/library' }),
  schema: z.object({
    kind: z.enum(['prompt', 'repo', 'caso']),
    title: z.string(),
    description: z.string(),
    /** Ordering hint; defaults to 0 so new items land at the end. */
    order: z.number().default(0),
    draft: z.boolean().default(false),
    /** prompt */
    pilar: pilar.optional(),
    text: z.string().optional(),
    /** repo */
    repo: z.string().optional(),
    url: z.string().url().optional(),
    /** caso */
    clinic: z.string().optional(),
    result: z.string().optional(),
    pubDate: z.coerce.date().optional(),
  }),
});

export const collections = { blog, rankings, extra, library };
