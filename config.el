;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-dark+)
;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;;
;;
;; ---------------------------------------------------------

;; Table of Contents:
;; 1. Whitespace Mode
;; 2. WSL Copy/paste
;; 3. Projectile Additions
;; 4. Other changes

;; 1. Whitespace Mode
(global-whitespace-mode 1)
(setq whitespace-line-column 127)

;; for [PL with Eli Barzilay](https://pl.barzilay.org/)
(add-hook 'racket-mode-hook
          (lambda ()
            (setq whitespace-line-column 80)))

;; 2. WSL Copy/paste
(defun wsl-copy (start end)
  (interactive "r")
  (let ((default-directory "/mnt/c"))
  (shell-command-on-region start end "clip.exe")))
(map! :leader
      :desc "Copy to os clipboard" "dc" 'wsl-copy)

(defun wsl-paste ()
  (interactive)
      (let ((wslbuffername "wsl-temp-buffer"))
    (get-buffer-create wslbuffername)
    (with-current-buffer wslbuffername
      (insert (let ((coding-system-for-read 'dos))
                (shell-command "powershell.exe -command 'Get-Clipboard' 2> /dev/null"
                               wslbuffername nil))))
    (insert-buffer-substring wslbuffername 2)
      (kill-buffer wslbuffername)))
(map! :leader
      :desc "Paste from os clip" "dp" 'wsl-paste)

;; 3. Projectile Additions
(map! :leader
      :desc "Search through project" "pS" '+ivy/project-search)

;; 4. Other changes
(super-save-mode 1)

(face-spec-set
 'tuareg-font-lock-constructor-face
 '((((class color) (background light)) (:foreground "SaddleBrown"))
   (((class color) (background dark)) (:foreground "#FF69B4"))
   (((class color) (type tty)) (:foreground "white"))))

  (defun doom*fix-broken-smie-modes (orig-fn arg)
    (let ((dtrt-indent-run-after-smie dtrt-indent-run-after-smie))
      (cl-letf* ((old-smie-config-guess (symbol-function 'smie-config-guess))
                 ((symbol-function 'smie-config-guess)
                  (lambda ()
                    (condition-case _ (funcall old-smie-config-guess)
                      (error (setq dtrt-indent-run-after-smie t))))))
        (funcall orig-fn arg))))
(advice-add #'dtrt-indent-mode :around #'doom*fix-broken-smie-modes)

;; produce message containing the face for the text under the cursor
(defun what-face (pos)
  (interactive "d")
  (hl-line-mode -1)
  (let ((face (or (get-char-property (point) 'read-face-name)
                  (get-char-property (point) 'face))))
    (hl-line-mode +1)
    (if face (message "Face: %s" face) (message "No face at %d" pos))))

(defun create-taipan ()
  (interactive)
  (let ((fname (read-string "Taipan file name: ")))
    (shell-command (concat "touch " fname ".taipan"))
    (shell-command (concat "touch " fname ".err"))
    (shell-command (concat "touch " fname ".options"))
    (shell-command (concat "echo check >" fname ".options"))
    (find-file (concat fname ".taipan"))
    (split-window-right)
    (other-window 1)
    (find-file (concat fname ".err"))
    (other-window 1)))

(defun doom-dashboard-draw-ascii-banner-fn ()
  (let*
      ((banner
        '("If pretty little blue birds fly"
          "beyond the rainbow"
          "why then oh why can't I?"
          " "
          " "
          " "
          "RIP Dayton Bryant 2001-2019"
          " "
          ))

      ;; ((banner
        ;;   '("=================     ===============     ===============   ========  ========"
        ;;     "\\\\ . . . . . . .\\\\   //. . . . . . .\\\\   //. . . . . . .\\\\  \\\\. . .\\\\// . . //"
        ;;     "||. . ._____. . .|| ||. . ._____. . .|| ||. . ._____. . .|| || . . .\\/ . . .||"
        ;;     "|| . .||   ||. . || || . .||   ||. . || || . .||   ||. . || ||. . . . . . . ||"
        ;;     "||. . ||   || . .|| ||. . ||   || . .|| ||. . ||   || . .|| || . | . . . . .||"
        ;;     "|| . .||   ||. _-|| ||-_ .||   ||. . || || . .||   ||. _-|| ||-_.|\\ . . . . ||"
        ;;     "||. . ||   ||-'  || ||  `-||   || . .|| ||. . ||   ||-'  || ||  `|\\_ . .|. .||"
        ;;     "|| . _||   ||    || ||    ||   ||_ . || || . _||   ||    || ||   |\\ `-_/| . ||"
        ;;     "||_-' ||  .|/    || ||    \\|.  || `-_|| ||_-' ||  .|/    || ||   | \\  / |-_.||"
        ;;     "||    ||_-'      || ||      `-_||    || ||    ||_-'      || ||   | \\  / |  `||"
        ;;     "||    `'         || ||         `'    || ||    `'         || ||   | \\  / |   ||"
        ;;     "||            .===' `===.         .==='.`===.         .===' /==. |  \\/  |   ||"
        ;;     "||         .=='   \\_|-_ `===. .==='   _|_   `===. .===' _-|/   `==  \\/  |   ||"
        ;;     "||      .=='    _-'    `-_  `='    _-'   `-_    `='  _-'   `-_  /|  \\/  |   ||"
        ;;     "||   .=='    _-'          '-__\\._-'         '-_./__-'         `' |. /|  |   ||"
        ;;     "||.=='    _-'                                                     `' |  /==.||"
        ;;     "=='    _-'                         E M A C S                          \\/   `=="
        ;;     "\\   _-'                                                                `-_   /"
        ;;     " `''                                                                      ``'"))
         (longest-line (apply #'max (mapcar #'length banner))))
    (put-text-property
     (point)
     (dolist (line banner (point))
       (insert (+doom-dashboard--center
                +doom-dashboard--width
                (concat
                 line (make-string (max 0 (- longest-line (length line)))
                                   32)))
               "\n"))
     'face 'doom-dashboard-banner)))

;; I had a dream my life would be so different from this hell I'm living
;; In Spain but the pain is silent
;; We can start and finish wars/we're what killed the dinosaurs/we're the asteroid that's overdue
;;
