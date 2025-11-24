;; -----------------------------------------------------------
;; Contract: SentinelVault.clar
;; Purpose:  Self-Revoking, Behavior-Triggered Smart Wallet
;; Author:   nuwa
;; -----------------------------------------------------------

(define-constant ERR-NOT-OWNER (err u100))
(define-constant ERR-WALLET-LOCKED (err u101))
(define-constant ERR-LIMIT-EXCEEDED (err u102))
(define-constant ERR-NOT-GUARDIAN (err u103))

;; -----------------------------------------------------------
;; Data Variables
;; -----------------------------------------------------------

(define-data-var owner principal tx-sender)
(define-data-var guardian principal tx-sender)
(define-data-var wallet-locked bool false)
(define-data-var daily-limit uint u1000000) ;; Example: 1,000,000 microSTX
(define-data-var last-reset uint u0)
(define-data-var spent-today uint u0)

;; -----------------------------------------------------------
;; Events (Note: Events not directly supported in this Clarity version)
;; -----------------------------------------------------------

;; -----------------------------------------------------------
;; Internal Helpers
;; -----------------------------------------------------------

(define-private (only-owner)
  (if (is-eq tx-sender (var-get owner))
      (ok true)
      ERR-NOT-OWNER))

(define-private (only-guardian)
  (if (is-eq tx-sender (var-get guardian))
      (ok true)
      ERR-NOT-GUARDIAN))

(define-private (check-reset)
  (begin
    (var-set spent-today u0)
    (ok true)))

;; -----------------------------------------------------------
;; Core Functions
;; -----------------------------------------------------------

(define-public (send-funds (recipient principal) (amount uint))
  (begin
    (try! (only-owner))
    (let ((reset-result (check-reset)))
      (if (var-get wallet-locked)
          ERR-WALLET-LOCKED
          (let ((spent (+ (var-get spent-today) amount)))
            (if (> spent (var-get daily-limit))
                (begin
                  ;; Auto-lock if limit exceeded
                  (var-set wallet-locked true)
                  ERR-LIMIT-EXCEEDED)
                (begin
                  (try! (stx-transfer? amount tx-sender recipient))
                  (var-set spent-today spent)
                  (ok true))
            ))))))

;; -----------------------------------------------------------
;; Security Management
;; -----------------------------------------------------------

(define-public (lock-wallet)
  (begin
    (try! (only-owner))
    (var-set wallet-locked true)
    (ok true)))

(define-public (unlock-wallet)
  (begin
    (try! (only-guardian))
    (var-set wallet-locked false)
    (ok true)))

(define-public (update-daily-limit (new-limit uint))
  (begin
    (try! (only-owner))
    (var-set daily-limit new-limit)
    (ok true)))

;; -----------------------------------------------------------
;; Read-Only Functions
;; -----------------------------------------------------------

(define-read-only (get-status)
  {
    owner: (var-get owner),
    guardian: (var-get guardian),
    locked: (var-get wallet-locked),
    spent-today: (var-get spent-today),
    limit: (var-get daily-limit)
  })
