;; TaskLoom Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u404))
(define-constant err-unauthorized (err u401))
(define-constant err-invalid-status (err u400))
(define-constant err-empty-input (err u402))
(define-constant err-invalid-length (err u403))

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

(define-private (is-valid-input-length (input (string-ascii 256)) (min uint) (max uint))
  (let ((len (len input)))
    (and (>= len min) (<= len max))
  )
)

(define-private (is-task-owner (task-id uint))
  (match (get-task-details task-id)
    task (is-eq (get creator task) tx-sender)
    false
  )
)

(define-private (log-event (event-type (string-ascii 32)) (data (tuple (task-id uint) (principal principal))))
  (print {
    type: event-type,
    data: data,
    timestamp: block-height
  })
)

;; Public Functions
(define-public (create-task (title (string-ascii 64)) (description (string-ascii 256)))
  (begin
    (asserts! (is-valid-input-length title u1 u64) err-invalid-length)
    (asserts! (is-valid-input-length description u1 u256) err-invalid-length)
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
      (log-event "task-created" { task-id: task-id, principal: tx-sender })
      (ok task-id)
    )
  )
)

[... remaining functions updated with similar improvements ...]
