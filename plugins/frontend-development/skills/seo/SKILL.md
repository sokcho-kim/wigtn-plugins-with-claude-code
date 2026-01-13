---
name: seo
description: Master SEO for Next.js with metadata API, structured data (JSON-LD), sitemaps, and robots.txt. Use when implementing SEO, setting up meta tags, or optimizing for search engines.
---

# SEO for Next.js

Comprehensive SEO patterns for Next.js App Router including metadata, structured data, sitemaps, and search engine optimization best practices.

## When to Use This Skill

- Setting up metadata API for static and dynamic pages
- Implementing structured data (JSON-LD) for rich results
- Generating dynamic sitemaps for better indexing
- Configuring robots.txt and crawling rules
- Adding Open Graph and Twitter Card meta tags
- Optimizing pages for Core Web Vitals and SEO

## 1. Metadata API (Next.js 16+)

### Static Metadata

```typescript
// src/app/layout.tsx
import type { Metadata } from 'next';

export const metadata: Metadata = {
  metadataBase: new URL('https://myshop.com'),
  title: {
    default: 'MyShop - Best Online Shopping Experience',
    template: '%s | MyShop',
  },
  description: 'Discover amazing products at unbeatable prices.',
  keywords: ['online shopping', 'e-commerce', 'best deals'],
  authors: [{ name: 'MyShop Team' }],
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: 'https://myshop.com',
    siteName: 'MyShop',
    title: 'MyShop - Best Online Shopping Experience',
    description: 'Discover amazing products at unbeatable prices.',
    images: [
      {
        url: '/og-image.jpg',
        width: 1200,
        height: 630,
        alt: 'MyShop',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'MyShop - Best Online Shopping Experience',
    description: 'Discover amazing products at unbeatable prices.',
    creator: '@myshop',
    images: ['/twitter-image.jpg'],
  },
  robots: {
    index: true,
    follow: true,
  },
};
```

### Dynamic Metadata

```typescript
// src/app/products/[id]/page.tsx
import type { Metadata } from 'next';
import { productsApi } from '@/features/products/api/products-api';

interface PageProps {
  params: { id: string };
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const product = await productsApi.getById(params.id);

  return {
    title: product.name,
    description: product.description,
    openGraph: {
      title: product.name,
      description: product.description,
      type: 'product',
      url: `https://myshop.com/products/${product.id}`,
      images: [
        {
          url: product.image,
          width: 800,
          height: 600,
          alt: product.name,
        },
      ],
    },
  };
}
```

## 2. Structured Data (JSON-LD)

### Product Schema

```typescript
// src/components/seo/product-schema.tsx
import Script from 'next/script';
import { Product } from '@/features/products/types/product.types';

interface ProductSchemaProps {
  product: Product;
}

export function ProductSchema({ product }: ProductSchemaProps) {
  const schema = {
    '@context': 'https://schema.org',
    '@type': 'Product',
    name: product.name,
    description: product.description,
    image: product.image,
    brand: {
      '@type': 'Brand',
      name: 'MyShop',
    },
    offers: {
      '@type': 'Offer',
      price: product.price,
      priceCurrency: 'USD',
      availability: product.stock > 0 
        ? 'https://schema.org/InStock' 
        : 'https://schema.org/OutOfStock',
      url: `https://myshop.com/products/${product.id}`,
    },
  };

  return (
    <Script
      id="product-schema"
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
    />
  );
}
```

## 3. Sitemap Generation

```typescript
// src/app/sitemap.ts
import { MetadataRoute } from 'next';
import { productsApi } from '@/features/products/api/products-api';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const baseUrl = 'https://myshop.com';

  // Static pages
  const staticPages = [
    '',
    '/products',
    '/about',
    '/contact',
  ].map((route) => ({
    url: `${baseUrl}${route}`,
    lastModified: new Date(),
    changeFrequency: 'daily' as const,
    priority: route === '' ? 1 : 0.8,
  }));

  // Dynamic product pages
  const products = await productsApi.getAll();
  const productPages = products.map((product) => ({
    url: `${baseUrl}/products/${product.id}`,
    lastModified: new Date(product.updatedAt),
    changeFrequency: 'weekly' as const,
    priority: 0.6,
  }));

  return [...staticPages, ...productPages];
}
```

## 4. Robots.txt

```typescript
// src/app/robots.ts
import { MetadataRoute } from 'next';

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: ['/admin', '/api'],
      },
    ],
    sitemap: 'https://myshop.com/sitemap.xml',
  };
}
```

## SEO Checklist

- [ ] Metadata API configured
- [ ] Dynamic metadata for pages
- [ ] Structured data (JSON-LD) added
- [ ] Sitemap generated
- [ ] Robots.txt configured
- [ ] Image optimization (Next/Image)
- [ ] Social media meta tags
- [ ] Mobile-friendly design
- [ ] Page speed optimization

## Testing Tools

- [Google Search Console](https://search.google.com/search-console)
- [PageSpeed Insights](https://pagespeed.web.dev/)
- [Google Rich Results Test](https://search.google.com/test/rich-results)

## Related Skills
- component-generator-agent.md
- accessibility-skill.md