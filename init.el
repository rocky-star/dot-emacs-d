;;; init.el --- Init  -*- lexical-binding: t; eval: (outline-minor-mode); -*-

;;; Commentary:

;; This is the init file.

;;; Code:

(setopt use-package-enable-imenu-support t)

;;; CORE & PACKAGE MANAGEMENT

(use-package emacs
  :bind (("M-M" . end-of-line) ; Expand M-m to jump to end line, useful for paragraphs.

         ;; paragraphs.el
         ("M-K" . kill-paragraph)            ; Expand M-k for kill-sentence.
         ("M-T" . transpose-sentences)       ; Expand M-t for transposing words.
         ("C-x M-t" . transpose-paragraphs)) ; Expand C-x C-t for transposing lines.
  :config
  ;; Don't allow the cursor in the minibuffer prompt.
  (setopt minibuffer-prompt-properties
          '(read-only t intangible t cursor-intangible t face minibuffer-prompt))

  (setopt completion-ignore-case t
          delete-by-moving-to-trash t
          delete-pair-push-mark t ; Emacs 31, for easy subsequent C-x C-x.
          enable-recursive-minibuffers t
          history-length 300
          mode-line-compact 'long
          read-process-output-max (* 1024 1024) ; 1 MiB
          redisplay-skip-fontification-on-input t
          undo-limit (* 13 160000)
          undo-strong-limit (* 13 240000)
          undo-outer-limit (* 13 24000000)
          user-full-name "Rocky☆Star"
          window-combination-limit t
          window-resize-pixelwise t
          read-buffer-completion-ignore-case t)

  ;; Disable bidi text scanning.
  (setq-default bidi-paragraph-direction 'left-to-right)
  (setq bidi-inhibit-bpa t)

  ;; Make git commands in Eshell open an instance of THIS config of Emacs.
  (dolist (varname '("GIT_EDITOR" "JJ_EDITOR"))
    (setenv varname (format "emacs --init-dir=%s " (shell-quote-argument user-emacs-directory))))

  (when (eq system-type 'windows-nt)
    ;; Set PowerShell as the default shell.
    (catch 'found
      (dolist (shell-name '("pwsh" "PowerShell"))
        (let ((shell-path (executable-find shell-name)))
          (when shell-path
            (setopt shell-file-name shell-path)
            (throw 'found nil)))))

    ;; Use UNIX-like tools provided by Git on Windows.
    (let ((git-bin "C:\\Program Files\\Git\\usr\\bin"))
      (when (file-directory-p git-bin)
        (setopt exec-path (cons git-bin exec-path)))))

  ;; EasyPG only trusts `epg-gpg-program' directly when it has a Customize
  ;; value; otherwise it may still pick Git for Windows' MSYS gpg.exe.
  (when (eq system-type 'windows-nt)
    (let ((gpg-bin "C:/Program Files/GnuPG/bin/gpg.exe"))
      (when (file-exists-p gpg-bin)
        (customize-set-variable 'epg-gpg-program gpg-bin)
        (when (boundp 'epg--configurations)
          (setq epg--configurations nil)))))

  ;; files.el
  (setopt view-read-only t
          ;; TRAMP enhancements from
          ;; <https://coredumped.dev/2025/06/18/making-tramp-go-brrrr./>.
          remote-file-name-inhibit-delete-by-moving-to-trash t
          remote-file-name-inhibit-auto-save t
          remote-file-name-inhibit-locks t
          remote-file-name-inhibit-auto-save-visited t)

  ;; indent.el
  (setopt tab-always-indent 'complete))

(use-package mule
  :config
  ;; Make everything accept UTF-8 as default.
  (modify-coding-system-alist 'file "" 'utf-8))

(use-package package
  :defer t
  :config
  (let ((make-pair
         (lambda (name)
           (cons name (concat "https://mirrors.tuna.tsinghua.edu.cn/elpa/" name "/")))))
    (setopt package-archives (mapcar make-pair '("gnu" "nongnu" "stable-melpa" "melpa"))
            package-archive-priorities
            '(("gnu" . 99)
              ("nongnu" . 90)
              ("stable-melpa" . 80)
              ("melpa" . 70))))

  (when (fboundp 'package-autosuggest-mode)
    (package-autosuggest-mode))) ; Emacs 31

(use-package help
  :defer t
  :config
  (setopt view-lossage-auto-refresh t)) ; Emacs 31, auto update C-h l

;;; APPEARANCE & WINDOW MANAGEMENT

(require-theme 'modus-themes)
(use-package modus-themes
  :config
  (setopt modus-themes-bold-constructs t
          modus-themes-italic-constructs t
          modus-themes-mixed-fonts t
          modus-themes-prompts '(italic bold)
          modus-themes-completions
          '((matches . (extrabold))
            (selection . (semibold italic text-also)))
          modus-themes-variable-pitch-ui t)
  (modus-themes-load-theme 'modus-operandi-tinted))

(use-package ligature
  :when (package-installed-p 'ligature)
  :config
  (ligature-set-ligatures 't '("www" "://"))
  (ligature-set-ligatures '(text-mode Info-mode) '("ff" "fi" "ffi"))
  (ligature-set-ligatures
   'python-mode
   '(":=" "!=" "**" "==" ">=" ">>" ">>=" "<=" "<<" "<<=" "~=" "^=" "->"))
  (global-ligature-mode))

(use-package frame
  :bind (("C-x 5 l" . select-frame-by-name)
         ("C-x 5 s" . set-frame-name)

         ;; Make C-x 5 o repeatable.
         :repeat-map frame-repeat-map
         ("o" . other-frame)
         ("n" . make-frame)
         ("d" . delete-frame)))

(use-package window
  :config
  (setopt switch-to-buffer-obey-display-actions t
          window-sides-vertical t))

(use-package tab-bar
  :bind (("C-x t <left>" . tab-bar-history-back)
         ("C-x t <right>" . tab-bar-history-forward))
  :config
  (tab-bar-mode)
  (tab-bar-history-mode))

(use-package pixel-scroll
  :config
  (setopt pixel-scroll-precision-use-momentum t)
  (pixel-scroll-mode)
  (pixel-scroll-precision-mode))

(use-package display-line-numbers
  :hook (prog-mode text-mode)
  :config
  (setopt display-line-numbers-type 'relative))

(use-package display-fill-column-indicator
  :hook (prog-mode text-mode))

(use-package face-remap
  :hook (Info-mode . variable-pitch-mode))

(use-package tooltip
  :config
  (tooltip-mode))

(use-package tty-tip
  :when (>= emacs-major-version 31)
  :config
  (tty-tip-mode))

(use-package mouse
  :config
  (setopt mouse-yank-at-point t
          mouse-drag-and-drop-region t
          mouse-drag-and-drop-region-cross-program t
          mouse-drag-mode-line-buffer t)
  (context-menu-mode))

;;; MINIBUFFER & COMPLETION

(use-package minibuffer
  :config
  (setopt completion-auto-select 'second-tab
          minibuffer-visible-completions (if (>= emacs-major-version 31) 'up-down t)
          completion-styles '(basic emacs22 flex)
          completions-detailed t
          completions-group t
          ;; completion-eager-update t
          ;; completions-format 'one-column
          completions-sort 'historical)

  (add-hook 'minibuffer-setup-hook
            (lambda () (setq-local truncate-lines t)))

  (minibuffer-depth-indicate-mode)
  (minibuffer-electric-default-mode))

(use-package icomplete
  :config
  (fido-vertical-mode))

(use-package which-key
  :when (package-installed-p 'which-key)
  :config
  (setopt which-key-dont-use-unicode nil
          which-key-idle-secondary-delay 0.25
          which-key-add-column-padding 1)

  ;; Add some descriptions for the default bindings in `global-map'
  ;; and `org-mode-map'.
  (which-key-add-key-based-replacements
    "<f1> 4" "help-other-win"
    "C-c" "mode-and-user"
    "C-c @" "outline"
    "C-h 4" "help-other-win"
    "C-x 4" "other-window"
    "C-x 5" "other-frame"
    "C-x 8" "insert-special"
    "C-x 8 ^" "superscript (⁰, ¹, ², …)"
    "C-x 8 _" "subscript (₀, ₁, ₂, …)"
    "C-x 8 a" "arrows & æ (←, →, ↔, æ)"
    "C-x 8 e" "emojis (🫎, 🇧🇷, 🇮🇹, …)"
    "C-x 8 *" "common symbols ( , ¡, €, …)"
    "C-x 8 =" "macron (Ā, Ē, Ḡ, …)"
    "C-x 8 N" "macron (№)"
    "C-x 8 O" "macron (œ)"
    "C-x 8 ~" "tilde (~, ã, …)"
    "C-x 8 /" "stroke (÷, ≠, ø, …)"
    "C-x 8 ." "dot (·, ż)"
    "C-x 8 ," "cedilla (¸, ç, ą, …)"
    "C-x 8 '" "acute (á, é, í, …)"
    "C-x 8 `" "grave (à, è, ì, …)"
    "C-x 8 \"" "quotation/dieresis (\", ë, ß, …)"
    "C-x 8 1" "†, 1/…"
    "C-x 8 2" "‡"
    "C-x 8 3" "3/…"
    "C-x C-k C-q" "kmacro-counters"
    "C-x C-k C-r a" "kmacro-add"
    "C-x C-k C-r" "kmacro-register"
    "C-x RET" "encoding/input"
    "C-x a i" "abbrevs-inverse-add"
    "C-x a" "abbrevs"
    "C-x n" "narrowing"
    "C-x p" "projects"
    "C-x r" "reg/rect/bkmks"
    "C-x t ^" "tab-bar-detach"
    "C-x t" "tab-bar"
    "C-x v" "version-control"
    "C-x w ^" "window-detach"
    "C-x w" "window-extras"
    "C-x x" "buffer-extras"
    "C-x" "extra-commands"
    "M-g" "goto-map"
    "M-s h" "search-highlight"
    "M-s" "search-map")

  (which-key-mode))

;;; EDITING BEHAVIOR

(use-package misc
  :bind (("M-J" . duplicate-dwim)     ; Since M-j is for breaking the line.
         ("M-Z" . zap-up-to-char)     ; Expand M-z for zap-to-char.
         ("M-F" . forward-to-word)    ; Expand M-f to jump to beginning of next word.
         ("M-B" . backward-to-word))) ; Expand M-b to jump to end of previous word

(use-package simple
  :bind (([remap capitalize-word] . capitalize-dwim) ; Make M-c work on regions.
         ([remap downcase-word] . downcase-dwim)     ; Make M-l work on regions.
         ([remap upcase-word] . upcase-dwim))        ; Make M-u work on regions.
  :config
  (setopt kill-do-not-save-duplicates t
          kill-region-dwim 'emacs-word ; Emacs 31
          read-extended-command-predicate #'command-completion-default-include-p ; Hide unusable commands in M-x.
          save-interprogram-paste-before-kill t
          set-mark-command-repeat-pop t ; Able to use C-u C-SPC C-SPC ... instead of C-u C-SPC C-u C-SPC ...
          ;; completion-show-help nil
          shell-command-prompt-show-cwd t)
  (column-number-mode))

(use-package delsel
  :config
  (delete-selection-mode))

(use-package elec-pair
  :config
  (electric-pair-mode))

(use-package paren
  :config
  (setopt show-paren-style 'mixed
          show-paren-context-when-offscreen t))

(use-package register
  :config
  (setopt register-use-preview t))

(use-package repeat
  :config
  (repeat-mode))

;;; FILES & STATE

(use-package savehist
  :preface
  (defun my--strip-text-props-from-kill-ring ()
    "Strip text properties from the kill ring."
    (setq kill-ring (mapcar #'substring-no-properties (cl-remove-if-not #'stringp kill-ring))))
  :config
  (setopt savehist-additional-variables
          '(kill-ring                        ; Clipboard
            register-alist                   ; Macros
            mark-ring global-mark-ring       ; Marks
            search-ring regexp-search-ring)) ; Searches
  (add-hook 'savehist-save-hook #'my--strip-text-props-from-kill-ring)
  (savehist-mode))

(use-package saveplace
  :config
  ;; Recenter after save-place restore.
  (add-hook 'save-place-find-file-hook :after
            (lambda (&rest _)
              (when buffer-file-name (ignore-errors (recenter)))))
  (save-place-mode))

(use-package recentf
  :bind ("M-g r" . recentf)
  :config
  (setopt recentf-max-saved-items 300
          recentf-auto-cleanup (if (daemonp) 300 'never)
          recentf-exclude '("^/\\(?:ssh\\|su\\|sudo\\)?:"))
  (recentf-mode))

(use-package autorevert
  :hook (emacs-startup . global-auto-revert-mode)
  :config
  (setopt auto-revert-remote-files nil
          auto-revert-avoid-polling t
          global-auto-revert-non-file-buffers t))

(use-package rfn-eshadow
  :config
  (file-name-shadow-mode))

(use-package dired
  :defer t
  :hook (dired-mode . dired-omit-mode)
  :config
  (setopt dired-auto-revert-buffer t
          dired-mouse-drag-files t
          dired-dwim-target t
          dired-kill-when-opening-new-dired-buffer t
          dired-listing-switches "-alh --group-directories-first"
          dired-hide-details-hide-absolute-location t)) ; Emacs 31

(use-package wdired
  :defer t
  :config
  (setopt wdired-allow-to-change-permissions t))

(use-package find-dired
  :bind ("M-s f" . find-name-dired)
  :config
  (setopt find-ls-option '("-exec ls -ldh {} +" . "-ldh"))) ; Human-readable sizes.

(use-package tramp
  :defer t
  :config
  ;; TRAMP enhancements from
  ;; <https://coredumped.dev/2025/06/18/making-tramp-go-brrrr./>.
  (setopt tramp-copy-size-limit (* 2 1024 1024) ; 2 MiB
          tramp-use-scp-direct-remote-copying t)
  (connection-local-set-profile-variables 'remote-direct-async-process '((tramp-direct-async-process . t)))
  (connection-local-set-profiles '(:application tramp :protocol "scp") 'remote-direct-async-process))

;; Also TRAMP enhancements.
(use-package compile
  :defer t
  :after tramp
  :config
  (remove-hook 'compilation-mode-hook #'tramp-compile-disable-ssh-controlmaster-options))

;;; SEARCH & NAVIGATION

(use-package isearch
  :config
  (setopt isearch-lazy-count t
          search-whitespace-regexp "[ \t\r\n]+"))

(use-package grep
  :bind ("M-s g" . grep)
  :config
  (when (executable-find "rg")
    (setopt grep-command "rg -nS --no-heading "))
  (setopt grep-find-ignored-directories
          (append grep-find-ignored-directories '("node_modules" "build" "dist"))))

(use-package xref
  :defer t
  :config
  (when (executable-find "rg")
    (setopt xref-search-program 'ripgrep))
  (when (fboundp 'global-xref-mouse-mode) ; Emacs 31
    (global-xref-mouse-mode)))

(use-package imenu
  :defer t
  :config
  (setopt imenu-auto-rescan t))

(use-package ibuffer
  :bind ([remap list-buffers] . ibuffer)
  :init
  (add-hook 'ibuffer-mode-hook
            (lambda ()
              (ibuffer-switch-to-saved-filter-groups "Default")))
  :config
  (setopt ibuffer-human-readable-size t ; Emacs 31
          ibuffer-saved-filter-groups
          '(("Default"
             ("Org" (or
                     (mode . org-mode)
                     (name . "^\\*Org Src")
                     (name . "^\\*Org Agenda\\*$")))
             ("TRAMP" (name . "^\\*tramp.*"))
             ("Emacs" (or
                       (name . "^\\*scratch\\*$")
                       (name . "^\\*Messages\\*$")
                       (name . "^\\*Warnings\\*$")
                       (name . "^\\*Shell Command Output\\*$")
                       (name . "^\\*Async-native-compile-log\\*$")))
             ("Ediff" (name . "^\\*[Ee]diff.*"))
             ("VC" (name . "^\\*vc-.*"))
             ("Dired" (mode . dired-mode))
             ("Terminal" (or
                          (mode . term-mode)
                          (mode . shell-mode)
                          (mode . eshell-mode)))
             ("Help" (or
                      (name . "^\\*Help\\*$")
                      (name . "^\\*info\\*$")))))
          ibuffer-show-empty-filter-groups nil))

;;; WEB

(use-package webjump
  :bind ("C-x /" . webjump)
  :config
  (setopt webjump-sites
          '(("Google" . [simple-query "https://www.google.com" "https://www.google.com/search?q=" ""])
            ("Bing" . [simple-query "https://www.bing.com" "https://www.bing.com/search?q="])
            ("YouTube" . [simple-query "https://www.youtube.com/feed/subscriptions" "https://www.youtube.com/results?search_query=" ""]))))

(use-package browse-url
  :defer t
  :config
  (setopt browse-url-secondary-browser-function 'eww-browse-url))

(use-package goto-addr
  :config
  (global-goto-address-mode))

(use-package shr
  :defer t
  :config
  (setopt shr-use-colors nil))

(use-package ffap
  :defer t
  :config
  (setopt ffap-machine-p-known 'reject))

;;; PROGRAMMING --- Language-Agnostic

(use-package project
  :defer t
  :config
  (setopt project-vc-extra-root-markers '("Cargo.toml" "package.json" "go.mod" "*.asd" "pom.xml" "requirements.txt" "pyproject.toml" "Gemfile" "*.gemspec" "autogen.sh")))

(use-package compile
  :defer t
  :config
  (setopt compilation-scroll-output 'first-error
          ansi-color-for-compilation-mode t)
  (add-hook 'compilation-filter-hook #'ansi-color-compilation-filter))

(use-package eglot
  :defer t
  :bind ( :map eglot-mode-map
          ("C-c l a" . eglot-code-actions)
          ("C-c l o" . eglot-code-action-organize-imports)
          ("C-c l r" . eglot-rename)
          ("C-c l i" . eglot-inlay-hints-mode)
          ("C-c l f" . eglot-format))
  :config
  (setopt eglot-autoshutdown t))

(use-package eglot-booster
  :when (and (package-installed-p 'eglot-booster)
             (executable-find "emacs-lsp-booster"))
  :after eglot
  :config
  (when (>= emacs-major-version 30)
    (setopt eglot-booster-io-only t))
  (setopt eglot-booster-no-remote-boost t)
  (eglot-booster-mode))

(use-package dape
  :when (package-installed-p 'dape)
  :hook ((kill-emacs . dape-breakpoint-save)
         (after-init . dape-breakpoint-load))
  :config
  ;; Allow setting breakpoints with a mouse.
  (dape-breakpoint-global-mode)

  (setopt dape-info-hide-mode-line nil)
  (add-hook 'dape-display-source-hook #'pulse-momentary-highlight-one-line)
  (add-hook 'dape-start-hook (lambda () (save-some-buffers t t)))
  (add-hook 'dape-compile-hook #'kill-buffer))

(use-package flymake
  :hook prog-mode
  :bind ( :map flymake-mode-map
          ("M-n" . flymake-goto-next-error)
          ("M-p" . flymake-goto-prev-error))
  :config
  (setopt flymake-show-diagnostics-at-end-of-line 'short))

(use-package completion-preview
  :hook (prog-mode text-mode))

(use-package eldoc
  :preface
  (defvar my--eldoc-html-patterns
    '(("&nbsp;" "\u00a0")
      ("&lt;" "<")
      ("&gt;" ">")
      ("&amp;" "&")
      ("&quot;" "\"")
      ("&apos;" "'"))
    "List of (PATTERN . REPLACEMENT) to replace in eldoc output.")

  (defun my--string-replace-all (patterns in-string)
    "Replace all cars from PATTERNS in IN-STRING with their pair."
    (mapc (lambda (pattern-pair)
            (setq in-string
                  (string-replace (car pattern-pair) (cadr pattern-pair) in-string)))
          patterns)
    in-string)

  (defun my--eldoc-preprocess (orig-fun &rest args)
    "Preprocess the docs to be displayed by eldoc to replace HTML escapes."
    (let ((doc (car args)))
      ;; The first argument is a list of (STRING :KEY VALUE ...) entries
      ;; we replace the text in each such string,
      ;; see docstring of `eldoc-display-functions'.
      (when (listp doc)
        (setq doc (mapcar
                   (lambda (doc) (cons
                                  (my--string-replace-all my--eldoc-html-patterns (car doc))
                                  (cdr doc)))
                   doc)))
      (apply orig-fun (cons doc (cdr args)))))
  :config
  (setopt eldoc-help-at-pt t ; Emacs 31
          eldoc-echo-area-prefer-doc-buffer t
          eldoc-documentation-strategy 'eldoc-documentation-compose)

  (advice-add 'eldoc-display-in-buffer :around #'my--eldoc-preprocess))

(use-package treesit
  :defer t
  :config
  (setopt treesit-font-lock-level 4
	  treesit-enabled-modes '(python-ts-mode))) ; Emacs 31

(use-package which-func
  :config
  (which-function-mode))

;;; PROGRAMMING --- Version Control

(use-package vc
  :config
  (setopt vc-allow-rewriting-published-history 'ask ; Emacs 31
          vc-git-diff-switches '("--patch-with-stat" "--histogram")
          vc-git-log-switches '("--stat")
          vc-git-log-edit-summary-target-len 50
          vc-git-log-edit-summary-max-len 70
          vc-git-print-log-follow t
          ;; vc-git-show-stash 0
          vc-annotate-display-mode 'scale
          vc-find-revision-no-save t
          vc-use-incoming-outgoing-prefixes t ; Emacs 31
          vc-dir-save-some-buffers-on-revert t ; Emacs 31
          add-log-keep-changes-together t)
  (when (boundp 'vc-auto-revert-mode)
    (vc-auto-revert-mode)))

(use-package diff-mode
  :defer t
  :config
  (setopt diff-default-read-only t
          diff-font-lock-syntax 'hunk-also
          diff-font-lock-prettify t))

(use-package ediff
  :defer t
  :config
  (setopt ediff-keep-variants nil))

(use-package diff-hl
  :when (package-installed-p 'diff-hl)
  :hook ((prog-mode vc-dir-mode) . turn-on-diff-hl-mode))

;;; PROGRAMMING --- Per-Language

(use-package cc-mode
  :defer t
  :config
  (setopt c-default-style '((java-mode . "java")
                            (awk-mode . "awk")
                            (other . "stroustrup"))))

(use-package python
  :defer t
  :preface
  (defun my--python-add-prettify-symbols ()
    "Add prettify symbols to the current Python buffer."
    (setq-local prettify-symbols-alist
                (append prettify-symbols-alist
                        '(("and" . ?∧)
                          ("for" . ?∀)
                          ("in" . ?∈)
			  ("is" . ?≡)
			  ("is not" . ?≢)
                          ("lambda" . ?λ)
                          ("not" . ?¬)
                          ("not in" . ?∉)
                          ("or" . ?∨)))))
  :hook (python-base-mode . my--python-add-prettify-symbols))

(use-package pet
  :when (package-installed-p 'pet)
  :init
  (add-hook 'python-base-mode 'pet-mode -10))

;;; WRITING

(use-package flyspell
  :defer t
  :config
  (when (executable-find "aspell")
    (setopt ispell-program-name "aspell"
            ispell-dictionary "en_US"))
  ;; (ispell-set-spellchecker-params)
  )

(use-package auctex
  :when (package-installed-p 'auctex)
  :preface
  (defun my--japanese-LaTeX-setup ()
    "Set sensible defaults for Japanese LaTeX buffers."
    (catch 'prog
      (dolist (prog '("dvipdfmx" "dvips"))
        (when (executable-find prog)
          (setq-local TeX-PDF-from-DVI (capitalize prog))
          (throw 'prog nil)))
      (message "Both dvipdfmx and dvips are not available.")))
  :hook ((LaTeX-mode . LaTeX-math-mode)
         (LaTeX-mode . turn-on-reftex)
         (japanese-LaTeX-mode . my--japanese-LaTeX-setup))
  :config
  (setopt TeX-auto-save t
          TeX-parse-self t)
  (setq-default TeX-master nil)

  (setopt TeX-default-mode 'japanese-LaTeX-mode
          japanese-TeX-engine-default 'uptex
          japanese-LaTeX-default-style "ctexart"))

(use-package markdown-mode
  :when (package-installed-p 'markdown-mode)
  :mode ("README\\.md\\'" . gfm-mode)
  :config
  (when (executable-find "pandoc")
    (setopt markdown-command '("pandoc" "--from=markdown" "--to=html5")))
  (setopt markdown-asymmetric-header t
          markdown-header-scaling t
          markdown-hide-urls t
          markdown-fontify-code-blocks-natively t
          markdown-gfm-uppercase-checkbox t))

(use-package doc-view
  :defer t
  :config
  (setopt doc-view-resolution 200))

;;; UTILITIES

(use-package shell
  :preface
  (defun my--shell-toggle-echo-mode ()
    "Automatically toggle comint's echo mode according to the shell."
    (let* ((proc (get-buffer-process (current-buffer)))
           (shell-path (car (process-command proc))))
      (catch 'found
        (dolist (suffix '("cmdproxy.exe" "cmd.exe" "PowerShell.exe" "pwsh.exe"))
          (when (string-suffix-p suffix shell-path)
            (setq-local comint-process-echoes t)
            (throw 'found nil))))))
  :config
  (add-hook 'shell-mode-hook #'my--shell-toggle-echo-mode))

(use-package eshell
  :defer t
  :hook (eshell-mode . eshell-read-history)
  :config
  (setopt eshell-history-size 100000
          eshell-hist-ignoredups t))

(use-package speedbar
  :preface
  (defun my-toggle-speedbar ()
    "Toggle / focus speedbar."
    (interactive)
    (speedbar)
    (let ((win (get-buffer-window speedbar-buffer)))
      (when win
        (select-window win))))
  :bind ("M-I" . my-toggle-speedbar)
  :config
  (setopt speedbar-prefer-window t ; Emacs 31
          speedbar-show-unknown-files t))

(use-package calendar
  :defer t
  :config
  (setopt calendar-latitude [34 19 north]
          calendar-longitude [108 42 east]
          calendar-location-name "Xianyang, Shaanxi"))

(use-package time
  :defer t
  :config
  (setopt world-clock-sort-order "%FT%T" ; Emacs 31
          display-time-day-and-date t))

(use-package epg
  :defer t
  :config
  (setopt epg-pinentry-mode 'loopback))

(use-package xt-mouse
  :config
  (xterm-mouse-mode))

(use-package editorconfig
  :when (package-installed-p 'editorconfig)
  :config
  (editorconfig-mode))

(provide 'init)
;;; init.el ends here
