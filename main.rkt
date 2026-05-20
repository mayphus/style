#lang racket

(require (for-syntax racket/base
                     racket/list
                     racket/match
                     racket/string
                     syntax/parse))

(provide define-styles
         styles->css
         css-rules
         css-text)

(begin-for-syntax
  (define (class-selector value)
    (format ".mf-~a" value))

  (define (var-property value)
    (string->symbol (format "--~a" value)))

  (define (expand-declaration declaration)
    (match declaration
      [`(tokens ,pairs ...)
       (for/list ([pair (in-list pairs)])
         (match pair
           [`(,name ,value)
            (list (var-property name) value)]))]
      [other (list other)]))

  (define (expand-declarations declarations)
    (append-map expand-declaration declarations))

  (define (expand-style-form datum)
    (match datum
      [`(style ,forms ...)
       (append-map expand-style-form forms)]
      [`(rule ,selector ,declarations ...)
       (list (cons selector (expand-declarations declarations)))]
      [`(class ,name ,declarations ...)
       (list (cons (class-selector name) (expand-declarations declarations)))]
      [`(dark ,forms ...)
       (list (cons "@media(prefers-color-scheme:dark)"
                   (append-map expand-style-form forms)))]
      [`(media ,query ,forms ...)
       (list (cons (format "@media~a" query)
                   (append-map expand-style-form forms)))]
      [other
       (raise-syntax-error #f "unknown style DSL form" other)]))

  (define (expand-style datums)
    (append-map expand-style-form datums))

  (define (rewrite-vars value)
    (match value
      [`(var ,name)
       (format "var(--~a)" name)]
      [(? pair?)
       (map rewrite-vars value)]
      [other other]))

  (define (rewrite-rule rule)
    (define selector (car rule))
    (define body (cdr rule))
    (if (and (string? selector) (string-prefix? selector "@"))
        (cons selector (map rewrite-rule body))
        (cons selector
              (for/list ([declaration (in-list body)])
                (cons (car declaration)
                      (map rewrite-vars (cdr declaration)))))))

  (define (expand-css-rules datums)
    (map rewrite-rule (expand-style datums))))

(define-syntax (define-styles stx)
  (syntax-parse stx
    [(_ name:id form ...)
     #`(define name '#,(expand-css-rules (syntax->datum #'(form ...))))]))

(define-styles css-rules
  (style
    (rule ":root"
      [color-scheme light dark]
      (tokens
       [bg "#ffffff"]
       [fg "#191613"]
       [surface "#ffffff"]
       [muted "#6f6761"]
       [line "rgba(25,22,19,.10)"]
       [line-strong "rgba(25,22,19,.18)"]
       [accent "#6d4b3e"]
       [accent-soft "rgba(109,75,62,.08)"]
       [accent-strong "#6d4b3e"]
       [code-bg "#ecefed"]))
    (dark
      (rule ":root"
        (tokens
         [bg "#11100f"]
         [fg "#f2ece5"]
         [surface "#171513"]
         [muted "#b9afa4"]
         [line "rgba(242,236,229,.12)"]
         [line-strong "rgba(242,236,229,.22)"]
         [accent "#ddb39c"]
         [accent-soft "rgba(221,179,156,.12)"]
         [accent-strong "#ddb39c"]
         [code-bg "#242a28"])))
    (rule "*"
      [box-sizing border-box])
    (rule "body"
      [margin 0]
      [background (var bg)]
      [color (var fg)]
      [font "16px/1.6 \"Avenir Next\",\"Segoe UI\",sans-serif"]
      [text-rendering optimizeLegibility]
      [-webkit-font-smoothing antialiased])
    (rule "a"
      [color (var accent)]
      [text-decoration-thickness .08em]
      [text-underline-offset .18em])
    (class shell
      [max-width 64rem]
      [margin 0 auto]
      [padding "2.4rem 2rem 4rem"])
    (class header
      [max-width 64rem]
      [margin 0 auto]
      [padding "2.4rem 2rem 0"]
      [display flex]
      [justify-content space-between]
      [align-items center]
      [gap 18px])
    (class brand
      [font-family "\"Iowan Old Style\",\"Palatino Linotype\",serif"]
      [font-size 1.15rem]
      [font-weight 600]
      [letter-spacing .01em]
      [color (var fg)]
      [text-decoration none])
    (class nav
      [display flex]
      [gap 1rem]
      [flex-wrap wrap]
      [font-size 1rem]
      [justify-content flex-end])
    (rule ".mf-nav a"
      [color (var muted)]
      [text-decoration none])
    (rule ".mf-nav a:hover"
      [color (var accent)])
    (rule "h1"
      [font-size 2.1rem]
      [line-height 1.16]
      [margin 0 0 16px])
    (rule "h2"
      [font-size 1.25rem]
      [line-height 1.25]
      [margin 34px 0 10px])
    (rule "p"
      [margin 0 0 16px])
    (rule "ul,ol"
      [padding-left 1.25rem])
    (rule "code"
      [background (var code-bg)]
      [border-radius 4px]
      [padding 1px 4px]
      [font-size .92em])
    (rule "blockquote"
      [border-left 3px solid (var line)]
      [margin 20px 0]
      [padding 0 0 0 16px]
      [color (var muted)])
    (class eyebrow
      [color (var muted)]
      [font-size .73rem]
      [font-weight 600]
      [letter-spacing .14em]
      [text-transform uppercase])
    (class lead
      [font-size 1.05rem]
      [line-height 1.8]
      [color (var muted)]
      [max-width 40rem])
    (class intro
      [padding-bottom 2rem])
    (class section
      [margin-top 2.2rem])
    (class section-title
      [margin-bottom .85rem])
    (rule ".mf-section-title .mf-lead"
      [font-size 1rem]
      [line-height 1.6]
      [margin-top .25rem])
    (class card-grid
      [display grid]
      [grid-template-columns "repeat(3,minmax(0,1fr))"]
      [gap 1rem])
    (class card
      [position relative]
      [display flex]
      [flex-direction column]
      [gap 1rem]
      [min-height 100%]
      [padding 1.15rem]
      [border 1px solid (var line)]
      [border-radius 1.05rem]
      [background (var surface)]
      [box-shadow "0 10px 24px rgba(25,22,19,.04)"]
      [backdrop-filter "blur(12px)"]
      [text-decoration none]
      [color "inherit"]
      [transition "border-color 160ms ease"])
    (rule ".mf-card:hover"
      [border-color (var line-strong)])
    (rule ".mf-card h2"
      [margin 0]
      [font-size 1.06rem]
      [font-weight 600]
      [line-height 1.2])
    (rule ".mf-card p"
      [margin 0]
      [color (var muted)])
    (class card-action
      [margin-top auto]
      [color (var muted)])
    (class link-list
      [list-style none]
      [padding 0]
      [margin 22px 0 0])
    (rule ".mf-link-list li"
      [border-top 1px solid (var line)]
      [padding 15px 0])
    (rule ".mf-link-list li:first-child"
      [border-top 0])
    (rule ".mf-link-list a"
      [font-weight 700]
      [text-decoration none])
    (class meta
      [color (var muted)]
      [font-size .92rem])
    (class description
      [color (var muted)]
      [margin-top 5px])
    (rule "article"
      [max-width 780px]
      [margin 0 auto]
      [padding 0])
    (rule "article h1"
      [font-size 2.1rem]
      [line-height 1.16])
    (class tag-row
      [display flex]
      [gap 8px]
      [flex-wrap wrap]
      [margin-top 16px])
    (class tag
      [border 1px solid (var line)]
      [border-radius 999px]
      [padding 2px 9px]
      [font-size .82rem]
      [color (var muted)])
    (class footer
      [max-width 64rem]
      [margin 0 auto]
      [padding "0 2rem 4rem"]
      [color (var muted)]
      [font-size .88rem])
    (rule ".mf-footer a"
      [color inherit]
      [text-decoration none])
    (media "(max-width:640px)"
      (class header
        [align-items flex-start]
        [flex-direction column]
        [padding "1.2rem 1rem 0"])
      (class shell
        [padding "1.2rem 1rem 3rem"])
      (class intro
        [padding-bottom 1.5rem])
      (class nav
        [width 100%]
        [justify-content flex-start])
      (class card-grid
        [grid-template-columns 1fr])
      (class lead
        [font-size 1.12rem])
      (rule "h1"
        [font-size 1.72rem]))))

(define (css-name value)
  (cond
    [(keyword? value) (keyword->string value)]
    [(symbol? value) (symbol->string value)]
    [else (~a value)]))

(define (css-value value)
  (cond
    [(list? value) (string-join (map css-value value) " ")]
    [else (~a value)]))

(define (declaration->css declaration)
  (define property (car declaration))
  (define values (cdr declaration))
  (format "~a:~a" (css-name property) (css-value values)))

(define (style-rule->css rule)
  (define selector (css-name (car rule)))
  (define body (cdr rule))
  (if (string-prefix? selector "@")
      (format "~a{~a}" selector (styles->css body))
      (format "~a{~a}"
              selector
              (string-join (map declaration->css body) ";"))))

(define (styles->css rules)
  (string-join (map style-rule->css rules) ""))

(define css-text (styles->css css-rules))

(module+ main
  (display css-text))

(module+ test
  (require rackunit)

  (check-true (string-contains? css-text "--bg:#ffffff"))
  (check-true (string-contains? css-text ".mf-shell{"))
  (check-true (string-contains? css-text "box-sizing:border-box"))
  (check-false (string-contains? css-text "tokens:")))
