;;; -*- lexical-binding: t; -*-
(require 'json)

(defun nix-straight-get-used-packages (init-file)
  (let ((nix-straight--packages nil))
    ;; (advice-add 'straight-use-package
    ;;             :override (lambda (recipe &rest r)
    ;;                         (let ((pkg (if (listp recipe)
    ;;                                           (car recipe)
    ;;                                      recipe)))
    ;;                           (message "[nix-straight.el] Collecting package '%s' from recipe '%s'" pkg recipe)
    ;;                           (add-to-list 'nix-straight--packages pkg))))
    (defun his-tracing-function (orig-fun &rest args)
      (message "straight-vc called with args %S" args)
      (let ((res (apply orig-fun args)))
        (message "straight-vc returned %S" res)
        res))

    (advice-add 'straight-vc :around #'his-tracing-function)
    (load init-file nil nil t)
    ;; (princ (json-encode doom-packages))

    nix-straight--packages))

(defun nix-straight-build-packages (init-file)
  (setq straight-default-files-directive '("*" (:exclude "*.elc")))
  (advice-add 'straight-use-package
              :around (lambda (orig-fn &rest r)
                        (message "     [nix-straight.el] Overriding recipe for '%s'" (car r))
                        (let* ((pkg (car r))
                               (pkg-name (symbol-name pkg))
                               (recipe (if (file-exists-p (straight--repos-dir pkg-name))
                                           (list pkg :local-repo pkg-name :repo pkg-name :type 'git)
                                         (list pkg :type 'built-in))))
                          (message "     --> [nix-straight.el] Recipe generated: %s" recipe)
                          (straight-override-recipe recipe))
                        (apply orig-fn r)))
  (load init-file nil nil t))

(provide 'setup)
;;; setup.el ends here
