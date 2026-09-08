;;; -*- lexical-binding: t; -*-

(use-package completion-preview
  :demand t
  :config
  (setq completion-preview-minimum-symbol-length 2)
  (global-completion-preview-mode 1))

(map! :leader "fa" #'consult-org-agenda)
(map! :leader "fd" #'consult-dir)

(use-package dired
  ;; Most from
  ;; https://www.jamescherti.com/emacs-dired-configuration/
  :custom
  (dired-auto-revert-buffer 'dired-directory-changed-p)
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-movement-style 'bounded-files)
  (dired-do-revert-buffer (lambda (dir)
                            (not (file-remote-p dir)))))

(use-package dirvish
  :defer t
  :custom
  (dirvish-attributes '(nerd-icons collapse file-size file-time))
  (dirvish-default-layout '(0 0.11 0.55))
  (dirvish-time-format-string "%d-%m-%y %I:%S:%p %Z")
  (dired-use-ls-dired 't)
  (dirvish-peek-mode 't)
  :config
  (when (and (eq system-type 'darwin) (executable-find "gls"))
    (setopt insert-directory-program "gls")))

(map! :leader "e" #'dirvish)

(defun Ex ()
  "Literally just opens dirvish. Made because I keep doing `:Ex`."
  (interactive)
  (dirvish))

(use-package easysession
  ;; ':demand t' ensures the package is loaded immediately upon startup
  :demand t

  :config
  ;; Key mappings
  (global-set-key (kbd "C-c sl") #'easysession-switch-to) ; Load session
  (global-set-key (kbd "C-c ss") #'easysession-save) ; Save session
  (global-set-key (kbd "C-c sL") #'easysession-switch-to-and-restore-geometry)
  (global-set-key (kbd "C-c sr") #'easysession-rename)
  (global-set-key (kbd "C-c sR") #'easysession-reset)
  (global-set-key (kbd "C-c su") #'easysession-unload)
  (global-set-key (kbd "C-c sd") #'easysession-delete)

  ;; Save every 10 minutes
  (setq easysession-save-interval (* 10 60))

  ;; Save the current session when using `easysession-switch-to'
  (setq easysession-switch-to-save-session t)

  ;; Do not exclude the current session when switching sessions
  (setq easysession-switch-to-exclude-current nil)

  ;; Display the active session name in the mode-line lighter.
  ;; (setq easysession-save-mode-lighter-show-session-name t)

  ;; Optionally, the session name can be shown in the modeline info area:
  ;; (setq easysession-mode-line-misc-info t)
  ;; non-nil: Make `easysession-setup' load the session automatically.
  ;; (nil: session is not loaded automatically; the user can load it manually.)
  (setq easysession-setup-load-session t)

  ;; The `easysession-setup' function adds hooks:
  ;; - To enable automatic session loading during `emacs-startup-hook', or
  ;;   `server-after-make-frame-hook' when running in daemon mode.
  ;; - To save the session at regular intervals, and when Emacs exits.
  (easysession-setup))

(use-package eglot
  :custom
  (eglot-code-action-indications '(left-fringe)))

(add-hook! 'eshell-mode-hook (setenv "TERM" "xterm-256color"))

(require 'flash-isearch)
(require 'flash-evil)

(use-package flash
  :defer t
  :commands (flash-jump flash-treesitter)
  :init
  (flash-isearch-mode 1)
  (flash-char-setup-evil-keys)
  :custom
  (flash-rainbow t)
  (flash-char-multi-line t)
  (flash-char-jump-labels t))

(with-eval-after-load 'evil
  (evil-global-set-key 'normal (kbd "s") #'flash-evil-jump)
  (evil-global-set-key 'operator (kbd "s") #'flash-evil-jump)
  (evil-global-set-key 'motion (kbd "s") #'flash-evil-jump)
  (evil-global-set-key 'visual (kbd "s") #'flash-evil-jump))

(use-package flycheck
  :defer t
  :config
  (global-flycheck-annotate-mode))

(defun my/flyspell-prog-mode (&rest _args)

  "Enable `flyspell-prog-mode' with buffer-local Aspell arguments."
  ;; The --run-together flag instructs Aspell to accept words formed by
  ;; combining two or more valid dictionary words without spaces, treating the
  ;; resulting string as valid.
  ;;
  ;; This is excellent for source code. Code is heavily populated with
  ;; compound variable names and technical terms (e.g., filepath, buffername,
  ;; checkbox).
  ;; URL: https://www.jamescherti.com/emacs-spell-checker-flyspell-ispell-aspell/
  (setopt ispell-extra-args '("--sug-mode=ultra"
                              "--camel-case"
                              "--ignore=3"))
  (flyspell-prog-mode))

(defun my/flyspell-enable-appropriate-mode ()
  "Enable the appropriate Flyspell mode based on the current major mode."
  (if (or (derived-mode-p 'conf-mode)
          (derived-mode-p 'yaml-mode)
          (derived-mode-p 'prog-mode)
          (derived-mode-p 'yaml-ts-mode)
          (derived-mode-p 'ansible-mode)
          (derived-mode-p 'toml-ts-mode)
          (derived-mode-p 'lisp-interaction-mode)
          (derived-mode-p 'json-mode)
          (derived-mode-p 'json-ts-mode))
      (my/flyspell-prog-mode)
    (flyspell-mode 1)))

(with-eval-after-load 'flyspell
  (add-hook 'prog-mode-hook #'my/flyspell-prog-mode)
  (add-hook 'conf-mode-hook #'my/flyspell-enable-appropriate-mode)
  (add-hook 'text-mode-hook #'my/flyspell-enable-appropriate-mode))

(with-eval-after-load 'flycheck
  (add-to-list 'flycheck-org-lint-disabled-checkers `missing-language-in-src-block)
  (add-to-list 'flycheck-org-lint-disabled-checkers `percent-encoding-link-escape))

(use-package ispell
  :custom
  (ispell-dictionary "en_US")
  (ispell-program-name "aspell")
  (ispell-quietly t)
  (ispell-personal-dictionary "~/.config/doom/dict/.pws"))

(with-eval-after-load 'ispell
  (setopt ispell-extra-args '("--sug-mode=ultra"
                              "--camel-case"
                              "--ignore=3")))

(use-package ghostel
  :defer t
  :custom
  (ghostel-enable-osc52 t)
  (ghostel-tramp-shell-integration t)
  (add-to-list 'project-switch-commands '(ghostel-project "Ghostel") t))

(use-package evil-ghostel
  :after (ghostel evil)
  :hook (ghostel-mode . evil-ghostel-mode))

(use-package ghostel-eshell
  :hook (eshell-load . ghostel-eshell-visual-command-mode))

(use-package ghostel-comint
  :hook (after-init . ghostel-comint-global-mode))

(map! :leader "ot" #'ghostel)
(map! :leader "oT" #'ghostel-project)

(use-package indent-bars
  :defer t
  :custom
  (indent-bars-no-descend-lists 'skip)
  (indent-bars-pattern ".")
  (indent-bars-treesit-ignore-blank-lines-types '("module")))

(use-package just-mode
  :defer t
  :mode ("justfile\\'" . just-mode)
  :custom
  (just-indent-offset 2))

(use-package kdl-mode
  :defer t
  :mode ("\\.kdl\\'" . kdl-mode))

(use-package lsp-mode
  :defer t
  :custom
  (lsp-inlay-hint-enable t)
  (lsp-eldoc-render-all t)
  (lsp-rust-analyzer-display-chaining-hints t)
  (lsp-rust-analyzer-display-closure-return-type-hints t)
  (lsp-rust-analyzer-display-parameter-hints t)
  (lsp-headerline-breadcrumb-enable t)
  (lsp-enable-folding t)
  :config
  (lsp-register-custom-settings
   ;; Enable inlay hints in Go
   '(("gopls.hints" ((assignVariableTypes . t)
                     (compositeLiteralFields . t)
                     (compositeLiteralTypes . t)
                     (constantValues . t)
                     (functionTypeParameters . t)
                     (parameterNames . t)
                     (rangeVariableTypes . t)))))

  (lsp-register-client
   ;; Fish-LSP
   (make-lsp-client
    :new-connection (lsp-stdio-connection '("fish-lsp" "start"))
    :activation-fn (lsp-activate-on "fish")
    :server-id 'fish-lsp))
  (add-to-list 'lsp-language-id-configuration '(fish-mode . "fish"))

  (setopt lsp-semantic-tokens-enable t
          lsp-enable-relative-indentation t
          lsp-log-io nil))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :bind (:map lsp-ui-doc-mode-map
              ("M-k" . lsp-ui-doc-glance))
  :config
  (setopt lsp-ui-sideline-show-diagnostics nil))

(use-package markdown-indent-mode
  :hook (markdown-ts-mode . markdown-indent-mode))

(use-package markdown-ts-mode
  :mode ("\\.md\\'" "\\.mdx\\'" "\\.markdown\\'")
  :config
  (require 'markdown-ts-mode-x))

(setopt user-full-name "Elian Manzueta"
        user-mail-address "elianmanzueta@protonmail.com"

        ;; emacs
        confirm-kill-emacs nil
        auto-save-default t
        make-backup-files t
        auto-save-default t
        truncate-string-ellipsis "…"
        delete-by-moving-to-trash t
        kill-ring-max 200
        +whitespace-guess-in-projects t
        magit-show-long-lines-warning nil
        display-line-numbers-type 'relative
        projectile-project-search-path '(("~/projects/" . 3))

        which-key-idle-delay 0.3
        which-key-idle-secondary-delay 0.05)

(add-to-list 'exec-path "/home/elian/.local/bin/")

(map! :leader "y" #'consult-yank-from-kill-ring)

;; For systemd files
(add-to-list 'auto-mode-alist '("\\.service\\'" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.timer\\'" . conf-mode))

;; auto-fill-mode
(add-hook 'text-mode-hook #'auto-fill-mode)
(setq-default fill-column 80)

;; Remove white screen on start
(add-to-list 'initial-frame-alist '(background-color . "#000000"))

(setopt evil-want-fine-undo t
        evil-shift-width 2
        evil-want-C-i-jump t
        +evil-want-move-window-to-wrap-around t

        evil-split-window-below t
        evil-vsplit-window-right t)

;; From ~/.config/emacs/sources/doom+/modules/editor/evil/config.el
(with-eval-after-load 'evil-easymotion
  (map! :m "gs" (cons "Easymotion" evilem-map)
        ;; TODO: Use named functions
        (:map evilem-map
              "a" (evilem-create #'evil-forward-arg)
              "A" (evilem-create #'evil-backward-arg)
              "s" #'flash-jump
              "SPC" #'flash-treesitter
              "/" #'evil-avy-goto-char-timer)))

(setopt +dashboard-pwd-policy "~/"
        doom-scratch-initial-major-mode 'lisp-interaction-mode
        initial-scratch-message ";;; scratch-buffer -*- lexical-binding: t; -*-\n"

        ;; theme
        doom-font-increment 1
        doom-font (font-spec :family "IosevkaTerm Nerd Font Mono" :size 18 :weight 'regular))

(setq doom-theme 'catppuccin-mocha)

(when (>= emacs-major-version 31)
  (setopt treesit-enabled-modes t
          ibuffer-human-readable-size t
          treesit-auto-install-grammar 'always
          completion-eager-update t
          completion-eager-display 'auto))

(defun my/proton-drive-sync ()
  "Syncs org-mode directory to Proton Drive."
  (interactive)
  (when (file-exists-p "~/org/proton-drive-sync.fish")
    (async-shell-command "fish ~/org/proton-drive-sync.fish" "Org Proton Drive Sync")))

(use-package git-auto-commit-mode
  :defer t
  :custom
  (gac-automatically-push-p t)
  (gac-automatically-add-new-files-p t)
  (gac-debounce-interval 60)
  (gac-shell-and " ; and "))

(use-package org-agenda
  :after org
  :custom
  (org-agenda-timegrid-use-ampm t)
  (org-display-custom-times t)
  (org-time-stamp-custom-formats '("<%m/%d/%y %a>" . "<%m/%d/%y %a %I:%M %p>"))
  (org-agenda-custom-commands '(("j" "Journal" ((agenda ""
                                                        ((org-agenda-overriding-header "Agenda"\n)
                                                         (org-agenda-files '("~/org/journal.org"))
                                                         (org-agenda-show-log t)
                                                         (org-agenda-files '("~/org/journal.org"))))
                                                (todo ""
                                                      ((org-agenda-files '("~/org/journal.org"))))))

                                ("w" . "Work-related")
                                ("wo" "Overview" ((agenda ""
                                                          ((org-agenda-overriding-header "Agenda\n")
                                                           (org-agenda-span 'fortnight)
                                                           (org-agenda-show-log t)
                                                           (org-agenda-start-on-weekday 1)
                                                           (org-agenda-files '("~/org/work/"))))
                                                  (todo ""
                                                        ((org-agenda-overriding-header "Inbox\n")
                                                         (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo '("NOTE")))
                                                         (org-agenda-files '("~/org/work/work-inbox.org"))))
                                                  (todo "PROJECT"
                                                        ((org-agenda-overriding-header "Projects\n")
                                                         (org-agenda-sorting-strategy)
                                                         (org-agenda-files '("~/org/work/work-projects.org"))))
                                                  (todo ""
                                                        ((org-agenda-overriding-header "Scheduled\n")
                                                         (org-agenda-files '("~/org/work/work-scheduled.org"))
                                                         (org-agenda-skip-function '(org-agenda-skip-entry-if 'unscheduled))))
                                                  (todo "NOTE"
                                                        ((org-agenda-overriding-header "Notes\n")
                                                         (org-agenda-files '("~/org/work"))))))
                                ("wp" "Projects" todo "PROJECT")
                                ("ws" "Scheduled" tags-todo "scheduled")
                                ("wi" "Inbox" tags-todo "inbox"))))

(add-hook! 'org-mode-hook
  (set-popup-rules!
    '(("^\\*Org Agenda" :size 0.5 :side left))))

(use-package org-appear
  :hook (org-mode . org-appear-mode)
  :custom
  (org-appear-autolinks t)
  (org-appear-autoentities t)
  (org-appear-autokeywords t)
  (org-appear-trigger 'manual))

(add-hook 'org-mode-hook (lambda ()
                           (add-hook 'evil-insert-state-entry-hook
                                     #'org-appear-manual-start
                                     nil
                                     t)
                           (add-hook 'evil-insert-state-exit-hook
                                     #'org-appear-manual-stop
                                     nil
                                     t)))

(use-package org-block-wrap
  :hook (org-mode . org-block-wrap-mode))

(use-package org
  :defer t
  :config
  (defvar +org-capture-work-inbox-file "~/org/work/work-inbox.org")
  (defvar +org-capture-work-projects-file "~/org/work/work-projects.org")
  (defvar +org-capture-work-meetings-file "~/org/work/work-meetings.org")
  (defvar +org-capture-work-scheduled-file "~/org/work/work-scheduled.org")

  (map! :leader "nn" #'org-capture-goto-target)
  (map! :leader "nN" #'org-capture)

  (setq org-capture-templates '(("j" "Journal entry"
                                 entry (file+olp+datetree +org-capture-journal-file)
                                 (file "~/org/templates/journal.org")
                                 :prepend t
                                 :tree-type week)
                                ("w" "Work Templates")
                                ("wn" "Work note"
                                 entry (file+olp+datetree +org-capture-work-inbox-file)
                                 (file "~/org/templates/note.org")
                                 :prepend t
                                 :tree-type week)
                                ("wi" "Work inbox entry"
                                 entry (file+olp+datetree +org-capture-work-inbox-file)
                                 (file "~/org/templates/inbox-entry.org")
                                 :prepend t
                                 :tree-type week)
                                ("ws" "Scheduled work inbox entry"
                                 entry (file+headline +org-capture-work-scheduled-file "Scheduled")
                                 (file "~/org/templates/scheduled-entry.org")
                                 :prepend t)
                                ("wp" "Work projects"
                                 entry (file+headline +org-capture-work-projects-file "Work Projects")
                                 (file "~/org/templates/project.org")
                                 :prepend t)
                                ("wm" "Work meeting"
                                 entry (file+headline +org-capture-work-scheduled-file "Meetings")
                                 (file "~/org/templates/meeting.org")
                                 :prepend t))))

(use-package org-attach
  :after org
  :custom
  (org-attach-id-dir "~/org/.attach")
  (org-attach-auto-tag nil)
  (org-attach-store-link-p 'file)
  (org-attach-id-to-path-function-list '(org-attach-id-ts-folder-format
                                         org-attach-id-uuid-folder-format
                                         org-attach-id-fallback-folder-format))
  (org-id-method 'ts)
  (org-id-ts-format "%Y-%m-%dT%H%M%S.%6N"))

(use-package org-download
  :after org
  :custom
  (org-download-image-org-width '450)
  (org-download-image-dir "~/org/.attach"))

(use-package org-habit-ng
  :hook (org-mode . org-habit-ng-mode))

(custom-set-faces!
  '(org-document-title :weight extra-bold :height 1.3)
  '(org-verbatim :inherit bold :weight extra-bold)
  '(org-quote :inherit modus-themes-fixed-pitch :slant italic))

(use-package org
  :defer t
  :config
  (setopt org-hide-emphasis-markers t
          org-fontify-quote-and-verse-blocks t
          org-auto-align-tags nil
          org-tags-column 0
          org-agenda-tags-column 0
          org-startup-folded 'content
          org-directory "~/org/"
          org-agenda-files '("~/org/work/work-inbox.org"
                             "~/org/work/work-projects.org"
                             "~/org/work/work-scheduled.org")
          org-log-done 'time
          org-log-into-drawer t
          org-agenda-hide-tags-regexp "todo\\|work\\|workinfo\\|daily\\|scheduled"
          org-safe-remote-resources '("\\`https://fniessen\\.github\\.io\\(?:/\\|\\'\\)")
          org-ellipsis " ▼")

  ;; Supresses warning I get with setopt
  (setq org-emphasis-alist '(("*" org-verbatim bold)
                             ("/" italic)
                             ("_" underline)
                             ("=" org-verbatim verbatim)
                             ("~" org-code verbatim)
                             ("+" (:strike-through t))))

  ;; Multi-line emphasis in org-mode
  (setcar (nthcdr 4 org-emphasis-regexp-components) 20)
  (org-set-emph-re 'org-emphasis-regexp-components org-emphasis-regexp-components))

(with-eval-after-load 'org
  (add-hook 'org-mode-hook (lambda () (display-line-numbers-mode -1))))

;; org-yas-expand-maybe-h lags the absolute fuck out of Org.
;; disable it.
(with-eval-after-load 'evil-org
  (map! :map evil-org-mode-map
        :n "zi" #'org-link-preview)
  (remove-hook 'org-tab-first-hook #'+org-yas-expand-maybe-h))

(use-package org-modern
  :after org
  :custom
  (org-modern-star 'replace)
  (org-modern-replace-stars "◉○✸✿")
  (org-modern-block-name '("‣ " . "‣ "))
  (org-modern-timestamp t)
  (org-modern-keyword "‣ ")
  (org-modern-table t)
  (org-modern-todo t))

(setopt org-pandoc-options-for-docx
        '((reference-doc . "~/.pandoc/templates/word-reference.docx")))

(use-package org-roam
  :after org
  :custom
  (org-roam-node-default-sort 'file-mtime)
  (org-roam-file-exclude-regexp (list "~/org/.attach/"))

  (org-roam-capture-templates
   '(("d" "default" plain (file "~/org/roam/templates/default.org")
      :if-new (file "%<%Y%m%d%H%M%S>-${slug}.org")
      :unnarrowed t)
     ("s" "study" plain (file "~/org/roam/templates/study.org")
      :if-new (file "%<%Y%m%d%H%M%S>-${slug}.org")
      :unarrowed t)
     ("w" "work" plain (file "~/org/roam/templates/default.org")
      :if-new (file "work/%<%Y%m%d%H%M%S>-${slug}.org")
      :unarrowed t))))

(use-package websocket :after org-roam)
(use-package org-roam-ui
  :after org-roam
  :custom
  (org-roam-ui-follow t)
  (org-roam-ui-update-on-save t)
  (org-roam-ui-open-on-start t))

(use-package org-tidy
  :after org
  :bind (:map org-mode-map
              ("C-c t" . org-tidy-mode))
  :custom
  (org-tidy-properties-style 'invisible))

(with-eval-after-load 'org
  (setopt +org-capture-todo-file "inbox.org")

  (setopt org-todo-keywords
          '((sequence "TODO(t)" "PROJECT(p)" "MEETING(m)" "IN-PROGRESS(i@/!)" "|" "DONE(d!)" "WONT-DO(w@/!)")
            (sequence "[ ](T)" "[-](S)" "[?](W)" "|" "[X](D)")
            (sequence "|" "OKAY(o)" "YES(y)" "NO(n)")
            (sequence "NOTE(N)" "HOLD(h)" "|")))

  (setopt org-todo-keyword-faces
          '(("[-]" . +org-todo-active) ("STRT" . +org-todo-active)
            ("[?]" . +org-todo-onhold) ("WAIT" . +org-todo-onhold)
            ("HOLD" . +org-todo-onhold) ("PROJECT" . +org-todo-project)
            ("NO" . +org-todo-cancel) ("KILL" . +org-todo-cancel)
            ("NOTE" . +org-todo-project)))

  (setopt org-modern-todo-faces
          '(("KILL" :inverse-video t :inherit +org-todo-cancel)
            ("NO" :inverse-video t :inherit +org-todo-cancel)
            ("PROJECT" :inverse-video t :foreground +org-todo-project)
            ("HOLD" :inverse-video t :inherit +org-todo-onhold)
            ("WAIT" :inverse-video t :inherit +org-todo-onhold)
            ("[?]" :inverse-video t :inherit +org-todo-onhold)
            ("STRT" :inverse-video t :inherit +org-todo-active)
            ("NOTE" :inverse-video t :inherit +org-todo-project)
            ("[-]" :inverse-video t :inherit +org-todo-active))))

(defun my/popterm-toggle ()
  "Toggle the terminal popup."
  (interactive)
  (popterm-toggle "scratch-term"))

(use-package popterm
  :defer t
  :bind (("C-|" . my/popterm-toggle))
  :custom
  (popterm-backend 'ghostel)
  (popterm-scope 'project)
  (popterm-display-method 'posframe)
  (popterm-auto-cd t)
  (popterm-cd-string (current-buffer))
  :config
  (popterm-global-mode 1))

(use-package powershell
  :mode ("\\.ps1\\'" . powershell-mode)
  :hook (powershell-mode . lsp-mode)
  :config
  (setopt powershell-location-of-exe "/mnt/c/Program Files/Powershell/7/pwsh.exe")
  (setopt lsp-pwsh-exe "/mnt/c/Program Files/Powershell/7/pwsh.exe"))

(use-package ssh-config-mode
  :defer t
  :config
  (add-to-list 'auto-mode-alist '("/\\.ssh/config\\(\\.d/.*\\.conf\\)?\\'" . ssh-config-mode))
  (add-to-list 'auto-mode-alist '("/sshd?_config\\(\\.d/.*\\.conf\\)?\\'"  . ssh-config-mode))
  (add-to-list 'auto-mode-alist '("/known_hosts\\'"       . ssh-known-hosts-mode))
  (add-to-list 'auto-mode-alist '("/authorized_keys2?\\'" . ssh-authorized-keys-mode)))

(add-hook 'ssh-config-mode-hook 'turn-on-font-lock)

;; Most of this is from *Making TRAMP go Brrrr*
;; https://coredumped.dev/2025/06/18/making-tramp-go-brrrr./
(with-eval-after-load 'tramp
  (with-eval-after-load 'compile
    (remove-hook 'compilation-mode-hook #'tramp-compile-disable-ssh-controlmaster-options)))

(use-package tramp
  :defer t
  :init
  (connection-local-set-profile-variables
   'remote-direct-async-process
   '((tramp-direct-async-process . t)))

  (connection-local-set-profiles
   '(:application tramp :protocol "scp")
   'remote-direct-async-process)

  (connection-local-set-profiles
   '(:application tramp :protocol "ssh")
   'remote-direct-async-process)

  (setopt vc-ignore-dir-regexp (format "\\(%s\\)\\|\\(%s\\)"
                                       vc-ignore-dir-regexp
                                       tramp-file-name-regexp)
          magit-tramp-pipe-stty-settings 'pty
          enable-remote-dir-locals t
          tramp-default-remote-shell "/bin/bash"))

(use-package tramp-hlo
  :after tramp
  :custom
  (tramp-hlo-setup))

(use-package msgpack
  :defer t)
(use-package tramp-rpc
  :defer t
  :custom
  (tramp-rpc-deploy-git-build-policy 'release))

(with-eval-after-load 'undo-fu
  (setopt undo-limit 80000000 ;; 80mb
          undo-strong-limit 100000000 ;; 100mb
          undo-outer-limit  72000000)) ;; 72mb

(use-package verb
  :after org
  :init
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((verb . t)))
  :config (define-key org-mode-map (kbd "C-c C-r") verb-command-map))

(use-package vertico
  :defer t
  :custom
  (vertico-buffer-display-action '(display-buffer-reuse-window))

  (vertico-multiform-categories
   '((symbol (vertico-sort-function . vertico-sort-alpha))
     (file (vertico-sort-function . vertico-sort-history-alpha)))))

(use-package vertico-directory
  :after vertico
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package vertico-posframe-preview
  :after vertico
  :config
  (vertico-posframe-preview-mode 1))

(use-package vterm
  :defer t
  :custom
  (vterm-shell explicit-shell-file-name)
  (vterm-buffer-name-string "vterm: %s"))

(add-load-path! "~/emacs-libvterm")
