# Mayphus Style

Small shared style surface for Mayphus web projects.

It provides:

- warm light/dark CSS variables
- the current Mayphus font stacks
- compact landing/header/card/list classes
- a Racket module that exports the same stylesheet as `css-text`
- `define-styles` and `styles->css` for small project-specific style modules

## Racket

From a sibling repo under `~/making`:

```racket
(require style/main)

css-text
```

Install locally while developing:

```bash
raco pkg install --auto --link .
```

## Plain CSS

Generate a CSS file for any project:

```bash
racket main.rkt > mayphus.css
```

## Style DSL

The stylesheet is written in a small Racket DSL inside `main.rkt`:

```racket
(define-styles css-rules
  (style
    (rule ":root"
      [color-scheme light dark]
      (tokens
       [bg "#ffffff"]
       [fg "#191613"]))
    (class shell
      [max-width 64rem]
      [background (var bg)])
    (dark
      (rule ":root"
        (tokens
         [bg "#11100f"]
         [fg "#f2ece5"])))
    (media "(max-width:640px)"
      (class shell
        [padding "1.2rem 1rem 3rem"]))))
```

`class` emits `.mf-*` selectors, `tokens` emits CSS custom properties, and
`(var name)` emits `var(--name)`.

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
