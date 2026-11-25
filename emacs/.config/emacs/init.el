;;; init.el -*- lexical-binding: t -*-

(setq custom-file (locate-user-emacs-file "custom.el"))  ; else Customize writes through the stow link into the repo
(load custom-file t)

(editorconfig-mode 1)  ; off by default, and vanilla indents with tabs

;; Last: an unlinked themes/ errors loudly instead of silently falling back, without skipping the rest.
(add-to-list 'custom-theme-load-path (locate-user-emacs-file "themes/"))
(setq catppuccin-flavor 'frappe)
(load-theme 'catppuccin t)
