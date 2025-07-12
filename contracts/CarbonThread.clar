;; CarbonThread - Sustainable Supply Chain Transparency Platform
;; A blockchain-based solution for tracking and verifying sustainable products

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-input (err u103))
(define-constant err-already-exists (err u104))
(define-constant err-invalid-status (err u105))

;; Data Variables
(define-data-var next-product-id uint u1)
(define-data-var platform-fee uint u1000) ;; 0.1% in basis points

;; Data Maps
(define-map products
  { product-id: uint }
  {
    manufacturer: principal,
    product-name: (string-ascii 64),
    category: (string-ascii 32),
    origin-location: (string-ascii 64),
    carbon-footprint: uint,
    sustainability-score: uint,
    created-at: uint,
    status: (string-ascii 16)
  }
)

(define-map certifications
  { product-id: uint, cert-type: (string-ascii 32) }
  {
    issuer: principal,
    cert-hash: (buff 32),
    issued-at: uint,
    expires-at: uint,
    verified: bool
  }
)

(define-map supply-chain-steps
  { product-id: uint, step-id: uint }
  {
    processor: principal,
    step-name: (string-ascii 64),
    location: (string-ascii 64),
    timestamp: uint,
    quality-score: uint,
    verified: bool
  }
)

(define-map authorized-verifiers
  { verifier: principal }
  { authorized: bool }
)

;; Read-only functions
(define-read-only (get-product (product-id uint))
  (map-get? products { product-id: product-id })
)

(define-read-only (get-certification (product-id uint) (cert-type (string-ascii 32)))
  (map-get? certifications { product-id: product-id, cert-type: cert-type })
)

(define-read-only (get-supply-chain-step (product-id uint) (step-id uint))
  (map-get? supply-chain-steps { product-id: product-id, step-id: step-id })
)

(define-read-only (is-authorized-verifier (verifier principal))
  (let
    (
      (verifier-data (map-get? authorized-verifiers { verifier: verifier }))
    )
    (match verifier-data
      some-data (get authorized some-data)
      false
    )
  )
)

(define-read-only (get-next-product-id)
  (var-get next-product-id)
)

(define-read-only (get-platform-fee)
  (var-get platform-fee)
)

;; Private functions
(define-private (is-valid-sustainability-score (score uint))
  (and (>= score u0) (<= score u100))
)

(define-private (is-valid-quality-score (score uint))
  (and (>= score u0) (<= score u100))
)

(define-private (is-valid-string (str (string-ascii 64)))
  (> (len str) u0)
)

(define-private (is-valid-product-id (product-id uint))
  (> product-id u0)
)

(define-private (is-valid-step-id (step-id uint))
  (>= step-id u0)
)

(define-private (is-valid-principal (principal-addr principal))
  (not (is-eq principal-addr 'SP000000000000000000002Q6VF78))
)

;; Public functions
(define-public (register-product 
  (product-name (string-ascii 64))
  (category (string-ascii 32))
  (origin-location (string-ascii 64))
  (carbon-footprint uint)
  (sustainability-score uint))
  (let
    (
      (product-id (var-get next-product-id))
      (current-height stacks-block-height)
      (validated-carbon-footprint (if (> carbon-footprint u0) carbon-footprint u0))
    )
    (asserts! (is-valid-string product-name) err-invalid-input)
    (asserts! (is-valid-string category) err-invalid-input)
    (asserts! (is-valid-string origin-location) err-invalid-input)
    (asserts! (is-valid-sustainability-score sustainability-score) err-invalid-input)
    (asserts! (is-valid-product-id product-id) err-invalid-input)
    
    (map-set products
      { product-id: product-id }
      {
        manufacturer: tx-sender,
        product-name: product-name,
        category: category,
        origin-location: origin-location,
        carbon-footprint: validated-carbon-footprint,
        sustainability-score: sustainability-score,
        created-at: current-height,
        status: "registered"
      }
    )
    (var-set next-product-id (+ product-id u1))
    (ok product-id)
  )
)

(define-public (add-certification
  (product-id uint)
  (cert-type (string-ascii 32))
  (cert-hash (buff 32))
  (expires-at uint))
  (let
    (
      (validated-product-id (if (> product-id u0) product-id u0))
      (validated-cert-type (if (> (len cert-type) u0) cert-type "invalid"))
      (validated-cert-hash (if (> (len cert-hash) u0) cert-hash 0x00))
      (product-data (unwrap! (map-get? products { product-id: validated-product-id }) err-not-found))
      (current-height stacks-block-height)
      (existing-cert (map-get? certifications { product-id: validated-product-id, cert-type: validated-cert-type }))
    )
    (asserts! (is-valid-product-id product-id) err-invalid-input)
    (asserts! (> (len cert-type) u0) err-invalid-input)
    (asserts! (> (len cert-hash) u0) err-invalid-input)
    (asserts! (is-authorized-verifier tx-sender) err-unauthorized)
    (asserts! (> expires-at current-height) err-invalid-input)
    (asserts! (is-none existing-cert) err-already-exists)
    
    (map-set certifications
      { product-id: validated-product-id, cert-type: validated-cert-type }
      {
        issuer: tx-sender,
        cert-hash: validated-cert-hash,
        issued-at: current-height,
        expires-at: expires-at,
        verified: true
      }
    )
    (ok true)
  )
)

(define-public (add-supply-chain-step
  (product-id uint)
  (step-id uint)
  (step-name (string-ascii 64))
  (location (string-ascii 64))
  (quality-score uint))
  (let
    (
      (validated-product-id (if (> product-id u0) product-id u0))
      (validated-step-id (if (>= step-id u0) step-id u0))
      (product-data (unwrap! (map-get? products { product-id: validated-product-id }) err-not-found))
      (current-height stacks-block-height)
      (existing-step (map-get? supply-chain-steps { product-id: validated-product-id, step-id: validated-step-id }))
    )
    (asserts! (is-valid-product-id product-id) err-invalid-input)
    (asserts! (is-valid-step-id step-id) err-invalid-input)
    (asserts! (is-valid-string step-name) err-invalid-input)
    (asserts! (is-valid-string location) err-invalid-input)
    (asserts! (is-valid-quality-score quality-score) err-invalid-input)
    (asserts! (is-none existing-step) err-already-exists)
    
    (map-set supply-chain-steps
      { product-id: validated-product-id, step-id: validated-step-id }
      {
        processor: tx-sender,
        step-name: step-name,
        location: location,
        timestamp: current-height,
        quality-score: quality-score,
        verified: false
      }
    )
    (ok true)
  )
)

(define-public (verify-supply-chain-step (product-id uint) (step-id uint))
  (let
    (
      (validated-product-id (if (> product-id u0) product-id u0))
      (validated-step-id (if (>= step-id u0) step-id u0))
      (step-data (unwrap! (map-get? supply-chain-steps { product-id: validated-product-id, step-id: validated-step-id }) err-not-found))
    )
    (asserts! (is-valid-product-id product-id) err-invalid-input)
    (asserts! (is-valid-step-id step-id) err-invalid-input)
    (asserts! (is-authorized-verifier tx-sender) err-unauthorized)
    
    (map-set supply-chain-steps
      { product-id: validated-product-id, step-id: validated-step-id }
      (merge step-data { verified: true })
    )
    (ok true)
  )
)

(define-public (update-product-status (product-id uint) (new-status (string-ascii 16)))
  (let
    (
      (validated-product-id (if (> product-id u0) product-id u0))
      (product-data (unwrap! (map-get? products { product-id: validated-product-id }) err-not-found))
      (manufacturer (get manufacturer product-data))
    )
    (asserts! (is-valid-product-id product-id) err-invalid-input)
    (asserts! (is-eq tx-sender manufacturer) err-unauthorized)
    (asserts! (or (is-eq new-status "registered") 
                  (is-eq new-status "in-transit") 
                  (is-eq new-status "delivered") 
                  (is-eq new-status "verified")) err-invalid-status)
    
    (map-set products
      { product-id: validated-product-id }
      (merge product-data { status: new-status })
    )
    (ok true)
  )
)

(define-public (authorize-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-valid-principal verifier) err-invalid-input)
    (map-set authorized-verifiers
      { verifier: verifier }
      { authorized: true }
    )
    (ok true)
  )
)

(define-public (revoke-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-valid-principal verifier) err-invalid-input)
    (map-set authorized-verifiers
      { verifier: verifier }
      { authorized: false }
    )
    (ok true)
  )
)

(define-public (set-platform-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-fee u10000) err-invalid-input) ;; Max 10%
    (var-set platform-fee new-fee)
    (ok true)
  )
)