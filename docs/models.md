# Models Documentation

This document provides a comprehensive overview of all data models used in the Pay App.

## Overview

The app uses a well-structured model system to represent data entities throughout the application. Models are organized in the `lib/models` directory and follow consistent patterns for serialization, deserialization, and data manipulation.

## Model Architecture

### Core Principles
- **Immutable by default**: Most models use `final` properties for data integrity
- **JSON serialization**: All models support `fromJson()` and `toMap()` methods
- **Database compatibility**: Models include `fromMap()` and `toMap()` for database operations
- **Type safety**: Strong typing with enums for status fields and categories
- **Validation**: Built-in validation for data integrity

### Common Patterns
- **Factory constructors**: `fromJson()`, `fromMap()` for deserialization
- **Serialization methods**: `toMap()`, `toJson()` for data persistence
- **Copy methods**: `copyWith()` for immutable updates
- **Computed properties**: Getters for derived values
- **String representations**: `toString()` for debugging

## Core Models

### 1. `Place` (`lib/models/place.dart`)
**Purpose**: Represents a business/merchant location

**Properties:**
- `id` (int) - Unique place identifier
- `name` (String) - Place name
- `account` (String) - Wallet address
- `slug` (String) - URL-friendly identifier
- `imageUrl` (String?) - Place image URL
- `description` (String?) - Place description
- `display` (Display) - UI display mode
- `tokens` (List<String>) - Accepted token addresses

**Enums:**
- `Display` - UI display modes:
  - `amount` - Show amount input
  - `menu` - Show menu items
  - `amountAndMenu` - Show both amount and menu
  - `topup` - Show top-up interface

**Key Methods:**
- `fromJson(Map<String, dynamic>)` - Parse from API response
- `toMap()` - Convert to database format
- `toString()` - Debug representation

### 2. `MenuItem` (`lib/models/menu_item.dart`)
**Purpose**: Represents individual menu items at places

**Properties:**
- `id` (int) - Unique menu item identifier
- `placeId` (int) - Associated place ID
- `imageUrl` (String?) - Item image URL
- `price` (int) - Price in cents
- `name` (String) - Item name
- `description` (String?) - Item description
- `category` (String) - Item category
- `vat` (int) - VAT percentage
- `emoji` (String?) - Item emoji
- `order` (double) - Display order

**Computed Properties:**
- `formattedPrice` (double) - Price in decimal format
- `priceString` (String) - Formatted price string

**Key Methods:**
- `fromJson(Map<String, dynamic>)` - Parse from API
- `fromMap(Map<String, dynamic>)` - Parse from database
- `toMap()` - Convert to database format

### 3. `PlaceWithMenu` (`lib/models/place_with_menu.dart`)
**Purpose**: Combines place information with menu items

**Properties:**
- `placeId` (int) - Place identifier
- `slug` (String) - Place slug
- `place` (Place) - Place information
- `profile` (ProfileV1) - Place profile
- `items` (List<MenuItem>) - Menu items
- `mappedItems` (Map<int, MenuItem>) - Items indexed by ID

**Key Methods:**
- `fromJson(Map<String, dynamic>)` - Parse from API
- `fromMap(Map<String, dynamic>)` - Parse from database
- `fromInteraction(Interaction)` - Create from interaction
- `toMap()` - Convert to database format

### 4. `PlaceMenu` (`lib/models/place_menu.dart`)
**Purpose**: Container for menu items with utility methods

**Properties:**
- `menuItems` (List<MenuItem>) - List of menu items

**Computed Properties:**
- `menuItemsById` (Map<int, MenuItem>) - Items indexed by ID
- `categories` (List<String>) - Unique categories

**Key Methods:**
- `fromJson(Map<String, dynamic>)` - Parse from API
- `getItemsByCategory(String)` - Filter items by category
- `toMap()` - Convert to database format

## Transaction Models

### 5. `Transaction` (`lib/models/transaction.dart`)
**Purpose**: Represents blockchain transactions

**Properties:**
- `id` (String) - Unique transaction identifier
- `txHash` (String) - Blockchain transaction hash
- `contract` (String) - Token contract address
- `fromAccount` (String) - Sender address
- `toAccount` (String) - Recipient address
- `amount` (String) - Transaction amount
- `description` (String?) - Transaction description
- `status` (TransactionStatus) - Transaction status
- `createdAt` (DateTime) - Creation timestamp
- `fromProfile` (ProfileV1?) - Sender profile
- `toProfile` (ProfileV1?) - Recipient profile

**Enums:**
- `TransactionStatus` - Transaction states:
  - `sending` - Transaction being sent
  - `pending` - Awaiting confirmation
  - `success` - Confirmed on blockchain
  - `fail` - Transaction failed

**Key Methods:**
- `fromJson(Map<String, dynamic>)` - Parse from API
- `fromMap(Map<String, dynamic>)` - Parse from database
- `toMap()` - Convert to database format
- `copyWith({...})` - Create modified copy
- `upsert(Transaction, Transaction)` - Merge transactions
- `exchangeDirection(String account)` - Determine if sent/received
- `parseTransactionStatus(dynamic)` - Parse status from various types

### 6. `Interaction` (`lib/models/interaction.dart`)
**Purpose**: Represents chat/messaging interactions between users

**Properties:**
- `id` (String) - Unique interaction identifier
- `exchangeDirection` (ExchangeDirection) - Transaction direction
- `account` (String) - User account
- `withAccount` (String) - Other party account
- `imageUrl` (String?) - Profile image URL
- `name` (String) - Display name
- `contract` (String) - Token contract
- `amount` (double) - Transaction amount
- `description` (String?) - Transaction description
- `isPlace` (bool) - Whether interaction is with a place
- `isTreasury` (bool) - Whether interaction is with treasury
- `placeId` (int?) - Place identifier if applicable
- `place` (PlaceWithMenu?) - Place information if applicable
- `profile` (ProfileV1) - User profile
- `hasMenuItem` (bool) - Whether place has menu items
- `hasUnreadMessages` (bool) - Whether has unread messages
- `lastMessageAt` (DateTime) - Last message timestamp

**Enums:**
- `ExchangeDirection` - Transaction directions:
  - `sent` - User sent money
  - `received` - User received money

**Key Methods:**
- `fromJson(Map<String, dynamic>)` - Parse from API
- `fromMap(Map<String, dynamic>)` - Parse from database
- `toMap()` - Convert to database format
- `copyWith({...})` - Create modified copy
- `upsert(Interaction, Interaction)` - Merge interactions
- `parseExchangeDirection(String)` - Parse direction from string

## Order Models

### 7. `Order` (`lib/models/order.dart`)
**Purpose**: Represents purchase orders at places

**Properties:**
- `id` (int) - Unique order identifier
- `createdAt` (DateTime) - Creation timestamp
- `completedAt` (DateTime?) - Completion timestamp
- `total` (double) - Total amount
- `due` (double) - Amount due
- `slug` (String) - Place slug
- `placeId` (int) - Place identifier
- `items` (List<OrderItem>) - Order items
- `status` (OrderStatus) - Order status
- `description` (String?) - Order description
- `txHash` (String?) - Transaction hash
- `type` (OrderType?) - Order type
- `account` (EthereumAddress?) - User account
- `fees` (double) - Order fees
- `place` (OrderPlace) - Place information
- `token` (String) - Token contract

**Enums:**
- `OrderStatus` - Order states:
  - `pending` - Order pending payment
  - `paid` - Order paid
  - `cancelled` - Order cancelled
  - `refunded` - Order refunded
  - `refund_pending` - Refund pending
  - `refund` - Refund in progress
  - `correction` - Order correction

- `OrderType` - Order sources:
  - `web` - Web interface
  - `app` - Mobile app
  - `terminal` - Payment terminal
  - `pos` - Point of sale

- `PaymentMode` - Payment methods:
  - `terminal` - Payment terminal
  - `qrCode` - QR code payment
  - `app` - App payment

**Computed Properties:**
- `isFinalized` (bool) - Whether order is in final state

**Key Methods:**
- `fromJson(Map<String, dynamic>)` - Parse from API
- `fromMap(Map<String, dynamic>)` - Parse from database
- `toMap()` - Convert to database format

### 8. `OrderItem` (`lib/models/order.dart`)
**Purpose**: Represents individual items in an order

**Properties:**
- `id` (int) - Menu item identifier
- `quantity` (int) - Item quantity

**Key Methods:**
- `fromJson(Map<String, dynamic>)` - Parse from API
- `toMap()` - Convert to database format

### 9. `OrderPlace` (`lib/models/order.dart`)
**Purpose**: Place information within an order

**Properties:**
- `slug` (String) - Place slug
- `display` (Display) - Display mode
- `account` (String) - Place account
- `items` (List<MenuItem>) - Available menu items

**Key Methods:**
- `fromJson(Map<String, dynamic>)` - Parse from API
- `fromMap(Map<String, dynamic>)` - Parse from database
- `toMap()` - Convert to database format

## Checkout Models

### 10. `Checkout` (`lib/models/checkout.dart`)
**Purpose**: Shopping cart for place orders

**Properties:**
- `items` (List<CheckoutItem>) - Cart items
- `manualAmount` (double?) - Manual amount override
- `message` (String?) - Order message

**Computed Properties:**
- `total` (double) - Total amount
- `decimalTotal` (double) - Total in decimal format
- `isEmpty` (bool) - Whether cart is empty
- `itemCount` (int) - Total item count

**Key Methods:**
- `fromMap(Map<String, dynamic>)` - Parse from database
- `toMap()` - Convert to database format
- `toJson()` - Convert to JSON
- `copyWith({...})` - Create modified copy
- `addItem(MenuItem, {int quantity})` - Add item to cart
- `removeItem(MenuItem)` - Remove item from cart
- `increaseItem(MenuItem)` - Increase item quantity
- `decreaseItem(MenuItem)` - Decrease item quantity
- `quantityOfMenuItem(MenuItem)` - Get item quantity

### 11. `CheckoutItem` (`lib/models/checkout_item.dart`)
**Purpose**: Individual item in shopping cart

**Properties:**
- `menuItem` (MenuItem) - Menu item reference
- `quantity` (int) - Item quantity

**Computed Properties:**
- `subtotal` (double) - Item subtotal (VAT included)

**Key Methods:**
- `fromMap(Map<String, dynamic>)` - Parse from database
- `toMap()` - Convert to database format
- `toListMap()` - Convert to list format
- `copyWith({...})` - Create modified copy

## User Models

### 12. `User` (`lib/models/user.dart`)
**Purpose**: Basic user information

**Properties:**
- `name` (String) - User name
- `username` (String) - Username
- `account` (String) - Wallet address
- `imageUrl` (String?) - Profile image
- `description` (String?) - User description
- `placeId` (String?) - Associated place ID

**Key Methods:**
- `fromJson(Map<String, dynamic>)` - Parse from API
- `toMap()` - Convert to database format
- `toString()` - Debug representation

### 13. `Card` (`lib/models/card.dart`)
**Purpose**: NFC card information

**Properties:**
- `serial` (String) - Card serial number
- `project` (String?) - Associated project
- `createdAt` (DateTime) - Creation timestamp
- `updatedAt` (DateTime) - Last update timestamp
- `owner` (String) - Card owner address

**Key Methods:**
- `fromJson(Map<String, dynamic>)` - Parse from API
- `toMap()` - Convert to database format

### 14. `CardInfo` (`lib/models/card.dart`)
**Purpose**: Extended card information with profile and balance

**Properties:**
- `uid` (String) - Card unique identifier
- `account` (String) - Card wallet address
- `profile` (ProfileV1) - Card profile
- `balance` (String) - Card balance
- `project` (String) - Associated project

### 15. `CWWallet` (`lib/models/wallet.dart`)
**Purpose**: Wallet information and balance

**Properties:**
- `name` (String) - Wallet name
- `address` (String) - Wallet address
- `alias` (String) - Community alias
- `account` (String) - Account identifier
- `_balance` (String) - Private balance field
- `currencyName` (String) - Currency name
- `symbol` (String) - Currency symbol
- `currencyLogo` (String) - Currency logo URL
- `decimalDigits` (int) - Decimal precision

**Computed Properties:**
- `balance` (String) - Public balance getter
- `doubleBalance` (double) - Balance as double
- `formattedBalance` (double) - Formatted balance

**Key Methods:**
- `fromJson(Map<String, dynamic>)` - Parse from JSON
- `toJson()` - Convert to JSON
- `copyWith({...})` - Create modified copy
- `setBalance(String)` - Update balance

## Model Relationships

### Data Flow
1. **API → Models**: `fromJson()` methods parse API responses
2. **Database → Models**: `fromMap()` methods parse database records
3. **Models → Database**: `toMap()` methods serialize for storage
4. **Models → API**: `toJson()` methods serialize for API calls

### Key Relationships
- **Place ↔ MenuItem**: One-to-many relationship
- **PlaceWithMenu**: Aggregates Place + MenuItem list
- **Order ↔ OrderItem**: One-to-many relationship
- **Checkout ↔ CheckoutItem**: One-to-many relationship
- **Transaction ↔ Profile**: References to user profiles
- **Interaction ↔ Place**: Optional relationship for place interactions

### Serialization Patterns
- **JSON**: Used for API communication
- **Map**: Used for database storage
- **String**: Used for debugging and logging

## Best Practices

### 1. Immutability
- Use `final` properties where possible
- Implement `copyWith()` methods for updates
- Avoid mutable state in models

### 2. Validation
- Include assertions for critical data
- Validate enum values with fallbacks
- Handle null values gracefully

### 3. Serialization
- Always implement both `fromJson()` and `fromMap()`
- Use consistent naming conventions
- Handle type conversions safely

### 4. Performance
- Use computed properties for derived values
- Implement efficient lookup methods
- Cache expensive calculations

### 5. Testing
- Models should be easily testable
- Include comprehensive `toString()` methods
- Test serialization/deserialization cycles

This model architecture provides a robust foundation for data management throughout the Pay App, ensuring type safety, consistency, and maintainability.
