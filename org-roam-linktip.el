;;; org-roam-linktip.el --- Display a linked contents in org-roam system on the tooltip -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Tomoyuki Murakami

;; Author: Tomoyuki Murakami <tomoyukim@outlook.com>
;; Version: 0.1.0
;; Package-Version: 20230204.1
;; Package-Commit: xxx
;; Description: Display a linked contents in org-roam system on the tooltip
;; Homepage: https://github.com/tomoyukim/org-roam-linktip
;; Package-Requires: ((emacs "25.1") (org-roam "2.0.0"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; org-roam-linktip is an extension of org-roam.
;; This package provides a function to show linked contents on the posframe in org-roam system.

;;; TODO:

;; * distribute on MELPA
;; * automatically show posframe when the cursor on the link

;;; Code:
(require 'posframe)
(require 'org-roam)

(defgroup org-roam-linktip nil
  "Minor mode to display linked contents instantly in org-roam system."
  :prefix "org-roam-linktip-"
  :group 'convenience)

(defcustom org-roam-linktip-border-color "gray30"
  "Color used to show the border of posframe."
  :type 'string
  :group 'org-roam-linktip)

(defcustom org-roam-linktip-border-width 2
  "Witdh used to show the border of posframe."
  :type 'number
  :group 'org-roam-linktip)

(defcustom org-roam-linktip-background-color nil
  "Background color to show the border of posframe."
  :type 'string
  :group 'org-roam-linktip)

(defun org-roam-linktip--get-contents (id)
  (let* ((node (or (org-roam-id-find id)
                   (org-id-find id)))
        (file (car node))
        (pos (cdr node)))
    (org-roam-preview-get-contents file pos)))

(defun org-roam-linktip--show (contents id)
  (let ((buffer (get-buffer-create (format "*org-roam-linktip*" id))))
    (with-current-buffer buffer
      (org-mode))
    (posframe-show buffer
                   :string contents
;;                   :width 100
                   :background-color org-roam-linktip-background-color
                   :internal-border-width org-roam-linktip-border-width
                   :internal-border-color org-roam-linktip-border-color)))

(defun org-roam-linktip-show ()
  "Show the linked content in org-roam system on a popframe"
  (interactive)
  (let* ((link (org-element-lineage (org-element-context) '(citation link) t))
         (type (org-element-property :type link))
         (id (org-element-property :path link)))
    (if (and (string= type "id") (not (string= "" id)))
        (org-roam-linktip--show (org-roam-linktip--get-contents id) id)
      (message "Not an available org-roam link."))))

(defun org-roam-linktip--pre-cmd ()
  "Function called by local `pre-command-hook' in `org-roam-linktip-mode'."
  (posframe-delete "*org-roam-linktip*"))

;; (defun org-roam-linktip--kill-buffer ()
;;   "Function called by local `kill-buffer-hook' in `org-roam-linktip-mode'."
;;   (posframe-delete "*org-roam-linktip*"))

;;;###autoload
(defvar org-roam-linktip-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c t") 'org-roam-linktip-show)
    map))

;;;###autoload
(define-minor-mode org-roam-linktip-mode
  "Minor mode to display linked contents instantly in org-roam system."
  :init-value nil
  :lighter nil
  :keymap org-roam-linktip-mode-map

  (cond
   (org-roam-linktip-mode
    (add-hook 'pre-command-hook #'org-roam-linktip--pre-cmd nil t)
;;    (add-hook 'kill-buffer-hook #'org-roam-linktip--kill-buffer nil t)
    )
   (t
    (remove-hook 'pre-command-hook #'org-roam-linktip--pre-cmd t)
;;    (remove-hook 'kill-buffer-hook #'org-roam-linktip--kill-buffer t)
    )))


(provide 'org-roam-linktip)
;;; org-roam-linktip.el ends here
