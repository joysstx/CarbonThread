# CarbonThread 🧵

A blockchain-based supply chain transparency platform for sustainable product verification built on Stacks.

## Overview

CarbonThread enables manufacturers, verifiers, and consumers to track and verify the sustainability credentials of products throughout their entire supply chain journey. By leveraging blockchain technology, we create an immutable record of a product's environmental impact, certifications, and supply chain steps. Now featuring **carbon offset integration** to help products achieve carbon neutrality through verified carbon credits.

## Features

- **Product Registration**: Manufacturers can register products with sustainability metrics
- **Certification Management**: Authorized verifiers can issue and manage sustainability certifications
- **Supply Chain Tracking**: Track products through each step of the supply chain
- **Verification System**: Independent verification of supply chain steps and certifications
- **Carbon Offset Integration**: Purchase and link carbon credits to products for carbon neutrality
- **Carbon Credit Management**: Track and verify carbon offset purchases and retirements
- **Transparency**: Public access to product sustainability data and carbon offset status

## Smart Contract Functions

### Public Functions

- `register-product` - Register a new product with sustainability data
- `add-certification` - Add sustainability certifications to products
- `add-supply-chain-step` - Add a new step in the product's supply chain
- `verify-supply-chain-step` - Verify a supply chain step (authorized verifiers only)
- `update-product-status` - Update product status (manufacturer only)
- `purchase-carbon-offset` - Purchase carbon credits to offset a product's emissions
- `retire-carbon-credits` - Retire carbon credits for permanent offset
- `authorize-verifier` - Authorize a new verifier (contract owner only)
- `revoke-verifier` - Revoke verifier authorization (contract owner only)

### Read-Only Functions

- `get-product` - Retrieve product information
- `get-certification` - Get certification details
- `get-supply-chain-step` - Get supply chain step information
- `get-carbon-offset` - Get carbon offset details for a product
- `is-carbon-neutral` - Check if a product has achieved carbon neutrality
- `is-authorized-verifier` - Check if a principal is an authorized verifier

## Installation

1. Install Clarinet: `npm install -g @hirosystems/clarinet`
2. Clone the repository
3. Run `clarinet check` to verify contract syntax
4. Deploy to testnet with `clarinet deploy`

## Usage

### Register a Product

```clarity
(contract-call? .carbonthread register-product 
  "Organic Cotton T-Shirt" 
  "Textiles" 
  "Gujarat, India" 
  u500 
  u85)
```

### Add Certification

```clarity
(contract-call? .carbonthread add-certification 
  u1 
  "Organic" 
  0x1234567890abcdef 
  u1000000)
```

### Purchase Carbon Offset

```clarity
(contract-call? .carbonthread purchase-carbon-offset 
  u1 
  u500 
  "VCS-123456789" 
  "Reforestation Project - Brazil")
```

### Retire Carbon Credits

```clarity
(contract-call? .carbonthread retire-carbon-credits 
  u1 
  u500)
```

## Testing

Run the test suite:
```bash
clarinet test
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Carbon Offset Features

The carbon offset integration allows:
- **Offset Purchases**: Link verified carbon credits to products
- **Credit Retirement**: Permanently retire credits for authentic carbon neutrality
- **Transparency**: Track all offset transactions on-chain
- **Verification**: Authorized verifiers can validate offset purchases
- **Status Tracking**: Monitor carbon neutral status of products

## Roadmap

- Enhanced carbon credit marketplace integration
- Automated offset calculations based on supply chain data
- Integration with major carbon registries
- Mobile app for consumer verification

---

*Weaving sustainability into every thread of the supply chain* 🌍