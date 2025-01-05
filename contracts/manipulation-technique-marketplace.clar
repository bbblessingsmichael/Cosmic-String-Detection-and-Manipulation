;; Manipulation Technique Marketplace Contract

(define-fungible-token cosmic-token)

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INSUFFICIENT_BALANCE (err u101))
(define-constant ERR_INVALID_TECHNIQUE (err u102))

;; Data variables
(define-data-var last-technique-id uint u0)

;; Data maps
(define-map techniques
  uint
  {
    creator: principal,
    name: (string-ascii 64),
    description: (string-utf8 1024),
    price: uint,
    status: (string-ascii 20)
  }
)

(define-map technique-owners
  { technique-id: uint, owner: principal }
  uint
)

;; Public functions
(define-public (create-technique (name (string-ascii 64)) (description (string-utf8 1024)) (price uint))
  (let
    (
      (technique-id (+ (var-get last-technique-id) u1))
    )
    (map-set techniques
      technique-id
      {
        creator: tx-sender,
        name: name,
        description: description,
        price: price,
        status: "active"
      }
    )
    (map-set technique-owners
      { technique-id: technique-id, owner: tx-sender }
      u1
    )
    (var-set last-technique-id technique-id)
    (ok technique-id)
  )
)

(define-public (buy-technique (technique-id uint))
  (let
    (
      (technique (unwrap! (map-get? techniques technique-id) ERR_INVALID_TECHNIQUE))
      (price (get price technique))
    )
    (asserts! (is-eq (get status technique) "active") ERR_INVALID_TECHNIQUE)
    (try! (ft-transfer? cosmic-token price tx-sender (get creator technique)))
    (map-set technique-owners
      { technique-id: technique-id, owner: tx-sender }
      (default-to u0 (+ (get-technique-ownership technique-id tx-sender) u1))
    )
    (ok true)
  )
)

(define-public (update-technique-status (technique-id uint) (new-status (string-ascii 20)))
  (let
    (
      (technique (unwrap! (map-get? techniques technique-id) ERR_INVALID_TECHNIQUE))
    )
    (asserts! (is-eq tx-sender (get creator technique)) ERR_NOT_AUTHORIZED)
    (ok (map-set techniques
      technique-id
      (merge technique { status: new-status })
    ))
  )
)

;; Read-only functions
(define-read-only (get-technique (technique-id uint))
  (map-get? techniques technique-id)
)

(define-read-only (get-technique-ownership (technique-id uint) (owner principal))
  (default-to u0 (map-get? technique-owners { technique-id: technique-id, owner: owner }))
)

(define-read-only (get-last-technique-id)
  (var-get last-technique-id)
)

