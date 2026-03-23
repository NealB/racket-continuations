#lang racket
(require racket/control)

(define (wrap-prompt fn . fn_args)
  (define prompt-tag
    (make-continuation-prompt-tag (gensym)))

  (define resume #f)
  
  (define (suspend)
    (call/comp
     (λ (return-cont)
       (set! resume return-cont)
       (abort/cc prompt-tag return-cont))
     prompt-tag))


  (call/prompt
   (thunk
    (apply fn suspend fn_args)
    ) 
   prompt-tag
   void)
    
  resume)

(provide wrap-prompt)
