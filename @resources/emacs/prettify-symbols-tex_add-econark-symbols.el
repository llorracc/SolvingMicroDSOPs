;; add to this as needed using econark.sty as the master
;; prettify mode is kind of slow so no point in populating unneeded
;; search for, e.g. 'unicode mathematical bold small a' then copy-paste

(defvar local-tex-symbols-alist nil
  "Alist of local TeX symbols to be prettified.")

(defun add-local-tex-symbols ()
  (setq local-tex-symbols-alist
        (list
	 (cons "\\leftassign"      (string-to-char "≔"))
         (cons "\\Ex"		   (string-to-char "𝔼"))
         (cons "\\aLvl"		   (string-to-char "𝒂"))
         (cons "\\bLvl"		   (string-to-char "𝒃"))
	 (cons "\\cLvl"		   (string-to-char "𝒄"))
	 (cons "\\CLvl"		   (string-to-char "𝑪"))
	 (cons "\\dLvl"		   (string-to-char "𝒅"))
	 (cons "\\eLvl"		   (string-to-char "𝒆"))
	 (cons "\\fLvl"		   (string-to-char "𝒇"))
	 (cons "\\gLvl"		   (string-to-char "𝒈"))
	 (cons "\\hLvl"		   (string-to-char "𝒉"))
	 (cons "\\iLvl"		   (string-to-char "𝒊"))
	 (cons "\\jLvl"		   (string-to-char "𝒋"))
	 (cons "\\nLvl"		   (string-to-char "𝒏"))
	 (cons "\\pLvl"		   (string-to-char "𝒑"))
	 (cons "\\permLvl"	   (string-to-char "𝒑"))
	 (cons "\\kLvl"		   (string-to-char "𝒌"))
	 (cons "\\mLvl"		   (string-to-char "𝒎"))
	 (cons "\\vLvl"		   (string-to-char "𝒗"))
	 (cons "\\wLvl"		   (string-to-char "𝒘"))
	 (cons "\\yLvl"		   (string-to-char "𝒚"))
	 (cons "\\PtyGroFac"       (string-to-char "𝒢")) ;; Aggregate
	 (cons "\\PtyGroRte"       (string-to-char "𝑔")) 
	 (cons "\\ptyGroFac"       (string-to-char "G")) ;; individual
	 (cons "\\ptyGroRte"       (string-to-char "g"))
	 (cons "\\PermGroFacAgg"   (string-to-char "𝒢")) ;; Aggregate 
	 (cons "\\PermGroFacInd"   (string-to-char "𝑔")) ;; individual
	 (cons "\\PermGroFacAll"   (string-to-char "𝐆")) ;; combo Agg & Ind bf
	 (cons "\\PermGroFac"      (string-to-char "G")) ;; nonspecific
	 (cons "\\PermGroRte"      (string-to-char "G")) ;; nonspecific
	 (cons "\\PermGroFacAdjV"  (string-to-char " "))
	 (cons "\\PermGroFacAdjMu" (string-to-char " "))
	 (cons "\\aNrm"		   (string-to-char "a"))
	 (cons "\\bNrm"		   (string-to-char "b"))
	 (cons "\\cNrm"		   (string-to-char "c"))
	 (cons "\\dNrm"		   (string-to-char "d"))
	 (cons "\\eNrm"		   (string-to-char "e"))
	 (cons "\\fNrm"		   (string-to-char "f"))
	 (cons "\\hNrm"		   (string-to-char "h"))
	 (cons "\\iNrm"		   (string-to-char "i"))
	 (cons "\\jNrm"		   (string-to-char "j"))
	 (cons "\\kNrm"		   (string-to-char "k"))
	 (cons "\\mNrm"		   (string-to-char "m"))
	 (cons "\\pNrm"		   (string-to-char "p"))
	 (cons "\\qNrm"		   (string-to-char "q"))
	 (cons "\\rNrm"		   (string-to-char "r"))
	 (cons "\\sNrm"		   (string-to-char "s"))
	 (cons "\\vNrm"		   (string-to-char "v"))
	 (cons "\\wNrm"		   (string-to-char "w"))
	 (cons "\\xNrm"		   (string-to-char "x"))
	 (cons "\\yNrm"		   (string-to-char "y"))
	 (cons "\\zNrm"		   (string-to-char "z"))
	 (cons "\\RNrm"		   (string-to-char "ℛ"))
	 (cons "\\RNrmByG"         (string-to-char "ℛ"))
	 (cons "\\vFunc"	   (string-to-char "𝚟"))
	 (cons "\\uFunc"	   (string-to-char "𝚞"))
	 (cons "\\cFunc"	   (string-to-char "𝚌"))
	 (cons "\\DiscFac"	   (string-to-char "β"))
	 (cons "\\DiscRte"	   (string-to-char "ν"))
	 (cons "\\std"		   (string-to-char "σ"))
	 (cons "\\CRRA"		   (string-to-char "ρ"))
	 (cons "\\prd"             (string-to-char "t"))
	 (cons "\\prdt"            (string-to-char "t"))
	 (cons "\\prdT"            (string-to-char "t"))
	 (cons "\\trmT"            (string-to-char "T"))
	 (cons "\\Reals"           (string-to-char "ℝ"))
	 (cons "\\Rfree"           (string-to-char "R"))
	 (cons "\\Risky"           (string-to-char "𝐑"))
	 (cons "\\Rport"           (string-to-char "ℜ"))
	 (cons "\\Shr"             (string-to-char "Ϛ"))
	 (cons "\\PermShkAgg"      (string-to-char "Ψ"))
	 (cons "\\permShkInd"      (string-to-char "ψ"))
	 (cons "\\permShk"         (string-to-char "ψ"))
	 (cons "\\tranShkEmp"      (string-to-char "θ"))
	 (cons "\\tranShkAll"      (string-to-char "ξ"))
	 (cons "\\tranShkEmpDummy" (string-to-char "ϑ")) ;; dummy of integration
	 (cons "\\Nrml"            (string-to-char "𝒩"))
	 (cons "\\arvl"            (string-to-char "≺"))
	 (cons "\\cntn"            (string-to-char "≻"))
	 (cons "\\dcsn"            (string-to-char "∼"))
	 (cons "\\BegMark"         (string-to-char "≺"))
	 (cons "\\EndMark"         (string-to-char "≻"))
	 ;; \check{\kNrm} and \check{\mNrm} are written inline; \kNrm→k and \mNrm→m prettify the base
	 (cons "\\labor"           (string-to-char "ℓ"))
         (cons "\\FDist"           (string-to-char "𝓕"))
         (cons "\\vartheta"        (string-to-char "ϑ"))
         (cons "\\APFac"        (string-to-char "Þ")) ;; bold does not exist 
         (cons "\\APRte"        (string-to-char "þ"))
         (cons "\\TMap"        (string-to-char "𝕋"))
         ))
  )

(defun enable-local-tex-symbols ()
  (add-local-tex-symbols))

;; Global toggle for prettify-symbols-mode (C-c C-S-p).
;; Blocks all activation (including .dir-locals.el) when disabled.
(unless (fboundp 'cdc/toggle-prettify-symbols-global)
  (defvar cdc/prettify-symbols-globally-disabled nil
    "When non-nil, suppress prettify-symbols-mode activation everywhere.")
  (defun cdc/toggle-prettify-symbols-global ()
    "Toggle prettify-symbols-mode in all current and future buffers."
    (interactive)
    (setq cdc/prettify-symbols-globally-disabled
          (not cdc/prettify-symbols-globally-disabled))
    (if cdc/prettify-symbols-globally-disabled
        (progn
          (global-prettify-symbols-mode -1)
          (dolist (buf (buffer-list))
            (with-current-buffer buf
              (when (bound-and-true-p prettify-symbols-mode)
                (prettify-symbols-mode -1))))
          (message "prettify-symbols: DISABLED globally"))
      (progn
        (dolist (buf (buffer-list))
          (with-current-buffer buf
            (when (derived-mode-p 'latex-mode 'LaTeX-mode 'TeX-mode)
              (prettify-symbols-mode 1))))
        (message "prettify-symbols: RE-ENABLED in TeX buffers"))))
  (define-advice prettify-symbols-mode (:around (orig-fn &rest args) cdc/suppress)
    "Prevent prettify-symbols-mode from activating when globally disabled."
    (unless cdc/prettify-symbols-globally-disabled
      (apply orig-fn args)))
  (global-set-key (kbd "C-c t p") #'cdc/toggle-prettify-symbols-global))
