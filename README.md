# CarbonThread 🧵

A blockchain-based supply chain transparency platform for sustainable product verification built on Stacks.

## Overview

CarbonThread enables manufacturers, verifiers, and consumers to track and verify the sustainability credentials of products throughout their entire supply chain journey. By leveraging blockchain technology, we create an immutable record of a product's environmental impact, certifications, and supply chain steps. Now featuring **carbon offset integration** to help products achieve carbon neutrality through verified carbon credits, **consumer review system** for authentic sustainability feedback from verified purchasers, and **IoT sensor integration** for real-time environmental monitoring during transport and storage.

## Features

- **Product Registration**: Manufacturers can register products with sustainability metrics
- **Certification Management**: Authorized verifiers can issue and manage sustainability certifications
- **Supply Chain Tracking**: Track products through each step of the supply chain
- **Verification System**: Independent verification of supply chain steps and certifications
- **Carbon Offset Integration**: Purchase and link carbon credits to products for carbon neutrality
- **Carbon Credit Management**: Track and verify carbon offset purchases and retirements
- **Consumer Review System**: Verified purchasers can rate and review products' actual sustainability performance
- **Purchase Verification**: Track and verify product purchases for authentic reviews
- **IoT Sensor Integration**: Connect IoT devices to automatically track environmental conditions during transport
- **Real-time Monitoring**: Monitor temperature, humidity, and location data from authorized IoT sensors
- **Alert System**: Automatic alerts when environmental thresholds are breached
- **Batch Tracking**: Group products into batches for streamlined management and recalls
- **Transparency**: Public access to product sustainability data, carbon offset status, consumer reviews, and sensor readings

## Smart Contract Functions

### Public Functions

#### Product & Supply Chain Management
- `register-product` - Register a new product with sustainability data
- `add-certification` - Add sustainability certifications to products
- `add-supply-chain-step` - Add a new step in the product's supply chain
- `verify-supply-chain-step` - Verify a supply chain step (authorized verifiers only)
- `update-product-status` - Update product status (manufacturer only)

#### Carbon Offset Management
- `purchase-carbon-offset` - Purchase carbon credits to offset a product's emissions
- `retire-carbon-credits` - Retire carbon credits for permanent offset
- `verify-carbon-offset` - Verify carbon offset purchases (authorized verifiers only)

#### Consumer Review System
- `record-purchase` - Record a product purchase for review eligibility
- `verify-purchase` - Verify a product purchase (authorized verifiers only)
- `add-consumer-review` - Add a consumer review with sustainability ratings (verified purchasers only)

#### IoT Sensor Management
- `register-iot-device` - Register a new IoT sensor device
- `authorize-iot-device` - Authorize an IoT device to submit sensor data (authorized verifiers only)
- `revoke-iot-device` - Revoke IoT device authorization (authorized verifiers only)
- `set-product-monitoring-thresholds` - Set environmental thresholds for products (manufacturer only)
- `record-sensor-data` - Record environmental sensor readings from authorized IoT devices
- `verify-sensor-reading` - Verify sensor reading authenticity (authorized verifiers only)

#### Administration
- `authorize-verifier` - Authorize a new verifier (contract owner only)
- `revoke-verifier` - Revoke verifier authorization (contract owner only)
- `set-platform-fee` - Set platform fee (contract owner only)

### Read-Only Functions

- `get-product` - Retrieve product information including review aggregates
- `get-certification` - Get certification details
- `get-supply-chain-step` - Get supply chain step information
- `get-carbon-offset` - Get carbon offset details for a product
- `get-consumer-review` - Get specific consumer review
- `get-purchase` - Get purchase record details
- `get-iot-device` - Get IoT device information and authorization status
- `get-sensor-reading` - Get specific sensor reading data
- `get-product-thresholds` - Get environmental monitoring thresholds for a product
- `is-carbon-neutral` - Check if a product has achieved carbon neutrality
- `has-verified-purchase` - Check if user has verified purchase for reviews
- `is-authorized-verifier` - Check if a principal is an authorized verifier
- `is-iot-device-authorized` - Check if an IoT device is authorized

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

### Record a Purchase

```clarity
(contract-call? .carbonthread record-purchase u1)
```

### Add Consumer Review

```clarity
(contract-call? .carbonthread add-consumer-review 
  u1        ;; product-id
  u1        ;; purchase-id
  u4        ;; overall-rating (1-5)
  u5        ;; sustainability-rating (1-5)
  u4        ;; quality-rating (1-5)
  "Excellent sustainable product, matches all claims!")
```

### Register IoT Device

```clarity
(contract-call? .carbonthread register-iot-device 
  "TEMP-SENSOR-001" 
  "Temperature Monitor")
```

### Set Environmental Thresholds

```clarity
(contract-call? .carbonthread set-product-monitoring-thresholds 
  u1        ;; product-id
  2         ;; min-temperature (°C)
  8         ;; max-temperature (°C)
  u30       ;; min-humidity (%)
  u70)      ;; max-humidity (%)
```

### Record Sensor Data

```clarity
(contract-call? .carbonthread record-sensor-data 
  u1                        ;; product-id
  "TEMP-SENSOR-001"        ;; device-id
  "temperature-humidity"    ;; sensor-type
  (some 5)                 ;; temperature (°C)
  (some u45)               ;; humidity (%)
  (some 40712345)          ;; location-lat
  (some -74006789))        ;; location-long
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

## IoT Sensor Integration Features

The IoT sensor integration enables:
- **Device Registration**: Register and authorize IoT sensor devices on-chain
- **Real-time Data Collection**: Automatically record temperature, humidity, and location data
- **Threshold Monitoring**: Set custom environmental thresholds for each product
- **Automatic Alerts**: System triggers alerts when conditions exceed safe thresholds
- **Data Verification**: Authorized verifiers can validate sensor readings
- **Immutable Records**: All sensor data permanently recorded on blockchain
- **Transport Monitoring**: Track environmental conditions throughout the supply chain
- **Quality Assurance**: Ensure products maintained proper conditions during transit

### Supported Sensor Types
- **Temperature Sensors**: Monitor ambient and product temperature
- **Humidity Sensors**: Track moisture levels during transport
- **GPS/Location Sensors**: Record geographic coordinates during transit
- **Multi-function Sensors**: Combined environmental monitoring devices

### IoT Use Cases
1. **Cold Chain Monitoring**: Ensure perishable goods stay within temperature range
2. **Quality Control**: Verify products maintained optimal conditions
3. **Compliance Verification**: Prove adherence to storage and transport requirements
4. **Damage Prevention**: Early warning system for environmental breaches
5. **Insurance Claims**: Provide verifiable proof of proper handling

## Consumer Review Features

The consumer review system enables:
- **Verified Reviews**: Only verified purchasers can leave reviews
- **Multi-dimensional Ratings**: Rate overall quality, sustainability, and product quality separately
- **Purchase Tracking**: Immutable record of product purchases on-chain
- **Review Aggregation**: Automatic calculation of average ratings and sustainability scores
- **Transparency**: All reviews are publicly verifiable on the blockchain
- **Anti-fraud**: Purchase verification prevents fake reviews

### Review Rating Scale
- **Overall Rating**: 1-5 stars for general product satisfaction
- **Sustainability Rating**: 1-5 stars for how well the product meets sustainability claims
- **Quality Rating**: 1-5 stars for product build quality and durability

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
- Advanced review analytics and sentiment analysis
- Integration with e-commerce platforms for automatic purchase recording
- Reputation system for reviewers
- Machine learning for sensor data anomaly detection
- Integration with major IoT platforms (AWS IoT, Azure IoT Hub)
- Predictive analytics for environmental condition forecasting
- Real-time dashboard for supply chain monitoring
- Automated compliance reporting

## Technical Architecture

### IoT Integration Architecture
```
IoT Devices → Data Gateway → Smart Contract → Blockchain
                    ↓
              Threshold Check
                    ↓
              Alert Generation
```

### Data Flow
1. IoT device collects environmental data
2. Data transmitted to authorized gateway
3. Smart contract validates device authorization
4. Threshold checks performed automatically
5. Data recorded immutably on blockchain
6. Alerts triggered if thresholds breached
7. Verifiers can validate readings

## Security Considerations

- Only authorized IoT devices can submit sensor data
- All sensor readings require verification by authorized verifiers
- Environmental thresholds can only be set by manufacturers
- Device authorization managed by trusted verifiers
- Immutable audit trail for all sensor data

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

---

*Weaving sustainability into every thread of the supply chain* 🌍