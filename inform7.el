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

(defface inform7-string-face
  '((t . (:inherit font-lock-string-face :weight bold :foreground "#004D99")))
  "Face for Inform 7 strings."
  :group 'inform7-faces)

(defface inform7-substitution-face
  '((t . (:inherit variable-pitch :slant italic :foreground "#3E9EFF")))
  "Face for Inform 7 substitutions embedded in text."
  :group 'inform7-faces)

(defface inform7-rule-name-face
  '((t . (:inherit font-lock-keyword-face)))
  "Face for Inform 7 rule names."
  :group 'inform7-faces)

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

(defconst inform7-regex-heading
  (inform7--make-regex-heading "\\(?:Volume\\|Book\\|Part\\|Chapter\\|Section\\)")
  "Regular expression for an Inform 7 heading.")

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

(defconst inform7-regex-substitution-maybe-open
  "\\[\\(?:[^]]\\|\\n\\)*\\]?+"
  "Regular expression for matching a substitution embedded in an Inform 7 string (which may not be closed).")

(defconst inform7-regex-string-maybe-open
  (format "\"\\(?:%s\\|[^\"]\\|\\n\\)*\"?+" inform7-regex-substitution-maybe-open)
  "Regular expression for matching an Inform 7 string (which may not be closed).")

(defconst inform7-regex-standard-rule
  (format "^\\(?:%s\\)" (regexp-opt-group
                         '("After"
                           "Before"
                           "Check"
                           "Carry out"
                           "Every"
                           "Instead of"
                           "Report"
                           "When")))
  "Regular expression for matching a standard Inform 7 rule.")

(defun inform7--match-inside (outer matcher facespec)
  "Match inside the match OUTER with MATCHER, fontifying with FACESPEC."
  (let ((preform `(progn
                    (goto-char (match-beginning 0))
                    (match-end 0))))
    `(,outer . '(,matcher ,preform nil (0 ,facespec t)))))

(defvar inform7-font-lock-keywords
  `((,inform7-regex-heading-volume . 'inform7-heading-volume-face)
    (,inform7-regex-heading-book . 'inform7-heading-book-face)
    (,inform7-regex-heading-part . 'inform7-heading-part-face)
    (,inform7-regex-heading-chapter . 'inform7-heading-chapter-face)
    (,inform7-regex-heading-section . 'inform7-heading-section-face)
    ;; standard rules
    (,inform7-regex-standard-rule . 'inform7-rule-name-face)
    ;; strings
    (,inform7-regex-string-maybe-open 0 'inform7-string-face t)
    ;; substitutions
    ,(inform7--match-inside inform7-regex-string-maybe-open inform7-regex-substitution-maybe-open `'inform7-substitution-face))
  "Syntax highlighting for Inform 7 files.")


;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; imenu Support ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;


(defun inform7-imenu-create-flat-index ()
  "Produce a flat imenu index for the current buffer.
See `imenu-create-index-function' for details."
  (let (index)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward inform7-regex-heading nil t)
        (let ((heading (match-string-no-properties 0))
              (pos (match-beginning 0)))
          (setq index (append index (list (cons heading pos)))))))
    index))


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
                t
                ((?\[ . "< n") ; open block comment
                 (?\] . "> n") ; close block comment
                 (?\" . ".")   ; quote
                 (?\\ . "."))  ; backslashes don't escape
                (font-lock-multiline . t)))

  ;; imenu support
  (setq imenu-create-index-function
        #'inform7-imenu-create-flat-index))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.\\(ni\\|i7\\)\\'" . inform7-mode)) ; Inform 7 source files (aka 'Natural Inform')
;;;###autoload
(add-to-list 'auto-mode-alist '("\\.i7x\\'" . inform7-mode))           ; Inform 7 extension files


(provide 'inform7)
;;; inform7.el ends here
