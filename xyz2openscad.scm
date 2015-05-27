#!/usr/bin/guile
!#
;;;
;;;GNU Guile script
;;;Author: Konstantin Prosenz
;;;Usage: guile xyz2openscad <path-to-.xyz-file>
;;;

(use-modules (srfi srfi-1)
             (ice-9 rdelim)
             (ice-9 format))

(define atom-list
  (list
   '("H" 1.20)
   '("C" 1.70)
   '("N" 1.55)
   '("O" 1.52)
   '("F" 1.47)
   '("P" 1.80)
   '("S" 1.80)
   '("Cl" 1.89)
   '("Ru" 1.45)))

(define (get-vdw-radius atom)
  (cadar (filter (lambda (atom-and-radius)
                 (string=? atom
                           (car atom-and-radius)))
                 atom-list)))

(define (check-file path)
  (if (file-exists? path)
      #t
      (begin
        (format #t
                "File \"~a\" does not exist.
Try using the absolute path in case you did
not already do so.~%" path)
        (quit))))

(define (read-xyz)
  (read-line)
  (read-line)
  (let rec ((line (read-line)))
    (cond ((eof-object? line) '())
          (else
           (cons (remove (lambda (a) (string=? a ""))
                         (string-split line
                                       (lambda (c) (or (char=? c #\Space)
                                                       (char=? c #\Tab)))))
                 (rec (read-line)))))))

(define (write-open-scad-script xyz-lines)
  (format #t "scale=1;~%~%")
  (let ((valid-atoms (map (lambda (atom-and-radius) (car atom-and-radius))
                          atom-list)))
    (let proc ((line-list xyz-lines))
      (cond ((null? line-list))
            (else
             (let* ((current-line (car line-list))
                    (current-atom (car current-line)))
               (format #t "translate([~a*scale,~a*scale,~a*scale]){~%"
                       ;;get the x,y,z coordinates
                       (list-ref current-line 1)
                       (list-ref current-line 2)
                       (list-ref current-line 3))
               (cond ((member current-atom
                              valid-atoms)
                      (format #t "sphere(~a*scale);};~%"
                              (get-vdw-radius current-atom)))
                     (else
                      (format #t "// atom ~a not found, assuming r=1.0~%"
                              current-atom)
                      (format #t "color(\"red\")~%")
                      (format #t "sphere(~a*scale);};~%" 1.0)))
               (proc (cdr line-list))))))))



(cond ((or 
        (member "-h" (command-line))
        (member "--help" (command-line))
        (member "?" (command-line))
        (< 2 (length (command-line))))
       (format #t
               "~%Converts a (orca) .xyz molecule coordinate file
to an openscad source file from which a 3D modell
can be rendered. The openscad source file will be printed
to standard output.
Should there be an atom in the .xyz for which there is
not data available, this script will assume a radius of 1
(Angstroem) and color the corresponding atom red in the rendered
3D modell.

Usage: guile xyz2openscad <path-to-.xyz-file>

You can also make this script executable with chmod.~%~%"))

      ((and (= 2 (length (command-line)))
(check-file (cadr (command-line))))
(with-input-from-file (cadr (command-line))
  (lambda () (write-open-scad-script (read-xyz)))))
((= 1 (length (command-line)))
 (write-open-scad-script (read-xyz))))

