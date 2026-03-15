(defun insert-tree (tree parent child)
     (cond   
            ( (null tree)
              (list parent (list child)) )
            ( (atom tree)
              (if (equal tree parent)
                  (list parent (list child))
                  tree))
            ( (equal (get-root tree) parent)
              (replace-subtree tree parent child))
            ( t
              (list (get-root tree)
                    (mapcar #'(lambda (subtree)
                                (insert-tree subtree parent child))
                        (get-children tree)))) ))

(defun get-root (tree)
   (first tree))

(defun get-children (tree)
   (second tree))

(defun replace-subtree (tree parent child)
  (list parent (append (get-children tree) (list child))))

(defun pre-order (tree )
  (if (atom tree)
      (list tree)
      (apply 'append
        (append
            (mapcar #'(lambda (subtree)
                      (pre-order subtree))
               (get-children tree))
            (list (list (get-root tree)))))))

