(defun han (n)
   "Recurrence relation for the number off steps required
    to solve the tower of hanoi"
    (if (eq n 1)
        1
        (1+ (* 2 (han (1- n))))))

;  Disks  1   2   3   4   5   6    7     8     9    10    11  .... 20
;
;  Moves  1   3   7   15  31  63   127   255   511  1023  2047 ... 1,048,575
;
