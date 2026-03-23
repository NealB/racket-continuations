#lang racket
(require db racket/pretty racket/control "wrap-prompt.rkt")


(define (make-query-func get-sql db-path)
   
  (define conn (sqlite3-connect #:database db-path
                                #:mode 'create))
   
  (define sql (get-sql))
                             
  (with-handlers ([exn:fail:sql? (lambda (e) (printf "Got exception: ~S~n" e))])
    (let ((result (query-rows conn sql)))
      result)))


(define send-query (wrap-prompt make-query-func "this-db.db"))

(send-query "SELECT x, y, z FROM FOO ORDER BY x")

(send-query "SELECT x, y, z FROM FOO ORDER BY x DESC")

