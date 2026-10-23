import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const moduleDirectory = dirname(fileURLToPath(import.meta.url));

function escapeHtml(value: string) {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}

function inlineMarkdown(value: string) {
  return escapeHtml(value)
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    .replace(/(https:\/\/[^\s<]+)/g, '<a href="$1">$1</a>')
    .replace(/([\w.+-]+@[\w.-]+\.[A-Za-z]{2,})/g, '<a href="mailto:$1">$1</a>');
}

function markdownToHtml(markdown: string) {
  const blocks: string[] = [];
  let listOpen = false;
  const closeList = () => {
    if (listOpen) {
      blocks.push('</ul>');
      listOpen = false;
    }
  };

  for (const rawLine of markdown.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line) {
      closeList();
      continue;
    }
    if (line === '---') {
      closeList();
      blocks.push('<hr>');
      continue;
    }
    const heading = line.match(/^(#{1,3})\s+(.+)$/);
    if (heading) {
      closeList();
      const level = heading[1]?.length ?? 2;
      blocks.push(`<h${level}>${inlineMarkdown(heading[2] ?? '')}</h${level}>`);
      continue;
    }
    if (line.startsWith('- ')) {
      if (!listOpen) {
        blocks.push('<ul>');
        listOpen = true;
      }
      blocks.push(`<li>${inlineMarkdown(line.slice(2))}</li>`);
      continue;
    }
    closeList();
    blocks.push(`<p>${inlineMarkdown(line)}</p>`);
  }
  closeList();
  return blocks.join('\n');
}

export function renderLegalPage(fileName: string, pageTitle: string) {
  const markdownPath = resolve(moduleDirectory, '..', '..', fileName);
  const body = markdownToHtml(readFileSync(markdownPath, 'utf8'));
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(pageTitle)}</title>
  <style>
    :root { color-scheme: light dark; }
    body { margin: 0; font: 16px/1.65 -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; background: #f8faf7; color: #14221c; }
    main { max-width: 760px; margin: 0 auto; padding: 48px 24px 80px; }
    h1 { font-size: clamp(2rem, 6vw, 3rem); line-height: 1.1; color: #075b45; }
    h2 { margin-top: 2.2rem; color: #0b6b52; }
    h3 { color: #0b6b52; }
    a { color: #087c5e; }
    li { margin: .55rem 0; }
    hr { border: 0; border-top: 1px solid #cbd8d1; margin: 3rem 0; }
    @media (prefers-color-scheme: dark) {
      body { background: #071c15; color: #e8f2ed; }
      h1, h2, h3, a { color: #4bd4aa; }
      hr { border-color: #29483c; }
    }
  </style>
</head>
<body><main>${body}</main></body>
</html>`;
}
