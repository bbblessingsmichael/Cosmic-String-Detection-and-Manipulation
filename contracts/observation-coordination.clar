;; Observation Coordination Contract

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_OBSERVATION (err u101))

;; Data variables
(define-data-var observation-count uint u0)

;; Data maps
(define-map observations
  uint
  {
    observer: principal,
    coordinates: (string-ascii 64),
    timestamp: uint,
    data: (string-utf8 1024),
    status: (string-ascii 20)
  }
)

(define-map analysis-tasks
  uint
  {
    analyst: principal,
    observation-id: uint,
    status: (string-ascii 20)
  }
)

;; Public functions
(define-public (submit-observation (coordinates (string-ascii 64)) (data (string-utf8 1024)))
  (let
    (
      (observation-id (+ (var-get observation-count) u1))
    )
    (map-set observations
      observation-id
      {
        observer: tx-sender,
        coordinates: coordinates,
        timestamp: block-height,
        data: data,
        status: "pending"
      }
    )
    (var-set observation-count observation-id)
    (ok observation-id)
  )
)

(define-public (create-analysis-task (observation-id uint))
  (let
    (
      (observation (unwrap! (map-get? observations observation-id) ERR_INVALID_OBSERVATION))
    )
    (map-set analysis-tasks
      observation-id
      {
        analyst: tx-sender,
        observation-id: observation-id,
        status: "in-progress"
      }
    )
    (ok observation-id)
  )
)

(define-public (update-observation-status (observation-id uint) (new-status (string-ascii 20)))
  (let
    (
      (observation (unwrap! (map-get? observations observation-id) ERR_INVALID_OBSERVATION))
    )
    (asserts! (or (is-eq tx-sender (get observer observation)) (is-eq tx-sender CONTRACT_OWNER)) ERR_NOT_AUTHORIZED)
    (ok (map-set observations
      observation-id
      (merge observation { status: new-status })
    ))
  )
)

;; Read-only functions
(define-read-only (get-observation (observation-id uint))
  (map-get? observations observation-id)
)

(define-read-only (get-analysis-task (observation-id uint))
  (map-get? analysis-tasks observation-id)
)

(define-read-only (get-observation-count)
  (var-get observation-count)
)

