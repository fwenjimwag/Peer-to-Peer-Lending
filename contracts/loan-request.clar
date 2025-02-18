;; Loan Request Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))

;; Data Variables
(define-data-var loan-nonce uint u0)

;; Data Maps
(define-map loan-requests
  { loan-id: uint }
  {
    borrower: principal,
    amount: uint,
    duration: uint,
    purpose: (string-utf8 500),
    status: (string-ascii 20)
  }
)

;; Public Functions

;; Create a new loan request
(define-public (create-loan-request (amount uint) (duration uint) (purpose (string-utf8 500)))
  (let
    (
      (loan-id (var-get loan-nonce))
    )
    (map-set loan-requests
      { loan-id: loan-id }
      {
        borrower: tx-sender,
        amount: amount,
        duration: duration,
        purpose: purpose,
        status: "pending"
      }
    )
    (var-set loan-nonce (+ loan-id u1))
    (ok loan-id)
  )
)

;; Update loan request status
(define-public (update-loan-status (loan-id uint) (new-status (string-ascii 20)))
  (let
    (
      (loan (unwrap! (map-get? loan-requests { loan-id: loan-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set loan-requests
      { loan-id: loan-id }
      (merge loan { status: new-status })
    ))
  )
)

;; Read-only Functions

;; Get loan request details
(define-read-only (get-loan-request (loan-id uint))
  (ok (unwrap! (map-get? loan-requests { loan-id: loan-id }) err-not-found))
)

;; Initialize contract
(begin
  (var-set loan-nonce u0)
)

