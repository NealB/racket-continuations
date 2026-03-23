#lang racket
(require db racket/control "wrap-prompt.rkt")



(define-with-enclosing-prompt (sqlite-query-proc get-query db-path)
  (define conn (sqlite3-connect #:database db-path
                                #:mode 'create))

  (let-values (((db-func sql) (get-query)))
    
    (with-handlers ([exn:fail:sql? (lambda (e) (printf "Got exception: ~S~n" e))])
      (match db-func
        ('rows (query-rows conn sql))
        ('exec (query-exec conn sql))
        ('row (query-row conn sql))
        ('maybe-row (query-maybe-row conn sql))))))


(define send-query (sqlite-query-proc "this-db.db"))


(define (send-queries-exec . queries)
  (for-each (curry send-query 'exec) queries))


(send-queries-exec
 "DROP TABLE IF EXISTS Foo"
 "CREATE TABLE Foo (x, y, z)"
 "INSERT INTO Foo (x, y, z) VALUES (1, 2, 3), (4, 5, 6), (9, 8, 7)")

(define send-query-rows (curry send-query 'rows))

(send-query-rows "SELECT x, y, z FROM Foo ORDER BY x")

(send-query-rows "SELECT x, y, z FROM Foo ORDER BY x DESC")

