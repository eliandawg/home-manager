;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package with Doom you must declare them here and run 'doom sync'
;; on the command line, then restart Emacs for the changes to take effect -- or
;; use 'M-x doom/reload'.

;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
;; (package! some-package)

;; Emacs
(package! flash)
(disable-packages! evil-snipe avy)
;; (package! doom-snippets :ignore t)
;; (package! yasnippet-snippets)

(unpin! flycheck)

;;; Org
(package! org-download)
(package! org-appear)
(package! git-auto-commit-mode)
(package! websocket)
(package! org-roam-ui)
(package! verb)
(package! vundo)
(package! org-tidy)
(package! org-block-wrap
  :recipe (:host gitlab :repo "vegasharmon/org-block-wrap"))
(package! org-habit-ng
  :recipe (:host github :repo "emacsmirror/org-habit-ng"))

;;; TRAMP
(package! tramp-hlo)
(package! msgpack)
(package! tramp-rpc :recipe (:host github :repo "ArthurHeymans/emacs-tramp-rpc" :files ("lisp/*.el")))

;; Code
(package! just-mode)
(package! fish-mode)
(package! flymake-ruff)
(package! ssh-config-mode)
(package! kdl-mode)
(package! uv
  :recipe (:host github :repo "johannes-mueller/uv.el"))
(package! flyover
  :recipe (:host github :repo "konrad1977/flyover"))
(package! mason)

;; Themes
(package! ef-themes
  :recipe (:host github
           :repo "protesilaos/ef-themes"))
(package! standard-themes)
(package! kaolin-themes)
(package! modus-catppuccin
  :recipe (:host gitlab
           :repo "magus/modus-catppuccin"))

;; Misc
(package! ghostel)
(package! evil-ghostel)
(package! buffer-to-pdf
  :recipe (:host github
           :repo "protesilaos/buffer-to-pdf"))
(package! vertico-posframe-preview
  :recipe (:host github
           :repo "kn66/vertico-posframe-preview"))
(package! olivetti)
(package! popterm
  :recipe (:host github
           :repo "ChetanKoneru/popterm.el"))
(package! markdown-indent-mode
  :recipe (:host github
           :repo "whhone/markdown-indent-mode"))
(package! easysession)
