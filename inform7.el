;;; inform7.el --- Major mode for working with Inform 7 files.

;; Copyright (C) 2020 Ben Moon
;; Author: Ben Moon <software@guiltydolphin.com>
;; URL: https://github.com/GuiltyDolphin/inform7-mode
;; Git-Repository: git://github.com/GuiltyDolphin/inform7-mode.git
;; Created: 2020-04-11
;; Version: 0.0.0
;; Keywords: languages
;; Package-Requires: ()

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; inform7-mode provides a major mode for interacting with files
;; written in Inform 7 syntax.
;;
;; For more information see the README.

;;; Code:


;;;;;;;;;;;;;;;;;;;;;
;;;;; Font Lock ;;;;;
;;;;;;;;;;;;;;;;;;;;;


(require 'font-lock)

(defgroup inform7-faces nil
  "Faces used in Inform 7 mode."
  :group 'inform7
  :group 'faces)

(defface inform7-heading-volume-face
  '((t . (:inherit inform7-heading-book-face :height 1.4)))
  "Face for Inform 7 volume headings."
  :group 'inform7-faces)

(defface inform7-heading-book-face
  '((t . (:inherit inform7-heading-part-face :height 1.3)))
  "Face for Inform 7 book headings."
  :group 'inform7-faces)

(defface inform7-heading-part-face
  '((t . (:inherit inform7-heading-chapter-face :height 1.2)))
  "Face for Inform 7 part headings."
  :group 'inform7-faces)

(defface inform7-heading-chapter-face
  '((t . (:inherit inform7-heading-section-face :height 1.1)))
  "Face for Inform 7 chapter headings."
  :group 'inform7-faces)

(defface inform7-heading-section-face
  '((t . (:inherit variable-pitch :weight bold)))
  "Face for Inform 7 section headings."
  :group 'inform7-faces)

(defun inform7--make-regex-heading (keyword)
  "Produce a regular expression for matching headings started by the given KEYWORD."
  (format "^%s[[:space:]]+[^[:space:]].*$" keyword))

(defconst inform7-regex-heading-volume
  (inform7--make-regex-heading "Volume")
  "Regular expression for an Inform 7 volume heading.")

(defconst inform7-regex-heading-book
  (inform7--make-regex-heading "Book")
  "Regular expression for an Inform 7 book heading.")

(defconst inform7-regex-heading-part
  (inform7--make-regex-heading "Part")
  "Regular expression for an Inform 7 part heading.")

(defconst inform7-regex-heading-chapter
  (inform7--make-regex-heading "Chapter")
  "Regular expression for an Inform 7 chapter heading.")

(defconst inform7-regex-heading-section
  (inform7--make-regex-heading "Section")
  "Regular expression for an Inform 7 section heading.")

(defvar inform7-font-lock-keywords
  `((,inform7-regex-heading-volume . 'inform7-heading-volume-face)
    (,inform7-regex-heading-book . 'inform7-heading-book-face)
    (,inform7-regex-heading-part . 'inform7-heading-part-face)
    (,inform7-regex-heading-chapter . 'inform7-heading-chapter-face)
    (,inform7-regex-heading-section . 'inform7-heading-section-face))
  "Syntax highlighting for Inform 7 files.")


;;;;;;;;;;;;;;;;;;;;;;
;;;;; Major Mode ;;;;;
;;;;;;;;;;;;;;;;;;;;;;


;;;###autoload
(define-derived-mode inform7-mode text-mode
  "Inform7"
  "Major mode for editing Inform 7 files."

  ;; Comments
  (setq-local comment-start "[")
  (setq-local comment-end "]")
  (setq-local comment-start-skip "\\[[[:space:]]*")
  (setq-local comment-column 0)
  (setq-local comment-auto-fill-only-comments nil)
  (setq-local comment-use-syntax t)

  ;; Font Lock
  (setq-local font-lock-defaults
              '(inform7-font-lock-keywords
                ;; fontify syntax (not just keywords)
                nil
                ;; ignore case of keywords
                t)))

(modify-syntax-entry ?\[ "< n" inform7-mode-syntax-table)
(modify-syntax-entry ?\] "> n" inform7-mode-syntax-table)
(modify-syntax-entry ?\" "\"" inform7-mode-syntax-table)
(modify-syntax-entry ?\\ "." inform7-mode-syntax-table)

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.\\(ni\\|i7\\)\\'" . inform7-mode)) ; Inform 7 source files (aka 'Natural Inform')
;;;###autoload
(add-to-list 'auto-mode-alist '("\\.i7x\\'" . inform7-mode))           ; Inform 7 extension files


(provide 'inform7)
;;; inform7.el ends here
