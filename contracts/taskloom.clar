;; TaskLoom Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u404))
(define-constant err-unauthorized (err u401))
(define-constant err-invalid-status (err u400))

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

;; Public Functions
(define-public (create-task (title (string-ascii 64)) (description (string-ascii 256)))
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
    (ok task-id)
  )
)

(define-public (update-task (task-id uint) (new-title (string-ascii 64)) (new-description (string-ascii 256)))
  (let ((task (unwrap! (get-task-details task-id) err-not-found)))
    (asserts! (is-eq (get creator task) tx-sender) err-unauthorized)
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

(define-public (assign-task (task-id uint) (assignee principal))
  (let ((task (unwrap! (get-task-details task-id) err-not-found)))
    (asserts! (is-eq (get creator task) tx-sender) err-unauthorized)
    (ok (map-set tasks
      { task-id: task-id }
      (merge task 
        {
          assignee: (some assignee),
          updated-at: block-height
        }
      )
    ))
  )
)

(define-public (update-task-status (task-id uint) (new-status (string-ascii 16)))
  (let ((task (unwrap! (get-task-details task-id) err-not-found)))
    (asserts! (or (is-eq (get creator task) tx-sender) 
                 (is-eq (get assignee task) (some tx-sender))) 
             err-unauthorized)
    (asserts! (or (is-eq new-status "pending")
                 (is-eq new-status "in-progress")
                 (is-eq new-status "completed")
                 (is-eq new-status "cancelled"))
             err-invalid-status)
    (ok (map-set tasks
      { task-id: task-id }
      (merge task 
        {
          status: new-status,
          updated-at: block-height
        }
      )
    ))
  )
)

;; Read Only Functions
(define-read-only (get-task-details (task-id uint))
  (map-get? tasks { task-id: task-id })
)

(define-read-only (get-user-tasks (user principal))
  (filter tasks (lambda (task) 
    (or 
      (is-eq (get creator task) user)
      (is-eq (get assignee task) (some user))
    )
  ))
)
