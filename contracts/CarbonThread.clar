;; CarbonThread - Sustainable Supply Chain Transparency Platform
;; A blockchain-based solution for tracking and verifying sustainable products
;; Now with carbon offset integration for carbon neutrality and consumer review system

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-input (err u103))
(define-constant err-already-exists (err u104))
(define-constant err-invalid-status (err u105))
(define-constant err-insufficient-credits (err u106))
(define-constant err-already-retired (err u107))
(define-constant err-already-reviewed (err u108))
(define-constant err-not-purchased (err u109))
(define-constant err-invalid-rating (err u110))

;; Data Variables
(define-data-var next-product-id uint u1)
(define-data-var next-purchase-id uint u1)
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
    status: (string-ascii 16),
    total-reviews: uint,
    average-rating: uint,
    average-sustainability-rating: uint
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

(define-map carbon-offsets
  { product-id: uint }
  {
    purchaser: principal,
    credits-purchased: uint,
    credits-retired: uint,
    registry-id: (string-ascii 64),
    project-name: (string-ascii 128),
    purchase-timestamp: uint,
    retirement-timestamp: (optional uint),
    verified: bool
  }
)

(define-map authorized-verifiers
  { verifier: principal }
  { authorized: bool }
)

(define-map product-purchases
  { purchase-id: uint }
  {
    product-id: uint,
    purchaser: principal,
    purchase-timestamp: uint,
    verified: bool
  }
)

(define-map consumer-reviews
  { product-id: uint, reviewer: principal }
  {
    purchase-id: uint,
    overall-rating: uint,
    sustainability-rating: uint,
    quality-rating: uint,
    review-text: (string-ascii 256),
    review-timestamp: uint,
    verified-purchase: bool
  }
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

(define-read-only (get-carbon-offset (product-id uint))
  (map-get? carbon-offsets { product-id: product-id })
)

(define-read-only (get-consumer-review (product-id uint) (reviewer principal))
  (map-get? consumer-reviews { product-id: product-id, reviewer: reviewer })
)

(define-read-only (get-purchase (purchase-id uint))
  (map-get? product-purchases { purchase-id: purchase-id })
)

(define-read-only (is-carbon-neutral (product-id uint))
  (let
    (
      (product-data (map-get? products { product-id: product-id }))
      (offset-data (map-get? carbon-offsets { product-id: product-id }))
    )
    (match product-data
      some-product
        (match offset-data
          some-offset
            (let
              (
                (carbon-footprint (get carbon-footprint some-product))
                (credits-retired (get credits-retired some-offset))
                (verified (get verified some-offset))
              )
              (and 
                verified
                (>= credits-retired carbon-footprint)
                (is-some (get retirement-timestamp some-offset))
              )
            )
          false
        )
      false
    )
  )
)

(define-read-only (has-verified-purchase (product-id uint) (purchaser principal))
  (let
    (
      (review-data (map-get? consumer-reviews { product-id: product-id, reviewer: purchaser }))
    )
    (match review-data
      some-review (get verified-purchase some-review)
      false
    )
  )
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

(define-read-only (get-next-purchase-id)
  (var-get next-purchase-id)
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

(define-private (is-valid-rating (rating uint))
  (and (>= rating u1) (<= rating u5))
)

(define-private (is-valid-string (str (string-ascii 64)))
  (> (len str) u0)
)

(define-private (is-valid-review-text (str (string-ascii 256)))
  (> (len str) u0)
)

(define-private (is-valid-long-string (str (string-ascii 128)))
  (> (len str) u0)
)

(define-private (is-valid-product-id (product-id uint))
  (> product-id u0)
)

(define-private (is-valid-purchase-id (purchase-id uint))
  (> purchase-id u0)
)

(define-private (is-valid-step-id (step-id uint))
  (>= step-id u0)
)

(define-private (is-valid-principal (principal-addr principal))
  (not (is-eq principal-addr 'SP000000000000000000002Q6VF78))
)

(define-private (is-valid-credits (credits uint))
  (> credits u0)
)

(define-private (calculate-new-average (current-average uint) (current-count uint) (new-rating uint))
  (if (is-eq current-count u0)
    new-rating
    (/ (+ (* current-average current-count) new-rating) (+ current-count u1))
  )
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
        carbon-footprint: (if (>= carbon-footprint u0) carbon-footprint u0),
        sustainability-score: sustainability-score,
        created-at: current-height,
        status: "registered",
        total-reviews: u0,
        average-rating: u0,
        average-sustainability-rating: u0
      }
    )
    (var-set next-product-id (+ product-id u1))
    (ok product-id)
  )
)

(define-public (record-purchase (product-id uint))
  (let
    (
      (purchase-id (var-get next-purchase-id))
      (current-height stacks-block-height)
      (product-data (unwrap! (map-get? products { product-id: product-id }) err-not-found))
    )
    (asserts! (is-valid-product-id product-id) err-invalid-input)
    (asserts! (is-valid-purchase-id purchase-id) err-invalid-input)
    
    (map-set product-purchases
      { purchase-id: purchase-id }
      {
        product-id: product-id,
        purchaser: tx-sender,
        purchase-timestamp: current-height,
        verified: false
      }
    )
    (var-set next-purchase-id (+ purchase-id u1))
    (ok purchase-id)
  )
)

(define-public (verify-purchase (purchase-id uint))
  (let
    (
      (purchase-data (unwrap! (map-get? product-purchases { purchase-id: purchase-id }) err-not-found))
    )
    (asserts! (is-valid-purchase-id purchase-id) err-invalid-input)
    (asserts! (is-authorized-verifier tx-sender) err-unauthorized)
    
    (map-set product-purchases
      { purchase-id: purchase-id }
      (merge purchase-data { verified: true })
    )
    (ok true)
  )
)

(define-public (add-consumer-review
  (product-id uint)
  (purchase-id uint)
  (overall-rating uint)
  (sustainability-rating uint)
  (quality-rating uint)
  (review-text (string-ascii 256)))
  (let
    (
      (current-height stacks-block-height)
      (product-data (unwrap! (map-get? products { product-id: product-id }) err-not-found))
      (purchase-data (unwrap! (map-get? product-purchases { purchase-id: purchase-id }) err-not-found))
      (existing-review (map-get? consumer-reviews { product-id: product-id, reviewer: tx-sender }))
      (purchase-product-id (get product-id purchase-data))
      (purchaser (get purchaser purchase-data))
      (purchase-verified (get verified purchase-data))
      (current-total-reviews (get total-reviews product-data))
      (current-avg-rating (get average-rating product-data))
      (current-avg-sustainability (get average-sustainability-rating product-data))
      (new-avg-rating (calculate-new-average current-avg-rating current-total-reviews overall-rating))
      (new-avg-sustainability (calculate-new-average current-avg-sustainability current-total-reviews sustainability-rating))
    )
    (asserts! (is-valid-product-id product-id) err-invalid-input)
    (asserts! (is-valid-purchase-id purchase-id) err-invalid-input)
    (asserts! (is-valid-rating overall-rating) err-invalid-rating)
    (asserts! (is-valid-rating sustainability-rating) err-invalid-rating)
    (asserts! (is-valid-rating quality-rating) err-invalid-rating)
    (asserts! (is-valid-review-text review-text) err-invalid-input)
    (asserts! (is-eq purchase-product-id product-id) err-invalid-input)
    (asserts! (is-eq purchaser tx-sender) err-not-purchased)
    (asserts! (is-none existing-review) err-already-reviewed)
    
    (map-set consumer-reviews
      { product-id: product-id, reviewer: tx-sender }
      {
        purchase-id: purchase-id,
        overall-rating: overall-rating,
        sustainability-rating: sustainability-rating,
        quality-rating: quality-rating,
        review-text: review-text,
        review-timestamp: current-height,
        verified-purchase: purchase-verified
      }
    )
    
    (map-set products
      { product-id: product-id }
      (merge product-data 
        {
          total-reviews: (+ current-total-reviews u1),
          average-rating: new-avg-rating,
          average-sustainability-rating: new-avg-sustainability
        }
      )
    )
    (ok true)
  )
)

(define-public (add-certification
  (product-id uint)
  (cert-type (string-ascii 32))
  (cert-hash (buff 32))
  (expires-at uint))
  (let
    (
      (product-data (unwrap! (map-get? products { product-id: product-id }) err-not-found))
      (current-height stacks-block-height)
      (existing-cert (map-get? certifications { product-id: product-id, cert-type: cert-type }))
    )
    (asserts! (is-valid-product-id product-id) err-invalid-input)
    (asserts! (> (len cert-type) u0) err-invalid-input)
    (asserts! (> (len cert-hash) u0) err-invalid-input)
    (asserts! (is-authorized-verifier tx-sender) err-unauthorized)
    (asserts! (> expires-at current-height) err-invalid-input)
    (asserts! (is-none existing-cert) err-already-exists)
    
    (map-set certifications
      { product-id: product-id, cert-type: cert-type }
      {
        issuer: tx-sender,
        cert-hash: cert-hash,
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
      (product-data (unwrap! (map-get? products { product-id: product-id }) err-not-found))
      (current-height stacks-block-height)
      (existing-step (map-get? supply-chain-steps { product-id: product-id, step-id: step-id }))
    )
    (asserts! (is-valid-product-id product-id) err-invalid-input)
    (asserts! (is-valid-step-id step-id) err-invalid-input)
    (asserts! (is-valid-string step-name) err-invalid-input)
    (asserts! (is-valid-string location) err-invalid-input)
    (asserts! (is-valid-quality-score quality-score) err-invalid-input)
    (asserts! (is-none existing-step) err-already-exists)
    
    (map-set supply-chain-steps
      { product-id: product-id, step-id: step-id }
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
      (step-data (unwrap! (map-get? supply-chain-steps { product-id: product-id, step-id: step-id }) err-not-found))
    )
    (asserts! (is-valid-product-id product-id) err-invalid-input)
    (asserts! (is-valid-step-id step-id) err-invalid-input)
    (asserts! (is-authorized-verifier tx-sender) err-unauthorized)
    
    (map-set supply-chain-steps
      { product-id: product-id, step-id: step-id }
      (merge step-data { verified: true })
    )
    (ok true)
  )
)

(define-public (purchase-carbon-offset
  (product-id uint)
  (credits-amount uint)
  (registry-id (string-ascii 64))
  (project-name (string-ascii 128)))
  (let
    (
      (product-data (unwrap! (map-get? products { product-id: product-id }) err-not-found))
      (current-height stacks-block-height)
      (existing-offset (map-get? carbon-offsets { product-id: product-id }))
      (manufacturer (get manufacturer product-data))
    )
    (asserts! (is-valid-product-id product-id) err-invalid-input)
    (asserts! (is-valid-credits credits-amount) err-invalid-input)
    (asserts! (is-valid-string registry-id) err-invalid-input)
    (asserts! (is-valid-long-string project-name) err-invalid-input)
    (asserts! (is-eq tx-sender manufacturer) err-unauthorized)
    (asserts! (is-none existing-offset) err-already-exists)
    
    (map-set carbon-offsets
      { product-id: product-id }
      {
        purchaser: tx-sender,
        credits-purchased: credits-amount,
        credits-retired: u0,
        registry-id: registry-id,
        project-name: project-name,
        purchase-timestamp: current-height,
        retirement-timestamp: none,
        verified: false
      }
    )
    (ok true)
  )
)

(define-public (retire-carbon-credits (product-id uint) (credits-to-retire uint))
  (let
    (
      (product-data (unwrap! (map-get? products { product-id: product-id }) err-not-found))
      (offset-data (unwrap! (map-get? carbon-offsets { product-id: product-id }) err-not-found))
      (current-height stacks-block-height)
      (manufacturer (get manufacturer product-data))
      (purchaser (get purchaser offset-data))
      (credits-purchased (get credits-purchased offset-data))
      (current-retired (get credits-retired offset-data))
      (new-retired-total (+ current-retired credits-to-retire))
    )
    (asserts! (is-valid-product-id product-id) err-invalid-input)
    (asserts! (is-valid-credits credits-to-retire) err-invalid-input)
    (asserts! (is-eq tx-sender manufacturer) err-unauthorized)
    (asserts! (is-eq tx-sender purchaser) err-unauthorized)
    (asserts! (<= new-retired-total credits-purchased) err-insufficient-credits)
    
    (map-set carbon-offsets
      { product-id: product-id }
      (merge offset-data 
        { 
          credits-retired: new-retired-total,
          retirement-timestamp: (some current-height)
        }
      )
    )
    (ok true)
  )
)

(define-public (verify-carbon-offset (product-id uint))
  (let
    (
      (offset-data (unwrap! (map-get? carbon-offsets { product-id: product-id }) err-not-found))
    )
    (asserts! (is-valid-product-id product-id) err-invalid-input)
    (asserts! (is-authorized-verifier tx-sender) err-unauthorized)
    
    (map-set carbon-offsets
      { product-id: product-id }
      (merge offset-data { verified: true })
    )
    (ok true)
  )
)

(define-public (update-product-status (product-id uint) (new-status (string-ascii 16)))
  (let
    (
      (product-data (unwrap! (map-get? products { product-id: product-id }) err-not-found))
      (manufacturer (get manufacturer product-data))
    )
    (asserts! (is-valid-product-id product-id) err-invalid-input)
    (asserts! (is-eq tx-sender manufacturer) err-unauthorized)
    (asserts! (or (is-eq new-status "registered") 
                  (is-eq new-status "in-transit") 
                  (is-eq new-status "delivered") 
                  (is-eq new-status "verified")) err-invalid-status)
    
    (map-set products
      { product-id: product-id }
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