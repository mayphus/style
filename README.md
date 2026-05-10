# Mayphus Style

Small shared style surface for Mayphus web projects.

It provides:

- warm light/dark CSS variables
- the current Mayphus font stacks
- compact landing/header/card/list classes
- a Racket module that exports the same stylesheet as `css-text`

## Racket

From a sibling repo under `~/making`:

```racket
(require "../style/main.rkt")

css-text
```

## Plain CSS

Generate a CSS file for any project:

```bash
racket main.rkt > mayphus.css
```

## Class Surface

- `mf-shell`
- `mf-header`
- `mf-brand`
- `mf-nav`
- `mf-intro`
- `mf-section`
- `mf-section-title`
- `mf-eyebrow`
- `mf-lead`
- `mf-card-grid`
- `mf-card`
- `mf-card-action`
- `mf-link-list`
- `mf-meta`
- `mf-description`
- `mf-footer`
- `mf-tag-row`
- `mf-tag`
