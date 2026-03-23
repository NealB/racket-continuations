#lang racket
(require racket/control (for-syntax racket/match))

(define (wrap-prompt fn . fn_args)
  (define prompt-tag
    (make-continuation-prompt-tag (gensym)))

  (define resume #f)
  
  (define (suspend)
    ; this only runs once, because subsequent calls are made to the resume continuation, which starts right after this procedure.
    (call/comp
     (λ (return-cont)
       (set! resume return-cont)
       (abort/cc prompt-tag))
     prompt-tag))

  (call/prompt
   (thunk
    (apply fn suspend fn_args)) 
   prompt-tag
   void)
    
  resume)

(define-syntax (define-with-enclosing-prompt stx)
  (match-define (list _ name-arg-list body ...) (syntax->list stx))
  (match-define (list name arg-list ...) (syntax->list name-arg-list))
  
  (datum->syntax stx
                 `(define ,name
                    (curry wrap-prompt
                           (λ ,arg-list ,@body)))))

(provide wrap-prompt define-with-enclosing-prompt)
