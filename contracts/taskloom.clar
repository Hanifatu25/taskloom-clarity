;; TaskLoom Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u404))
(define-constant err-unauthorized (err u401))
(define-constant err-invalid-status (err u400))
(define-constant err-empty-input (err u402))

;; Data Variables
(define-data-var task-count uint u0)
(define-data-var list-count uint u0)

;; Data Maps
(define-map tasks 
  { task-id: uint } 
  {
    title: (string-ascii 64),
    description: (string-ascii 256),
    status: (string-ascii 16),
    creator: principal,
    assignee: (optional principal),
    created-at: uint,
    updated-at: uint,
    list-id: (optional uint)
  }
)

(define-map task-lists
  { list-id: uint }
  {
    name: (string-ascii 64),
    owner: principal,
    created-at: uint
  }
)

;; Helper Functions
(define-private (is-valid-status (status (string-ascii 16)))
  (or (is-eq status "pending")
      (is-eq status "in-progress")
      (is-eq status "completed")
      (is-eq status "cancelled"))
)

(define-private (is-valid-input (input (string-ascii 256)))
  (not (is-eq input ""))
)

;; Public Functions
(define-public (create-task (title (string-ascii 64)) (description (string-ascii 256)))
  (begin
    (asserts! (is-valid-input title) err-empty-input)
    (asserts! (is-valid-input description) err-empty-input)
    (let
      (
        (task-id (var-get task-count))
        (block-height block-height)
      )
      (map-set tasks
        { task-id: task-id }
        {
          title: title,
          description: description,
          status: "pending",
          creator: tx-sender,
          assignee: none,
          created-at: block-height,
          updated-at: block-height,
          list-id: none
        }
      )
      (var-set task-count (+ task-id u1))
      (print { type: "task-created", task-id: task-id, creator: tx-sender })
      (ok task-id)
    )
  )
)

(define-public (update-task (task-id uint) (new-title (string-ascii 64)) (new-description (string-ascii 256)))
  (begin
    (asserts! (is-valid-input new-title) err-empty-input)
    (asserts! (is-valid-input new-description) err-empty-input)
    (let ((task (unwrap! (get-task-details task-id) err-not-found)))
      (asserts! (is-eq (get creator task) tx-sender) err-unauthorized)
      (print { type: "task-updated", task-id: task-id, updater: tx-sender })
      (ok (map-set tasks
        { task-id: task-id }
        (merge task 
          {
            title: new-title,
            description: new-description,
            updated-at: block-height
          }
        )
      ))
    )
  )
)

[... remaining functions with similar improvements ...]
