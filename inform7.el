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

;;;###autoload
(define-derived-mode inform7-mode text-mode
  "Inform7"
  "Major mode for editing Inform 7 files.")

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.\\(ni\\|i7\\)\\'" . inform7-mode)) ; Inform 7 source files (aka 'Natural Inform')
;;;###autoload
(add-to-list 'auto-mode-alist '("\\.i7x\\'" . inform7-mode))           ; Inform 7 extension files

(provide 'inform7)
;;; inform7.el ends here
