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

(define (read-xyz-file path)
  (cond
   ((not (file-exists? path))
    (format #t
            "File \"~a\" does not exist.
Try using the absolute path in case you did
not already do so.~%" path) (quit))
   (else
    (with-input-from-file path
      (lambda ()
        (read-line)
        (read-line)
        (let rec ((line (read-line)))
          (cond ((eof-object? line) '())
                (else
                 (cons (remove (lambda (a) (string=? a ""))
                               (string-split line
                                             (lambda (c) (char=? c #\Space))))
                       (rec (read-line)))))))))))
   
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

(define (write-open-scad-script xyz-lines)
  (format #t "i=1;~%")
  (let proc ((line-list xyz-lines))
    (cond ((null? line-list))
          (else
           (let ((current-line (car line-list)))
             (format #t "translate([~a*i,~a*i,~a*i]){~%"
                     (list-ref current-line 1)
                     (list-ref current-line 2)
                     (list-ref current-line 3))
             (cond ((member (car current-line)
                            (map (lambda (atom-and-radius) (car atom-and-radius))
                                 atom-list))
                    (format #t "sphere(~a*i);};~%"
                            (cadar (filter (lambda (i)
                                             (string=? (car i) (car current-line)))
                                           atom-list))))
                   (else
                    (format #t "// atom ~a not found, assuming r=1.0~%"
                            (car current-line))
                    (format #t "color(\"red\")~%")
                    (format #t "sphere(~a*i);};~%" 1.0)))

             (proc (cdr line-list)))))))

(if (and (= 2 (length (command-line)))
        (not (string=? (cadr (command-line))
                       "-h"))
        (not (string=? (cadr (command-line))
                       "?"))
        (not (string=? (cadr (command-line))
                       "--help")))
    (write-open-scad-script (read-xyz-file (cadr (command-line))))
    (format #t
            "~%Converts a (orca) .xyz molecule coordinate file
to an openscad source file from which a 3D modell
can be rendered. The openscad source file will be printed
to standard output.~%
Usage: guile xyz2openscad <path-to-.xyz-file>~%~%"))
