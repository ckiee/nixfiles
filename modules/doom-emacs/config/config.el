(setq user-full-name "ckie"
      user-mail-address "us@ckie.dev")
(load "~/.config/doom-nix-bins.el")
(setq doom-theme 'doom-sourcerer-cookie)
(setq doom-font (font-spec :family "JetBrains Mono" :size 13)
      doom-variable-pitch-font (font-spec :family "Inter" :size 16))
(setq doom-big-font-increment 3)
(setq display-line-numbers-type 'relative)
(setq scroll-margin 8)
(setq-default fill-column 100)
;; (add-to-list 'default-frame-alist '(alpha-background . 0))
(defun ckie--suppress-messages (func &rest args)
  "Suppress message output from FUNC."
  ;; Some packages are too noisy.
  ;; https://superuser.com/questions/669701/emacs-disable-some-minibuffer-messages
  (cl-flet ((silence (&rest args1) (ignore)))
    (advice-add 'message :around #'silence)
    (unwind-protect
        (apply func args)
      (advice-remove 'message #'silence))))

;; Suppress "Cleaning up the recentf...done (0 removed)"
(advice-add 'recentf-cleanup :around #'ckie--suppress-messages)
(map! :leader "f P" (cmd! (doom-project-browse "~/git/nixfiles/modules/doom-emacs/config/")))
(defun ckie-count-buffers (&optional display-anyway)
  "Display or return the number of buffers."
  (interactive)
  (let ((buf-count (length (buffer-list))))
    (if (or (interactive-p) display-anyway)
        (message "%d buffers in this Emacs" buf-count)) buf-count))
(map! :leader "b c" #'ckie-count-buffers)
(after! mu4e (setq mu4e-index-lazy-check '()))
(after! doom-modeline (setq doom-modeline-mu4e nil))
(after! mu4e
  (setq sendmail-program (executable-find "msmtp")
        send-mail-function #'smtpmail-send-it
        message-sendmail-f-is-evil t
        message-sendmail-extra-arguments '("--read-envelope-from")
        message-send-mail-function #'message-send-mail-with-sendmail))
(setq mu4e-headers-date-format "%d/%m/%y")
(setq mu4e-headers-time-format "%d/%m/%y %l:%M:%S %p")
(after! mu4e
  (map! :map mu4e-view-mode-map :n "C--" #'text-scale-decrease))
(after! mu4e
    (add-hook 'mu4e-compose-mode-hook (lambda () (smartparens-mode 0))))
(after! mu4e
    (setq mu4e-sent-folder "/ckiedev/Sent"))
(setq org-directory "~/Sync/org/")
(add-hook 'org-mode-hook #'writeroom-mode)
(add-hook 'org-mode-hook #'hl-todo-mode)
(setq writeroom-width 70)
(setq writeroom-mode-line t)
(setq org-clock-persist 'history)
(org-clock-persistence-insinuate)
(add-to-list 'auto-mode-alist '("\\.svx\\'" . markdown-mode))
(setq lsp-clients-lua-language-server-bin "lua-language-server")
(setq! lsp-disabled-clients '(vue-semantic-server))
(add-load-path! "vendor")
(require 'brightscript-mode)
(add-to-list 'auto-mode-alist '("\\.brs\\'" . brightscript-mode))
; pretend we also know BrighterScript
(add-to-list 'auto-mode-alist '("\\.bs\\'" . brightscript-mode))
(defun ckie--vertico-go-to-home ()
  "Navigate vertico to the user's home directory"
  (interactive)
  (beginning-of-line)
  (let ((pt (point))) (end-of-line) (delete-region pt (point)))
  (insert "~/"))
; broken because of https://github.com/minad/vertico/issues/214
(after! vertico (map! :map vertico-map "~" #'ckie--vertico-go-to-home))
(defun ckie-refresh-projectile-known-list ()
  (interactive)
  "Adds all directories from ~/git to projectile-known-projects"
  (setq projectile-known-projects
        (-distinct (append
                    projectile-known-projects
                    (--filter (f-directory? it) (mapcar (lambda (x) (format "~/git/%s/" x))
                                                        (nthcdr 2 (directory-files "~/git"))))))))

(after! projectile
  (advice-add 'projectile-switch-project :before #'ckie-refresh-projectile-known-list))
(advice-add '+workspace-switch
            :around (lambda
                      (orig-fn &rest r)
                      (setq nix-nixfmt-bin (if (string= (car r) "nixpkgs") "nixpkgs-fmt" "nixfmt"))
                      (apply orig-fn r)))

(after! format-all (define-format-all-formatter nixfmt
    (:executable "nixfmt")
    (:install "nix-env -f https://github.com/serokell/nixfmt/archive/master.tar.gz -i")
    (:modes nix-mode)
    (:format (format-all--buffer-easy (if (string= (+workspace-current-name) "nixpkgs") "nixpkgs-fmt" "nixfmt")))))
(after! vertico (map!
    :map vertico-map
        :g "<prior>" 'vertico-scroll-down
        :g "<next>" 'vertico-scroll-up))
(defun ckie-advice-unadvice (sym)
  "Remove all advices from symbol SYM."
  (interactive "aFunction symbol: ")
  (advice-mapc (lambda (advice _props) (advice-remove sym advice)) sym))
(map! :leader :n "h d k" #'ckie-advice-unadvice)
(defun ckie-startup-init-state ()
  "Initalize Emacs state to satisfy mei"
  (interactive)
  (advice-remove 'projectile-switch-project #'ckie-refresh-projectile-known-list)
  (setq +workspaces-switch-project-function #'find-file)
  (f-touch (concat doom-cache-dir (f-path-separator) ".projectile"))
  (dolist (name `("~/Sync/" "~/git/nixfiles/" "~/git/nixpkgs/" ,doom-cache-dir))
    (+workspace/new)
    (projectile-switch-project-by-name name))
  (=mu4e) ; *mu4e* workspace, it eats the current workspace so we opened a dummy one.
  (+workspace/delete "main")
  (setq +workspaces-switch-project-function #'doom-project-find-file)
  (advice-add 'projectile-switch-project :before #'ckie-refresh-projectile-known-list))

(map! :leader :n "q k" #'ckie-startup-init-state)
; (add-hook 'after-init-hook #'ckie-startup-init-state) ;runs too early
(advice-add 'consult-theme :after (lambda (&rest r)
                                     (setq doom-theme nil)))
(add-hook 'c-mode-hook (lambda ()
  (when (and buffer-file-name
             (or (-any? (lambda (x) (string-match x buffer-file-name)) '("chocolate-doom" "crispy-doom")))
    (c-set-style "bsd")
    (setq indent-tabs-mode nil)
    (setq tab-width 8)
    (setq c-basic-offset 4)))))
(map! :leader "c X" #'flycheck-list-errors)
(add-hook 'rust-mode-hook 'flycheck-popup-tip-mode)
(map! :leader "g o y" #'bar-to-clipboard)
(map! :leader "g c v" #'magit-commit-instant-fixup)
(put 'magit-log-mode 'magit-log-default-arguments '("-n512" "--decorate"))
(map! :mode emmet-mode :i "TAB" #'+web/indent-or-yas-or-emmet-expand)
(setq-default frame-title-format '((:eval (buffer-name (window-buffer (minibuffer-selected-window))))))
(load-library "ox-reveal")
(define-globalized-minor-mode global-mixed-pitch-mode mixed-pitch-mode mixed-pitch-mode)
(setq lsp-rust-analyzer-display-chaining-hints t
      lsp-rust-analyzer-display-parameter-hints t
      lsp-rust-analyzer-closing-brace-hints t)
(after! spell-fu (remove-hook 'text-mode-hook #'spell-fu-mode))
(after! gptel
        (setq! gptel-model 'gpt-4o)
        (map! :leader "l l" #'gptel-menu)
        (map! :leader "l r" #'gptel-rewrite)
        (map! :mode gptel-context-buffer-mode :n "d" #'gptel-context-flag-deletion))
