;;; early-init.el --- Early init  -*- lexical-binding: t; -*-

;;; Commentary:

;; This is the early init file.

;;; Code:

;; Load the automatic customization file.
(setopt custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))

;; Delay GC while Emacs is booting.
(setopt gc-cons-threshold most-positive-fixnum
        gc-cons-percentage 0.6)
;; Reset them to sensible defaults after booting.
(defun my--reset-gc-params ()
  "Reset some GC parameters to sensible defaults."
  (setopt gc-cons-threshold (* 100 1024 1024)
          gc-cons-percentage 0.1))
(add-hook 'after-init-hook #'my--reset-gc-params)

;; Disable native compilation if on battery power.
(setopt native-comp-async-on-battery-power nil) ; Emacs 31

;; Window management tweaks.
(setopt frame-resize-pixelwise t
        frame-inhibit-implied-resize t) ; Emacs 31
(setq frame-title-format
      '(""
        (:eval
         (let ((project (project-current)))
           (if project
               (concat "[p] " (project-name project))
             "%b")))
        (multiple-frames "" (" - GNU Emacs at " system-name))))

;; Avoid raising the *Messages* buffer is anything is still without
;; lexical bindings.
(setopt warning-minimum-level :error
        warning-suppress-types '((lexical-binding)))

;; Configure suitable fonts according to the availability on the system.
(defconst my-font-presets
  '((sarasa . ((default . "Sarasa Term SC")
               (fixed-pitch . "Sarasa Fixed SC")
               (fixed-pitch-serif . "Sarasa Fixed Slab SC")
               (variable-pitch . "Sarasa UI SC")))
    (windows-11 . ((default . "Cascadia Code")
                   (fixed-pitch . "Cascadia Mono")
                   (variable-pitch . "Segoe UI Variable Small")))
    (windows-vista . ((default . "Consolas")
                      (variable-pitch . "Segoe UI")))
    (kde-plasma . ((default . "Hack")
                   (variable-pitch . "Noto Sans")))
    (gnome . ((default . "DejaVu Sans Mono")
              (variable-pitch . "Cantarell")))
    (noto . ((default . "Noto Sans Mono")
             (variable-pitch . "Noto Sans")))
    (dejavu . ((default . "DejaVu Sans Mono")
               (variable-pitch . "DejaVu Sans")))
    (windows-2000 . ((default . "Lucida Console")
                     (variable-pitch . "Tahoma"))))
  "All available font presets for various platforms.")
(defun my-font-preset-get-first-available (&optional frame)
  "Find the first available font preset of the FRAME."
  (let ((families (font-family-list frame)))
    (catch 'preset
      (dolist (preset my-font-presets)
        (when (catch 'family
                (dolist (family (mapcar #'cdr (cdr preset)))
                  (unless (member family families)
                    (throw 'family nil)))
                t)
          (throw 'preset preset)))
      nil)))
(defun my-font-preset-apply (preset &optional frame)
  "Apply the given PRESET to the FRAME."
  (message "Applying font preset %s..." (car preset))
  (dolist (face-pair (cdr preset))
    (if (eq (car face-pair) 'default)
        (set-face-attribute 'default frame :family (cdr face-pair) :height 105)
      (set-face-attribute (car face-pair) frame :family (cdr face-pair)))))
(defun my-font-preset-apply-auto (&optional frame)
  "Find the first available font preset and apply to the FRAME."
  (when (display-graphic-p frame)
    (let ((preset (my-font-preset-get-first-available frame)))
      (if preset
          (my-font-preset-apply preset frame)
        (message "No suitable font preset found.")))))
(add-hook 'after-make-frame-functions #'my-font-preset-apply-auto)

;; Scale fringe widths according to display DPIs.
(defun my-reset-fringe-width (&optional frame)
  "Reset width of left & right fringes of the FRAME to 8 (the default)."
  (when (display-graphic-p frame)
    (let* ((dpi (/ (display-pixel-width frame)
                   (/ (display-mm-width frame) 25.4)))
           (scaling (/ dpi 96))) ; 96 is the default on Windows.
      (with-selected-frame frame
        (set-fringe-style (round (* 8 scaling)))))))
(add-hook 'after-make-frame-functions #'my-reset-fringe-width)

;; Explicitly set default geometry of frames.
(setopt default-frame-alist '((width . 80) (height . 40)))

(provide 'early-init)
;;; early-init.el ends here
