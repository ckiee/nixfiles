;;; mc-debug-func.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2021 ckie
;;
;; Author: ckie <https://ckie.dev>
;; Maintainer: ckie <us@ckie.dev>
;; Created: August 29, 2021
;; Modified: August 29, 2021
;; Version: 0.0.1
;; Keywords: Symbol’s value as variable is void: finder-known-keywords
;; Homepage: https://github.com/ckiee/nixfiles
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:
(require 'generic)

(define-generic-mode 'mcf-debug-mode
  ()
  ()
  '(
    ("\\[\\(C\\|M\\|R = -?[[:digit:]]+\\)]". 'font-lock-keyword-face)
    ("\\[R = \\(-?[[:digit:]]+\\)]"1 'font-lock-constant-face t)
    ("\\(size\\)=\\(-?[[:digit:]]+\\)" (1 'font-lock-keyword-face) (2 'font-lock-constant-face))
    ("\\[F]" . 'font-lock-warning-face)
    ("[a-z0-9_.+-:]+:\\(?:[a-z0-9_.+-:]+/?\\)" . 'font-lock-function-name-face)
    )
  '("debug-trace-[[:digit:]]+-..-.._..\...\...\.txt")
  nil
  "Major mode for editing minecraft /debug function traces")

;; [C] <command> means the <command> is executed.
;; [M] <message> means a message is returned.
;; [E] <message> means a failure message is returned.
;; [R = -55] <command> means the <command> returns a brigadier return value.
;; [C] <command> -> <num> means the <command> is executed and returns a brigadier return value.
;; [F] <function> size=-95 means a function is called.
;; arc86:foo/super_bar/y33t

(provide 'mc-debug-func)
;;; mc-debug-func.el ends here
