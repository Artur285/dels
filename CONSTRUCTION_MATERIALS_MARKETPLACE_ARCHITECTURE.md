# Construction Materials Leasing Marketplace - Backend Architecture

## Executive Summary

This document outlines a scalable, multi-country marketplace backend architecture for leasing construction materials with AI-powered recommendations, supporting REST and GraphQL APIs with event-driven architecture.

---

## 1. High-Level Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        API Gateway Layer                         │
│  (Kong/AWS API Gateway - Rate Limiting, Auth, Load Balancing)   │
└─────────────────┬──────────────────────────┬───────────────────┘
                  │                          │
        ┌─────────▼─────────┐      ┌────────▼────────┐
        │   REST API Layer   │      │  GraphQL Layer  │
        │   (Express.js)     │      │   (Apollo)      │
        └─────────┬─────────┘      └────────┬────────┘
                  │                          │
                  └──────────┬───────────────┘
                             │
        ┌────────────────────▼────────────────────┐
        │         Service Mesh (Istio)            │
        │    (Service Discovery, Observability)   │
        └────────────────────┬────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
    ┌───▼───┐          ┌────▼────┐        ┌─────▼────┐
    │Supplier│          │Leasing  │        │  User    │
    │Service │          │Service  │        │ Service  │
    └───┬───┘          └────┬────┘        └─────┬────┘
        │                    │                    │
    ┌───▼───┐          ┌────▼────┐        ┌─────▼────┐
    │Inventory│        │Contract │        │  Auth    │
    │Service  │        │Service  │        │ Service  │
    └───┬───┘          └────┬────┘        └─────┬────┘
        │                    │                    │
    ┌───▼───┐          ┌────▼────┐        ┌─────▼────┐
    │Payment │          │  AI     │        │ Notification│
    │Service │          │Recommend│        │  Service   │
    └───┬───┘          └────┬────┘        └─────┬──────┘
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
        ┌────────────────────▼────────────────────┐
        │         Event Bus (Apache Kafka)        │
        │  (contract.created, inventory.updated)  │
        └────────────────────┬────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
    ┌───▼────────┐    ┌─────▼──────┐    ┌──────▼───────┐
    │ PostgreSQL  │    │   Redis    │    │  Elasticsearch│
    │  (Primary)  │    │  (Cache)   │    │   (Search)   │
    └────────────┘    └────────────┘    └──────────────┘
```

### Key Architectural Principles

1. **Microservices Architecture**: Domain-driven design with independent services
2. **Event-Driven**: Asynchronous communication via Kafka
3. **Multi-Tenancy**: Support for multiple countries with data isolation
4. **CQRS Pattern**: Separate read and write models for scalability
5. **API-First**: REST for CRUD, GraphQL for complex queries
6. **Cloud-Native**: Containerized services (Docker/Kubernetes)

---

## 2. Database Schema (PostgreSQL)

### Core Tables

```sql
-- Multi-tenancy support
CREATE TABLE countries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(3) UNIQUE NOT NULL, -- ISO 3166-1 alpha-3
    name VARCHAR(100) NOT NULL,
    currency_code VARCHAR(3) NOT NULL, -- ISO 4217
    timezone VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Suppliers (multi-country support)
CREATE TABLE suppliers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_id UUID NOT NULL REFERENCES countries(id),
    company_name VARCHAR(255) NOT NULL,
    company_registration VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    address JSONB NOT NULL, -- Flexible address structure per country
    verification_status VARCHAR(20) DEFAULT 'pending', -- pending, verified, rejected
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_reviews INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT rating_check CHECK (rating >= 0 AND rating <= 5)
);

CREATE INDEX idx_suppliers_country ON suppliers(country_id);
CREATE INDEX idx_suppliers_verification ON suppliers(verification_status);

-- Material Categories
CREATE TABLE material_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES material_categories(id),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icon_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Materials Catalog
CREATE TABLE materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES material_categories(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    specifications JSONB, -- Flexible specs (dimensions, weight, material type, etc.)
    images JSONB, -- Array of image URLs
    unit_of_measurement VARCHAR(20) NOT NULL, -- pieces, kg, m3, etc.
    available_quantity DECIMAL(10,2) NOT NULL,
    min_lease_quantity DECIMAL(10,2) DEFAULT 1,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT positive_quantity CHECK (available_quantity >= 0)
);

CREATE INDEX idx_materials_supplier ON materials(supplier_id);
CREATE INDEX idx_materials_category ON materials(category_id);
CREATE INDEX idx_materials_availability ON materials(is_available) WHERE is_available = true;

-- Pricing (time-based)
CREATE TABLE material_pricing (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    material_id UUID NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
    pricing_tier VARCHAR(50) NOT NULL, -- hourly, daily, weekly, monthly
    price_per_unit DECIMAL(10,2) NOT NULL,
    currency_code VARCHAR(3) NOT NULL,
    min_duration INTEGER, -- Minimum rental duration in hours
    max_duration INTEGER, -- Maximum rental duration in hours
    discount_percentage DECIMAL(5,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT positive_price CHECK (price_per_unit >= 0)
);

CREATE INDEX idx_pricing_material ON material_pricing(material_id);

-- Users/Customers
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_id UUID NOT NULL REFERENCES countries(id),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    company_name VARCHAR(255),
    phone VARCHAR(50),
    address JSONB,
    role VARCHAR(20) DEFAULT 'customer', -- customer, supplier, admin
    is_verified BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_country ON users(country_id);

-- Leasing Contracts
CREATE TABLE leasing_contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_number VARCHAR(50) UNIQUE NOT NULL,
    user_id UUID NOT NULL REFERENCES users(id),
    supplier_id UUID NOT NULL REFERENCES suppliers(id),
    country_id UUID NOT NULL REFERENCES countries(id),
    status VARCHAR(20) DEFAULT 'draft', -- draft, pending, active, completed, cancelled
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    actual_return_date TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    currency_code VARCHAR(3) NOT NULL,
    deposit_amount DECIMAL(10,2) DEFAULT 0,
    terms_and_conditions TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_dates CHECK (end_date > start_date)
);

CREATE INDEX idx_contracts_user ON leasing_contracts(user_id);
CREATE INDEX idx_contracts_supplier ON leasing_contracts(supplier_id);
CREATE INDEX idx_contracts_status ON leasing_contracts(status);
CREATE INDEX idx_contracts_dates ON leasing_contracts(start_date, end_date);

-- Contract Line Items
CREATE TABLE contract_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID NOT NULL REFERENCES leasing_contracts(id) ON DELETE CASCADE,
    material_id UUID NOT NULL REFERENCES materials(id),
    quantity DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    pricing_tier VARCHAR(50) NOT NULL,
    duration_hours INTEGER NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT positive_quantity CHECK (quantity > 0)
);

CREATE INDEX idx_contract_items_contract ON contract_items(contract_id);
CREATE INDEX idx_contract_items_material ON contract_items(material_id);

-- Payments
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID NOT NULL REFERENCES leasing_contracts(id),
    user_id UUID NOT NULL REFERENCES users(id),
    payment_type VARCHAR(20) NOT NULL, -- deposit, lease_payment, penalty, refund
    amount DECIMAL(10,2) NOT NULL,
    currency_code VARCHAR(3) NOT NULL,
    payment_method VARCHAR(50), -- credit_card, bank_transfer, etc.
    payment_provider VARCHAR(50), -- stripe, paypal, etc.
    transaction_id VARCHAR(255) UNIQUE,
    status VARCHAR(20) DEFAULT 'pending', -- pending, completed, failed, refunded
    processed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT positive_amount CHECK (amount >= 0)
);

CREATE INDEX idx_payments_contract ON payments(contract_id);
CREATE INDEX idx_payments_user ON payments(user_id);
CREATE INDEX idx_payments_status ON payments(status);

-- Reviews and Ratings
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID NOT NULL REFERENCES leasing_contracts(id),
    user_id UUID NOT NULL REFERENCES users(id),
    supplier_id UUID NOT NULL REFERENCES suppliers(id),
    rating INTEGER NOT NULL,
    comment TEXT,
    response TEXT, -- Supplier response
    responded_at TIMESTAMP,
    is_verified BOOLEAN DEFAULT false, -- Verified purchase
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT rating_range CHECK (rating >= 1 AND rating <= 5)
);

CREATE INDEX idx_reviews_supplier ON reviews(supplier_id);
CREATE INDEX idx_reviews_contract ON reviews(contract_id);

-- AI Recommendations Data (for ML model)
CREATE TABLE user_interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    material_id UUID REFERENCES materials(id),
    interaction_type VARCHAR(50) NOT NULL, -- view, search, cart_add, contract_created
    metadata JSONB, -- Additional context (search terms, filters used, etc.)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_interactions_user ON user_interactions(user_id);
CREATE INDEX idx_interactions_material ON user_interactions(material_id);
CREATE INDEX idx_interactions_type ON user_interactions(interaction_type);

-- Search History (for AI)
CREATE TABLE search_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    search_query TEXT NOT NULL,
    filters JSONB, -- Applied filters
    results_count INTEGER,
    clicked_material_id UUID REFERENCES materials(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_search_user ON search_history(user_id);
CREATE INDEX idx_search_created ON search_history(created_at);

-- Inventory Reservations
CREATE TABLE inventory_reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    material_id UUID NOT NULL REFERENCES materials(id),
    contract_id UUID REFERENCES leasing_contracts(id),
    quantity DECIMAL(10,2) NOT NULL,
    reserved_from TIMESTAMP NOT NULL,
    reserved_until TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'active', -- active, released, consumed
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_reservations_material ON inventory_reservations(material_id);
CREATE INDEX idx_reservations_dates ON inventory_reservations(reserved_from, reserved_until);
```

### Database Sharding Strategy

- **Horizontal Sharding by Country**: Each country gets its own database instance
- **Shard Key**: `country_id`
- **Benefits**: 
  - Data sovereignty compliance (GDPR, local regulations)
  - Improved query performance
  - Isolated failure domains
  - Easier regional scaling

---

## 3. Core Services

### 3.1 User Service
**Responsibilities:**
- User registration and authentication (JWT tokens)
- Profile management
- Role-based access control (RBAC)
- Password reset and email verification

**Tech Stack:** Node.js (Express), PostgreSQL, Redis (sessions), JWT

**Key Endpoints:**
```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh-token
GET    /api/v1/users/:id
PUT    /api/v1/users/:id
DELETE /api/v1/users/:id
```

---

### 3.2 Supplier Service
**Responsibilities:**
- Supplier registration and verification
- Company profile management
- Multi-country supplier support
- Rating and review aggregation

**Tech Stack:** Node.js (Express), PostgreSQL

**Key Endpoints:**
```
POST   /api/v1/suppliers
GET    /api/v1/suppliers/:id
PUT    /api/v1/suppliers/:id
POST   /api/v1/suppliers/:id/verify
GET    /api/v1/suppliers/:id/ratings
```

---

### 3.3 Inventory Service
**Responsibilities:**
- Material catalog management
- Real-time availability tracking
- Category management
- Image and specification storage (S3)

**Tech Stack:** Node.js (Express), PostgreSQL, Redis (cache), AWS S3

**Key Endpoints:**
```
POST   /api/v1/materials
GET    /api/v1/materials/:id
PUT    /api/v1/materials/:id
DELETE /api/v1/materials/:id
GET    /api/v1/materials/search
GET    /api/v1/materials/categories
POST   /api/v1/materials/:id/images
```

**Event Publishing:**
- `inventory.created`
- `inventory.updated`
- `inventory.depleted`

---

### 3.4 Leasing Service
**Responsibilities:**
- Contract lifecycle management (draft → active → completed)
- Time-based pricing calculations
- Deposit and penalty management
- Contract document generation (PDF)

**Tech Stack:** Node.js (Express), PostgreSQL, Redis (locking), PDFKit

**Key Endpoints:**
```
POST   /api/v1/contracts
GET    /api/v1/contracts/:id
PUT    /api/v1/contracts/:id
POST   /api/v1/contracts/:id/approve
POST   /api/v1/contracts/:id/cancel
POST   /api/v1/contracts/:id/return
GET    /api/v1/contracts/:id/document
```

**Event Publishing:**
- `contract.created`
- `contract.approved`
- `contract.completed`
- `contract.cancelled`

---

### 3.5 Payment Service
**Responsibilities:**
- Payment processing (Stripe, PayPal integration)
- Multi-currency support
- Refund handling
- Payment verification

**Tech Stack:** Node.js (Express), PostgreSQL, Stripe SDK, PayPal SDK

**Key Endpoints:**
```
POST   /api/v1/payments
GET    /api/v1/payments/:id
POST   /api/v1/payments/:id/refund
GET    /api/v1/payments/contract/:contractId
```

**Event Publishing:**
- `payment.completed`
- `payment.failed`
- `payment.refunded`

---

### 3.6 AI Recommendation Service
**Responsibilities:**
- Personalized material recommendations
- Similar materials suggestions
- Predictive demand forecasting
- Search ranking optimization

**Tech Stack:** Python (FastAPI), TensorFlow/PyTorch, PostgreSQL, Redis

**ML Models:**
1. **Collaborative Filtering**: User-item interactions
2. **Content-Based**: Material specifications and categories
3. **Hybrid Model**: Combines both approaches
4. **Time-Series Forecasting**: Demand prediction

**Key Endpoints:**
```
GET    /api/v1/ai/recommendations/:userId
POST   /api/v1/ai/recommendations/similar
POST   /api/v1/ai/track-interaction
GET    /api/v1/ai/trending-materials
GET    /api/v1/ai/demand-forecast/:materialId
```

**AI Features:**
- Real-time recommendations using cached embeddings
- A/B testing framework for model evaluation
- Feedback loop for continuous learning
- Explainable AI (why these recommendations?)

---

### 3.7 Notification Service
**Responsibilities:**
- Email notifications (SendGrid)
- SMS alerts (Twilio)
- In-app notifications (WebSockets)
- Push notifications (FCM)

**Tech Stack:** Node.js (Express), PostgreSQL, Redis (queue), SendGrid, Twilio

**Event Subscriptions:**
- `contract.created` → Email confirmation
- `payment.completed` → Payment receipt
- `contract.ending-soon` → Reminder notification
- `inventory.depleted` → Supplier alert

---

### 3.8 Search Service
**Responsibilities:**
- Full-text search across materials
- Faceted search and filtering
- Auto-suggestions
- Search analytics

**Tech Stack:** Node.js (Express), Elasticsearch, Redis

**Key Endpoints:**
```
GET    /api/v1/search/materials?q=...&filters=...
GET    /api/v1/search/suggestions?q=...
GET    /api/v1/search/facets
```

---

## 4. API Endpoints

### 4.1 REST API (Express.js)

#### Authentication
```javascript
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/logout
POST   /api/v1/auth/refresh-token
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/reset-password
```

#### Materials
```javascript
GET    /api/v1/materials
GET    /api/v1/materials/:id
POST   /api/v1/materials
PUT    /api/v1/materials/:id
DELETE /api/v1/materials/:id
GET    /api/v1/materials/:id/availability
POST   /api/v1/materials/:id/reserve
```

#### Contracts
```javascript
GET    /api/v1/contracts
GET    /api/v1/contracts/:id
POST   /api/v1/contracts
PUT    /api/v1/contracts/:id
DELETE /api/v1/contracts/:id
POST   /api/v1/contracts/:id/approve
POST   /api/v1/contracts/:id/cancel
POST   /api/v1/contracts/:id/extend
```

#### Payments
```javascript
GET    /api/v1/payments
GET    /api/v1/payments/:id
POST   /api/v1/payments
POST   /api/v1/payments/:id/refund
GET    /api/v1/payments/history
```

#### Reviews
```javascript
GET    /api/v1/reviews/supplier/:supplierId
POST   /api/v1/reviews
PUT    /api/v1/reviews/:id
DELETE /api/v1/reviews/:id
```

---

### 4.2 GraphQL API (Apollo Server)

#### Schema Definition

```graphql
type Query {
  # Materials
  material(id: ID!): Material
  materials(
    filters: MaterialFilters
    pagination: PaginationInput
    sort: SortInput
  ): MaterialConnection!
  
  # Contracts
  contract(id: ID!): Contract
  myContracts(status: ContractStatus): [Contract!]!
  
  # Suppliers
  supplier(id: ID!): Supplier
  suppliers(countryId: ID): [Supplier!]!
  
  # AI Recommendations
  recommendedMaterials(userId: ID!): [Material!]!
  similarMaterials(materialId: ID!): [Material!]!
  trendingMaterials(countryId: ID): [Material!]!
}

type Mutation {
  # Authentication
  register(input: RegisterInput!): AuthPayload!
  login(email: String!, password: String!): AuthPayload!
  
  # Materials
  createMaterial(input: MaterialInput!): Material!
  updateMaterial(id: ID!, input: MaterialInput!): Material!
  deleteMaterial(id: ID!): Boolean!
  
  # Contracts
  createContract(input: ContractInput!): Contract!
  approveContract(id: ID!): Contract!
  cancelContract(id: ID!, reason: String): Contract!
  
  # Payments
  processPayment(input: PaymentInput!): Payment!
  refundPayment(id: ID!): Payment!
  
  # Reviews
  createReview(input: ReviewInput!): Review!
}

type Subscription {
  # Real-time updates
  contractStatusChanged(contractId: ID!): Contract!
  inventoryUpdated(materialId: ID!): Material!
  paymentProcessed(contractId: ID!): Payment!
}

# Types
type Material {
  id: ID!
  name: String!
  description: String
  category: MaterialCategory!
  supplier: Supplier!
  specifications: JSON
  images: [String!]!
  pricing: [MaterialPricing!]!
  availableQuantity: Float!
  unit: String!
  rating: Float
  reviewCount: Int!
  isAvailable: Boolean!
}

type MaterialCategory {
  id: ID!
  name: String!
  slug: String!
  parent: MaterialCategory
  children: [MaterialCategory!]!
}

type Supplier {
  id: ID!
  companyName: String!
  country: Country!
  email: String!
  phone: String
  address: JSON!
  rating: Float!
  totalReviews: Int!
  verificationStatus: VerificationStatus!
  materials: [Material!]!
}

type Contract {
  id: ID!
  contractNumber: String!
  user: User!
  supplier: Supplier!
  status: ContractStatus!
  items: [ContractItem!]!
  startDate: DateTime!
  endDate: DateTime!
  totalAmount: Float!
  currency: String!
  payments: [Payment!]!
}

type ContractItem {
  id: ID!
  material: Material!
  quantity: Float!
  unitPrice: Float!
  pricingTier: String!
  durationHours: Int!
  subtotal: Float!
}

type Payment {
  id: ID!
  contract: Contract!
  amount: Float!
  currency: String!
  paymentType: PaymentType!
  status: PaymentStatus!
  transactionId: String
  processedAt: DateTime
}

type Review {
  id: ID!
  contract: Contract!
  user: User!
  supplier: Supplier!
  rating: Int!
  comment: String
  response: String
  createdAt: DateTime!
}

# Inputs
input MaterialFilters {
  categoryId: ID
  supplierId: ID
  countryId: ID
  minPrice: Float
  maxPrice: Float
  isAvailable: Boolean
  search: String
}

input ContractInput {
  supplierId: ID!
  items: [ContractItemInput!]!
  startDate: DateTime!
  endDate: DateTime!
  notes: String
}

input ContractItemInput {
  materialId: ID!
  quantity: Float!
  pricingTier: String!
}

# Enums
enum ContractStatus {
  DRAFT
  PENDING
  ACTIVE
  COMPLETED
  CANCELLED
}

enum PaymentStatus {
  PENDING
  COMPLETED
  FAILED
  REFUNDED
}

enum PaymentType {
  DEPOSIT
  LEASE_PAYMENT
  PENALTY
  REFUND
}

enum VerificationStatus {
  PENDING
  VERIFIED
  REJECTED
}
```

---

## 5. Event-Driven Architecture (Apache Kafka)

### Event Topics

```yaml
topics:
  - name: inventory.events
    partitions: 12
    replication_factor: 3
    events:
      - inventory.created
      - inventory.updated
      - inventory.depleted
      - inventory.reserved
      - inventory.released
  
  - name: contract.events
    partitions: 12
    replication_factor: 3
    events:
      - contract.created
      - contract.approved
      - contract.active
      - contract.completed
      - contract.cancelled
      - contract.extended
  
  - name: payment.events
    partitions: 8
    replication_factor: 3
    events:
      - payment.initiated
      - payment.completed
      - payment.failed
      - payment.refunded
  
  - name: user.events
    partitions: 8
    replication_factor: 3
    events:
      - user.registered
      - user.verified
      - user.profile_updated
  
  - name: ai.events
    partitions: 16
    replication_factor: 3
    events:
      - interaction.tracked
      - recommendation.served
      - search.performed
```

### Event Schema Example

```json
{
  "eventId": "uuid",
  "eventType": "contract.created",
  "timestamp": "2024-01-05T12:00:00Z",
  "version": "1.0",
  "source": "leasing-service",
  "payload": {
    "contractId": "uuid",
    "userId": "uuid",
    "supplierId": "uuid",
    "countryId": "uuid",
    "totalAmount": 5000.00,
    "currency": "USD",
    "startDate": "2024-01-10T08:00:00Z",
    "endDate": "2024-02-10T08:00:00Z",
    "items": [
      {
        "materialId": "uuid",
        "quantity": 10,
        "unitPrice": 50.00
      }
    ]
  },
  "metadata": {
    "correlationId": "uuid",
    "userId": "uuid",
    "traceId": "uuid"
  }
}
```

### Event Consumers

1. **Notification Service**: Listens to all events, sends notifications
2. **Analytics Service**: Processes events for business intelligence
3. **AI Service**: Consumes interaction events for model training
4. **Inventory Service**: Updates availability based on contract events
5. **Audit Service**: Logs all events for compliance

---

## 6. Technology Stack Summary

### Backend Services
- **Primary Language**: Node.js 20+ (Express.js)
- **AI Service**: Python 3.11+ (FastAPI)
- **Database**: PostgreSQL 15+
- **Cache**: Redis 7+
- **Search**: Elasticsearch 8+
- **Message Queue**: Apache Kafka 3.5+
- **API Gateway**: Kong or AWS API Gateway
- **Service Mesh**: Istio

### Infrastructure
- **Container Orchestration**: Kubernetes (EKS/GKE/AKS)
- **Service Discovery**: Kubernetes DNS + Istio
- **CI/CD**: GitHub Actions / GitLab CI
- **Monitoring**: Prometheus + Grafana
- **Logging**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **Tracing**: Jaeger
- **Storage**: AWS S3 / Google Cloud Storage

### AI/ML Stack
- **Framework**: TensorFlow 2.x or PyTorch 2.x
- **Feature Store**: Feast
- **Model Serving**: TensorFlow Serving / TorchServe
- **Experiment Tracking**: MLflow
- **Vector Database**: Pinecone or Weaviate

### Security
- **Authentication**: JWT (RS256)
- **Authorization**: RBAC with Casbin
- **API Security**: OAuth 2.0, Rate Limiting
- **Data Encryption**: AES-256 (at rest), TLS 1.3 (in transit)
- **Secret Management**: HashiCorp Vault
- **DDoS Protection**: Cloudflare

---

## 7. Scalability Considerations

### Horizontal Scaling
- **Stateless Services**: All services are containerized and stateless
- **Auto-scaling**: Kubernetes HPA based on CPU/Memory/Custom metrics
- **Database Read Replicas**: Read-heavy queries use replicas
- **Caching Strategy**: Redis for hot data, CDN for static assets

### Performance Optimization
- **Database Indexing**: Strategic indexes on high-traffic queries
- **Connection Pooling**: PgBouncer for PostgreSQL
- **Query Optimization**: EXPLAIN ANALYZE for slow queries
- **API Response Compression**: Gzip compression
- **GraphQL Data Loader**: Batch and cache database queries

### Geographic Distribution
- **Multi-Region Deployment**: Services deployed in US, EU, APAC
- **CDN**: CloudFront/Cloudflare for static content
- **Database Sharding**: By country for data sovereignty
- **Latency Optimization**: Regional endpoints with geo-routing

---

## 8. Security & Compliance

### Data Protection
- **GDPR Compliance**: Data retention policies, right to be forgotten
- **PCI-DSS**: Payment data encryption, tokenization
- **Data Masking**: Sensitive data masked in logs
- **Backup Strategy**: Automated daily backups, 30-day retention

### API Security
- **Rate Limiting**: 1000 requests/hour per user
- **Input Validation**: Schema validation with Joi/Yup
- **SQL Injection Prevention**: Parameterized queries
- **XSS Protection**: Content Security Policy headers
- **CORS**: Configured for allowed origins only

---

## 9. Monitoring & Observability

### Metrics (Prometheus)
- Service health checks
- Request latency (p50, p95, p99)
- Error rates
- Database connection pool metrics
- Kafka consumer lag

### Logging (ELK)
- Structured logging (JSON format)
- Centralized log aggregation
- Log retention: 90 days
- Search and analysis capabilities

### Tracing (Jaeger)
- Distributed tracing across services
- Request flow visualization
- Performance bottleneck identification

### Alerting (PagerDuty)
- Service down alerts
- High error rate alerts
- Database connection failures
- Kafka consumer lag alerts

---

## 10. Deployment Strategy

### CI/CD Pipeline
```yaml
stages:
  - test
  - build
  - deploy-staging
  - integration-tests
  - deploy-production

test:
  - Unit tests (Jest, Pytest)
  - Integration tests
  - Code coverage > 80%
  - Security scanning (Snyk, OWASP)

build:
  - Docker image build
  - Image scanning (Trivy)
  - Push to registry (ECR/GCR)

deploy:
  - Blue-Green deployment
  - Canary releases (10% → 50% → 100%)
  - Automatic rollback on errors
  - Health checks
```

### Database Migrations
- **Tool**: Flyway or Knex.js
- **Strategy**: Forward-only migrations
- **Testing**: Migrations tested in staging first
- **Rollback**: Manual rollback with down migrations

---

## 11. Cost Optimization

### Strategies
1. **Reserved Instances**: For predictable workloads
2. **Spot Instances**: For batch AI training jobs
3. **Auto-scaling**: Scale down during off-peak hours
4. **S3 Lifecycle Policies**: Move old logs to Glacier
5. **Database Query Optimization**: Reduce compute costs
6. **CDN Caching**: Reduce origin server load

---

## 12. Future Enhancements

1. **Blockchain Integration**: Smart contracts for leasing agreements
2. **IoT Integration**: Real-time tracking of leased materials
3. **AR/VR**: Virtual material inspection
4. **Voice Assistance**: Alexa/Google Assistant integration
5. **Mobile Apps**: Native iOS/Android apps
6. **B2B Portal**: Dedicated portal for enterprise customers
7. **Marketplace Expansion**: Allow third-party integrations

---

## Conclusion

This architecture provides a robust, scalable foundation for a multi-country construction materials leasing marketplace with AI-powered recommendations. The microservices approach ensures independent scaling, the event-driven architecture enables real-time updates, and the multi-region deployment ensures low latency globally.

The system is designed to handle:
- **10,000+ concurrent users**
- **1M+ materials catalog**
- **100K+ daily transactions**
- **Sub-100ms API response times**
- **99.9% uptime SLA**

---

**Document Version**: 1.0  
**Last Updated**: 2024-01-05  
**Author**: Senior Backend Architect  
