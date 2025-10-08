# Database Schema Documentation

This document provides a comprehensive overview of the database tables used in the Pay App.

## Database Overview

The app uses SQLite as the local database with the following characteristics:
- **Database Version**: 14
- **Database Service**: `AppDBService` (singleton pattern)
- **Location**: `lib/services/db/app/db.dart`
- **Abstract Base Classes**: `DBService` and `DBTable` in `lib/services/db/db.dart`

## Tables

### 1. `preference` Table
**File**: `lib/services/db/preference.dart`  
**Purpose**: Stores application preferences and settings

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `key` | TEXT | PRIMARY KEY | Unique preference identifier |
| `created_at` | TEXT | NOT NULL | ISO 8601 timestamp when preference was created |
| `updated_at` | TEXT | NOT NULL | ISO 8601 timestamp when preference was last updated |
| `value` | TEXT | NOT NULL | Preference value |

**Key Methods**:
- `get(String key)` - Retrieve preference value
- `set(String key, String value)` - Set/update preference value
- `clear()` - Clear all preferences

---

### 2. `t_cards` Table
**File**: `lib/services/db/app/cards.dart`  
**Purpose**: Stores user payment cards and wallet information

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `uid` | TEXT | PRIMARY KEY | Unique card identifier |
| `project` | TEXT | NULL | Project identifier |
| `created_at` | TEXT | NULL | ISO 8601 timestamp when card was created |
| `updated_at` | TEXT | NULL | ISO 8601 timestamp when card was last updated |
| `account` | TEXT | NOT NULL | Account identifier associated with the card |

**Indexes**:
- `idx_t_cards_account` - For fast account lookups
- `idx_t_cards_project` - For fast project lookups

**Key Methods**:
- `getAll()` - Fetch all cards
- `getByUid(String uid)` - Fetch card by UID
- `getByAccount(String account)` - Fetch card by account
- `upsert(DBCard card)` - Insert or update card
- `upsertMany(List<DBCard> cards)` - Batch insert/update cards
- `replaceAll(List<DBCard> cards)` - Replace all cards

---

### 3. `t_contacts` Table
**File**: `lib/services/db/app/contacts.dart`  
**Purpose**: Stores user contacts (both users and places)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `account` | TEXT | PRIMARY KEY | Account identifier |
| `username` | TEXT | NOT NULL | Username |
| `name` | TEXT | NOT NULL | Display name |
| `type` | TEXT | NOT NULL | Contact type: 'user' or 'place' |
| `profile` | TEXT | NULL | JSON-encoded profile data |
| `place` | TEXT | NULL | JSON-encoded place data |

**Indexes**:
- `idx_t_contacts_account` - For fast account lookups
- `idx_t_contacts_username` - For fast username lookups

**Contact Types**:
- `ContactType.user` - Regular user contact
- `ContactType.place` - Business/place contact

**Key Methods**:
- `getAll()` - Fetch all contacts
- `getByAccount(String account)` - Fetch contact by account
- `getByUsername(String username)` - Fetch contact by username
- `upsert(DBContact contact)` - Insert or update contact

---

### 4. `t_interactions` Table
**File**: `lib/services/db/app/interactions.dart`  
**Purpose**: Stores chat/messaging interactions between users and places

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | TEXT | PRIMARY KEY | Unique interaction identifier |
| `direction` | TEXT | NOT NULL | Interaction direction |
| `account` | TEXT | NOT NULL | User account identifier |
| `with_account` | TEXT | NOT NULL | Account being interacted with |
| `name` | TEXT | NOT NULL | Display name of the interaction |
| `image_url` | TEXT | NULL | Profile/avatar image URL |
| `contract` | TEXT | NOT NULL | Token/contract identifier |
| `amount` | TEXT | NOT NULL | Amount involved in interaction |
| `description` | TEXT | NULL | Interaction description |
| `is_place` | INTEGER | NOT NULL | Boolean: 1 if interaction is with a place |
| `is_treasury` | INTEGER | NOT NULL | Boolean: 1 if interaction is with treasury |
| `place_id` | INTEGER | NULL | Place identifier (if applicable) |
| `has_unread_messages` | INTEGER | NOT NULL | Boolean: 1 if has unread messages |
| `last_message_at` | TEXT | NOT NULL | ISO 8601 timestamp of last message |
| `has_menu_item` | INTEGER | NOT NULL | Boolean: 1 if place has menu items |
| `place` | TEXT | NULL | JSON-encoded place data |
| `profile` | TEXT | NOT NULL | JSON-encoded profile data |

**Indexes**:
- `idx_t_interactions_account` - For fast account lookups
- `idx_t_interactions_with_account` - For fast with_account lookups
- `idx_t_interactions_last_message_at` - For sorting by last message time
- `idx_t_interactions_is_place` - For filtering place interactions
- `idx_t_interactions_has_unread_messages` - For filtering unread messages
- `idx_t_interactions_last_message_at_desc` - Composite index for efficient sorting

**Key Methods**:
- `getAll(String account, {String? token})` - Fetch all interactions for account
- `getAllPaginated(...)` - Fetch interactions with pagination
- `getById(String id)` - Fetch interaction by ID
- `getInteractionsForAccount(...)` - Fetch interactions between specific accounts
- `getPlaceInteractions(...)` - Fetch only place interactions
- `getUnreadInteractions(...)` - Fetch interactions with unread messages
- `upsert(Interaction interaction)` - Insert or update interaction
- `updateUnreadStatus(String id, bool hasUnreadMessages)` - Update unread status
- `updateLastMessageAt(String id, DateTime lastMessageAt)` - Update last message timestamp

---

### 5. `t_orders` Table
**File**: `lib/services/db/app/orders.dart`  
**Purpose**: Stores order information for purchases at places

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY | Unique order identifier |
| `created_at` | TEXT | NOT NULL | ISO 8601 timestamp when order was created |
| `completed_at` | TEXT | NULL | ISO 8601 timestamp when order was completed |
| `total` | INTEGER | NOT NULL | Total order amount |
| `due` | INTEGER | NOT NULL | Amount due |
| `place_id` | INTEGER | NOT NULL | Place identifier where order was placed |
| `slug` | TEXT | NOT NULL | Place slug identifier |
| `items` | TEXT | NOT NULL | JSON-encoded order items |
| `status` | TEXT | NOT NULL | Order status |
| `description` | TEXT | NULL | Order description |
| `tx_hash` | TEXT | NULL | Transaction hash (if paid) |
| `type` | TEXT | NULL | Order type |
| `account` | TEXT | NULL | User account identifier |
| `fees` | INTEGER | NOT NULL DEFAULT 0 | Order fees |
| `place` | TEXT | NOT NULL | JSON-encoded place data |
| `token` | TEXT | NOT NULL | Token/contract identifier |

**Indexes**:
- `idx_t_orders_place_id` - For fast place lookups
- `idx_t_orders_slug` - For fast slug lookups
- `idx_t_orders_account` - For fast account lookups
- `idx_t_orders_created_at` - For sorting by creation time
- `idx_t_orders_status` - For filtering by status
- `idx_t_orders_tx_hash` - For transaction hash lookups
- `idx_t_orders_place_created` - Composite index (place_id, created_at)
- `idx_t_orders_account_created` - Composite index (account, created_at)

**Key Methods**:
- `getAll(String account)` - Fetch all orders for account
- `getById(int id)` - Fetch order by ID
- `getByTxHash(String txHash)` - Fetch order by transaction hash
- `getOrdersBySlug(...)` - Fetch orders by place slug
- `getOrdersByAccount(...)` - Fetch orders by account with pagination
- `getOrdersByStatus(...)` - Fetch orders by status
- `upsert(Order order)` - Insert or update order
- `upsertMany(List<Order> orders)` - Batch insert/update orders

---

### 6. `t_places_with_menu` Table
**File**: `lib/services/db/app/places_with_menu.dart`  
**Purpose**: Stores places that have menu items available

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `place_id` | INTEGER | PRIMARY KEY | Unique place identifier |
| `slug` | TEXT | NOT NULL | Place slug identifier |
| `place` | TEXT | NOT NULL | JSON-encoded place data |
| `profile` | TEXT | NULL | JSON-encoded profile data |
| `items` | TEXT | NOT NULL | JSON-encoded menu items |

**Indexes**:
- `idx_t_places_with_menu_slug` - For fast slug lookups

**Key Methods**:
- `getAll()` - Fetch all places with menu
- `getByPlaceId(int placeId)` - Fetch place by place ID
- `getBySlug(String slug)` - Fetch place by slug
- `upsert(PlaceWithMenu placeWithMenu)` - Insert or update place
- `upsertMany(List<PlaceWithMenu> placesWithMenu)` - Batch insert/update places
- `deleteBySlug(String slug)` - Delete place by slug

---

### 7. `t_transactions` Table
**File**: `lib/services/db/app/transactions.dart`  
**Purpose**: Stores transaction records for payments and transfers

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | TEXT | PRIMARY KEY | Unique transaction identifier |
| `tx_hash` | TEXT | NOT NULL | Blockchain transaction hash |
| `contract` | TEXT | NOT NULL | Token/contract identifier |
| `from_account` | TEXT | NOT NULL | Sender account identifier |
| `to_account` | TEXT | NOT NULL | Recipient account identifier |
| `amount` | TEXT | NOT NULL | Transaction amount |
| `description` | TEXT | NULL | Transaction description |
| `status` | TEXT | NOT NULL | Transaction status |
| `created_at` | TEXT | NOT NULL | ISO 8601 timestamp when transaction was created |

**Indexes**:
- `idx_t_transactions_tx_hash` - For fast transaction hash lookups
- `idx_t_transactions_contract` - For fast contract lookups
- `idx_t_transactions_from_account` - For fast sender lookups
- `idx_t_transactions_to_account` - For fast recipient lookups
- `idx_t_transactions_created_at` - For sorting by creation time
- `idx_t_transactions_user_transactions` - Composite index (from_account, to_account, created_at)
- `idx_t_transactions_user_transactions_reverse` - Composite index (to_account, from_account, created_at)

**Key Methods**:
- `getAll()` - Fetch all transactions
- `getById(String id)` - Fetch transaction by ID
- `getByTxHash(String txHash)` - Fetch transaction by hash
- `getTransactionsBetweenUsers(...)` - Fetch transactions between two accounts
- `getTransactionsForAccount(...)` - Fetch all transactions for an account
- `upsert(Transaction transaction)` - Insert or update transaction
- `upsertMany(List<Transaction> transactions)` - Batch insert/update transactions

## Database Migrations

The database uses a version-based migration system. Each table implements the `migrate` method to handle schema changes between versions. The current database version is **14**.

### Migration History
- **Version 2**: Initial cards table creation
- **Version 3**: Added timestamps to cards table
- **Version 4**: Initial transactions table creation
- **Version 5**: Removed exchange_direction column from transactions
- **Version 6**: Initial orders table creation
- **Version 7**: Added slug column to orders
- **Version 8**: Recreated orders table with new schema
- **Version 10**: Initial places_with_menu table creation
- **Version 11**: Initial interactions table creation
- **Version 12**: Recreated interactions table with new schema
- **Version 13**: Added contract index to transactions
- **Version 14**: Recreated orders table with latest schema

## Usage Patterns

### Common Operations
1. **Upsert Operations**: Most tables use `upsert` methods with `ConflictAlgorithm.replace` for insert-or-update functionality
2. **Batch Operations**: Tables support batch operations for multiple records
3. **Pagination**: Many query methods support limit/offset pagination
4. **Indexing**: Strategic indexes are created for common query patterns
5. **JSON Storage**: Complex objects are stored as JSON strings in TEXT columns

### Performance Considerations
- Composite indexes are used for multi-column queries
- Descending indexes are created for efficient sorting
- Batch operations are used for bulk data operations
- Proper indexing strategy for common query patterns

## Database Service Architecture

The database follows a clean architecture pattern:
- **Abstract Base Classes**: `DBService` and `DBTable` provide common functionality
- **Singleton Pattern**: `AppDBService` is implemented as a singleton
- **Table Instantiation**: Tables are instantiated during database configuration
- **Migration Support**: Built-in migration system for schema evolution
- **Cross-Platform**: Supports both mobile and web platforms using appropriate SQLite implementations
