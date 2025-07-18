
;; StacksTick
;;Ticketing smart contract is a decentralized ticketing platform built on the Stacks blockchain using the Clarity smart contract language

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-OWNER (err u100))
(define-constant ERR-TICKET-ALREADY-MINTED (err u101))
(define-constant ERR-TICKET-NOT-FOUND (err u102))
(define-constant ERR-UNAUTHORIZED-TRANSFER (err u103))
(define-constant ERR-INVALID-INPUT (err u104))
(define-constant ERR-CAPACITY-EXCEEDED (err u105))
(define-constant ERR-EVENT-ALREADY-CANCELLED (err u106))
(define-constant ERR-REFUND-FAILED (err u107))
(define-constant ERR-TICKETS-ALREADY-SOLD (err u108))
(define-constant ERR-INVALID-TRANSFER-RECIPIENT (err u109))


;; Map
(define-map ticket-metadata 
  {ticket-id: (string-ascii 100)} 
  {
    event-name: (string-ascii 100),
    event-date: (string-ascii 50),
    ticket-price: uint,
    max-capacity: uint,
    current-sales: uint,
    is-cancelled: bool
  }
)


;; Tracks ticket holders for each event
(define-map event-ticket-holders 
  {ticket-id: (string-ascii 100), ticket-owner: principal} 
  bool
)


;; Private functions
(define-private (is-valid-event-name (name (string-ascii 100)))
  (and 
    (> (len name) u0) 
    (<= (len name) u100)
  )
)

(define-private (is-valid-event-date (date (string-ascii 50)))
  (and 
    (> (len date) u0) 
    (<= (len date) u50)
  )
)

(define-private (is-valid-ticket-price (price uint))
  (> price u0)
)

(define-private (is-valid-max-capacity (capacity uint))
  (> capacity u0)
)

;; Principal Validation Function
(define-private (is-valid-principal (addr principal))
  (not (is-eq addr CONTRACT-OWNER))
)


(define-read-only (get-ticket-metadata (ticket-id (string-ascii 100)))
  (map-get? ticket-metadata {ticket-id: ticket-id})
)





;; Update Event Details
(define-public (update-event-details
  (ticket-id (string-ascii 100))
  (new-event-name (string-ascii 100))
  (new-event-date (string-ascii 50))
  (new-ticket-price uint)
)
  (let ((ticket-info (unwrap! (get-ticket-metadata ticket-id) ERR-TICKET-NOT-FOUND)))
    (begin
      ;; Ensure only contract owner can update
      (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-OWNER)

      ;; Prevent updates after tickets have been sold
      (asserts! (is-eq (get current-sales ticket-info) u0) ERR-TICKETS-ALREADY-SOLD)

      ;; Validate new inputs
      (asserts! (is-valid-event-name new-event-name) ERR-INVALID-INPUT)
      (asserts! (is-valid-event-date new-event-date) ERR-INVALID-INPUT)
      (asserts! (is-valid-ticket-price new-ticket-price) ERR-INVALID-INPUT)

      ;; Update ticket metadata
      (map-set ticket-metadata 
        {ticket-id: ticket-id}
        (merge ticket-info {
          event-name: new-event-name,
          event-date: new-event-date,
          ticket-price: new-ticket-price
        })
      )

      (ok true)
    )
  )
)


;; Cancel Event
(define-public (cancel-event (ticket-id (string-ascii 100)))
  (let ((ticket-info (unwrap! (get-ticket-metadata ticket-id) ERR-TICKET-NOT-FOUND)))
    (begin
      ;; Ensure only contract owner can cancel
      (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-OWNER)

      ;; Ensure event hasn't already been cancelled
      (asserts! (not (get is-cancelled ticket-info)) ERR-EVENT-ALREADY-CANCELLED)

      ;; Mark event as cancelled
      (map-set ticket-metadata 
        {ticket-id: ticket-id}
        (merge ticket-info {is-cancelled: true})
      )

      (ok true)
    )
  )
)
