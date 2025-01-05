;; Cosmic String NFT Contract

(define-non-fungible-token cosmic-string uint)

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_STRING (err u101))

;; Data variables
(define-data-var last-string-id uint u0)

;; Data maps
(define-map string-data
  uint
  {
    discoverer: principal,
    coordinates: (string-ascii 64),
    length: uint,
    energy-density: uint,
    discovery-timestamp: uint
  }
)

;; Public functions
(define-public (mint-cosmic-string (coordinates (string-ascii 64)) (length uint) (energy-density uint))
  (let
    (
      (string-id (+ (var-get last-string-id) u1))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (try! (nft-mint? cosmic-string string-id tx-sender))
    (map-set string-data
      string-id
      {
        discoverer: tx-sender,
        coordinates: coordinates,
        length: length,
        energy-density: energy-density,
        discovery-timestamp: block-height
      }
    )
    (var-set last-string-id string-id)
    (ok string-id)
  )
)

(define-public (transfer-cosmic-string (string-id uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (unwrap! (nft-get-owner? cosmic-string string-id) ERR_INVALID_STRING)) ERR_NOT_AUTHORIZED)
    (try! (nft-transfer? cosmic-string string-id tx-sender recipient))
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-cosmic-string-data (string-id uint))
  (map-get? string-data string-id)
)

(define-read-only (get-cosmic-string-owner (string-id uint))
  (nft-get-owner? cosmic-string string-id)
)

(define-read-only (get-last-string-id)
  (var-get last-string-id)
)

