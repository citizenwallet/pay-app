# State Management Documentation

This document provides a comprehensive overview of the state management architecture used in the Pay App.

## Overview

The app uses **Provider** as the primary state management solution, following Flutter's recommended approach. The state management is organized around the repository's architectural patterns with clear separation of concerns.

## Architecture Principles

### Core Principles
- **Provider over local state**: Favor Provider for state management over local widget state
- **Scoped state**: State is typically scoped to routes or modals rather than global
- **Service integration**: State classes call services directly, widgets never call services
- **Local state for UI only**: Use local state management only for self-contained widgets (animations, hiding widgets, etc.)

### State Organization
- **Global state**: App-wide state like user authentication, wallet, and preferences
- **Route-scoped state**: State specific to particular routes (account, interactions, transactions)
- **Modal-scoped state**: State for specific modals and their functionality
- **Feature-scoped state**: State for specific features (cards, places, orders)

## State Provider Structure

### Main State Provider (`lib/state/state.dart`)

The main state provider orchestrates all state management through several provider functions:

#### 1. `provideAppState()` - Global Application State
Provides core application-wide state that persists across the entire app lifecycle.

**Providers:**
- `AppState` - Core app configuration and token management
- `CommunityState` - Community-specific settings
- `OnboardingState` - User onboarding flow state
- `ScanState` - QR code scanning functionality
- `LocaleState` - Internationalization state
- `TopupState` - Token top-up functionality
- `ProfileState` - User profile management
- `CardsState` - NFC card management
- `WalletState` - Wallet and balance management

#### 2. `provideAccountState()` - Account-Specific State
Provides state scoped to a specific user account, created dynamically based on route parameters.

**Parameters:**
- `account` - User account address from route parameters
- `token` - Optional token contract address from query parameters

**Providers:**
- `InteractionState` - Chat/messaging interactions for the account
- `PlacesState` - Places and businesses data
- `ContactsState` - User contacts management
- `AccountState` - Account-specific information
- `TransactionsState` - Transaction history for the account

#### 3. `provideWalletState()` - Wallet-Specific State
Provides wallet state for specific account operations.

**Providers:**
- `WalletState` - Wallet operations and balance management

#### 4. `providePlaceState()` - Place-Specific State
Provides state for place/business interactions.

**Parameters:**
- `slug` - Place identifier
- `account` - User account

**Providers:**
- `OrdersWithPlaceState` - Order management for specific place
- `CheckoutState` - Checkout process state

#### 5. `provideCardState()` - Card-Specific State
Provides state for NFC card interactions.

**Parameters:**
- `cardId` - Card identifier
- `cardAddress` - Card wallet address
- `myAddress` - User's wallet address

**Providers:**
- `CardState` - Individual card management
- `TransactionsWithUserState` - Transaction history between user and card

#### 6. `provideSendingState()` - Payment Sending State
Provides state for sending payments and transactions.

**Parameters:**
- `initialAddress` - Initial recipient address

**Providers:**
- `WalletState` - Wallet operations
- `SendingState` - Payment sending process

## State Classes

### Global State Classes

#### `AppState` (`lib/state/app.dart`)
**Purpose**: Core application state and configuration management

**Key Properties:**
- `currentTokenAddress` - Currently selected token
- `currentTokenConfig` - Token configuration
- `lastAccount` - Last used account
- `small` - UI size preference

**Key Methods:**
- `setCurrentToken(String tokenAddress)` - Switch active token
- `setLastAccount(String account)` - Set last used account
- `setSmall(bool small)` - Toggle UI size

#### `WalletState` (`lib/state/wallet.dart`)
**Purpose**: Wallet management, balance tracking, and account operations

**Key Properties:**
- `address` - Current wallet address
- `tokenBalances` - Map of token balances
- `tokenLoadingStates` - Loading states for each token
- `loading` - General loading state
- `error` - Error state
- `credentialsExpired` - Session expiration state

**Key Methods:**
- `init()` - Initialize wallet and load balances
- `switchAccount(String account)` - Switch to different account
- `startBalancePolling()` - Start periodic balance updates
- `updateBalance()` - Update current token balance
- `loadTokenBalances()` - Load all token balances
- `getTokenBalance(String tokenAddress)` - Get specific token balance

#### `CardsState` (`lib/state/cards.dart`)
**Purpose**: NFC card management and operations

**Key Properties:**
- `cards` - List of user's cards
- `cardBalances` - Map of card balances
- `profiles` - Map of card profiles
- `claimingCard` - Card claiming state
- `releasingCard` - Card release state
- `updatingCardName` - Card name update state

**Key Methods:**
- `fetchCards()` - Load user's cards from API
- `fetchProfile(String address)` - Load card profile
- `claim(String uid, String? uri, String? name)` - Claim new card
- `release(String uid)` - Release card
- `updateCardName(String uid, String newName)` - Update card name

#### `ProfileState` (`lib/state/profile.dart`)
**Purpose**: User profile management and editing

**Key Properties:**
- `appAccount` - User's wallet address
- `appProfile` - User's profile data
- `profile` - Current profile being viewed
- `hasChanges` - Whether profile has unsaved changes
- `profileUpdateState` - Profile update progress state
- `editingImage` - Image being edited

**Key Methods:**
- `fetchProfile()` - Load profile from cache/API
- `giveProfileUsername()` - Auto-generate username for new users
- `checkUsernameTaken(String username)` - Validate username availability
- `saveProfile()` - Save profile changes
- `selectPhoto()` - Select new profile photo

#### `OnboardingState` (`lib/state/onboarding.dart`)
**Purpose**: User onboarding and session management

**Key Properties:**
- `connectedAccountAddress` - Connected account
- `sessionRequestStatus` - Session request progress
- `phoneNumberController` - Phone number input
- `challengeController` - SMS challenge input

**Key Methods:**
- `requestSession(String source)` - Request SMS session
- `confirmSession(String challenge)` - Confirm SMS challenge
- `formatPhoneNumber(String phoneNumber)` - Format phone input
- `isSessionExpired()` - Check session validity

### Route-Scoped State Classes

#### `TransactionsState` (`lib/state/transactions/transactions.dart`)
**Purpose**: Transaction history management with caching and pagination

**Key Properties:**
- `transactions` - List of transactions
- `orders` - Map of orders by transaction hash
- `profiles` - Map of user profiles
- `loading` - Loading state
- `loadingMore` - Pagination loading state
- `hasMoreTransactions` - Whether more transactions available

**Key Methods:**
- `getTransactions({String? token})` - Load transactions with caching
- `loadMoreTransactions()` - Load additional transactions
- `refreshTransactions()` - Force refresh from API
- `startPolling()` - Start periodic transaction updates
- `fetchProfile(String account)` - Load user profile

#### `InteractionState` (`lib/state/interactions/interactions.dart`)
**Purpose**: Chat/messaging interactions management

**Key Properties:**
- `interactions` - List of interactions
- `interactionsMap` - Map for quick lookups
- `searchQuery` - Search functionality
- `loading` - Loading state
- `syncing` - API sync state

**Key Methods:**
- `getInteractions({String? token})` - Load interactions with caching
- `markInteractionAsRead(Interaction interaction)` - Mark as read
- `refreshFromRemote()` - Force API sync
- `startPolling()` - Start periodic updates
- `getInteractionsForAccount(String account)` - Get specific interactions

#### `ContactsState` (`lib/state/contacts/contacts.dart`)
**Purpose**: Contact management and search

**Key Properties:**
- `contacts` - List of contacts
- `searchQuery` - Search query
- `customContact` - Custom contact from search
- `customContactProfile` - Profile for custom contact

**Key Methods:**
- `fetchContacts()` - Load device contacts
- `setSearchQuery(String query)` - Search for contacts
- `getContactProfileFromUsername(String query)` - Get profile by username
- `getContactProfileFromAddress(String address)` - Get profile by address

### Feature-Scoped State Classes

#### `SendingState` (`lib/state/sending.dart`)
**Purpose**: Payment sending and QR code processing

**Key Properties:**
- `qrData` - Parsed QR code data
- `profile` - Recipient profile
- `place` - Place information
- `order` - Order information
- `transactionSending` - Transaction in progress
- `amount` - Transaction amount

**Key Methods:**
- `parseQRData(String rawValue)` - Parse QR code
- `getContactProfileFromAddress(String address)` - Load recipient profile
- `sendTransaction(String tokenAddress, {...})` - Send payment
- `setAmount(double amount)` - Set transaction amount

## State Management Patterns

### 1. Caching Strategy
Most state classes implement a **cache-first** approach:
1. Load data from local database immediately
2. Sync with remote API in background
3. Update local cache and UI when new data arrives

### 2. Polling and Real-time Updates
Many state classes implement polling for real-time updates:
- `TransactionsState` - Polls for new transactions every 3 seconds
- `InteractionState` - Polls for new messages every 3 seconds
- `WalletState` - Polls for balance updates every 1 second

### 3. Error Handling
Consistent error handling patterns:
- `safeNotifyListeners()` - Prevents notifications after disposal
- Try-catch blocks with Firebase Crashlytics integration
- Graceful degradation when API calls fail

### 4. Loading States
Multiple loading states for better UX:
- `loading` - Initial data loading
- `loadingMore` - Pagination loading
- `syncing` - Background sync status
- `error` - Error state

### 5. Memory Management
Proper disposal patterns:
- `_mounted` flag to prevent notifications after disposal
- Timer cleanup in `dispose()` methods
- Service cleanup where appropriate

## State Lifecycle

### 1. Initialization
- State classes are created by Provider
- `init()` methods are called to set up initial state
- Services are instantiated and configured

### 2. Data Loading
- Cache-first loading from local database
- Background API synchronization
- Polling setup for real-time updates

### 3. User Interactions
- State methods handle user actions
- UI updates through `notifyListeners()`
- Service calls for data persistence

### 4. Cleanup
- `dispose()` methods clean up resources
- Timers are cancelled
- Services are properly closed

## Best Practices

### 1. State Organization
- Keep related state together in the same class
- Use separate state classes for different features
- Scope state appropriately (global vs route vs modal)

### 2. Service Integration
- State classes should call services directly
- Widgets should never call services directly
- Use dependency injection for service access

### 3. Performance
- Implement pagination for large datasets
- Use caching to reduce API calls
- Implement proper loading states

### 4. Error Handling
- Always use try-catch blocks for async operations
- Provide meaningful error states
- Log errors with Firebase Crashlytics

### 5. Testing
- State classes should be easily testable
- Mock services for unit tests
- Test state transitions and side effects

## Integration with Routing

The state management is tightly integrated with GoRouter:

- **Route parameters** determine which state providers are created
- **Query parameters** can influence state initialization
- **State keys** ensure proper state isolation between routes
- **Disposal** happens automatically when routes are popped

## Database Integration

State classes integrate with the local database:

- **Read operations** load from database first for immediate UI updates
- **Write operations** update both database and remote API
- **Caching** reduces API calls and improves performance
- **Offline support** through local database storage

This architecture provides a robust, scalable state management solution that follows Flutter best practices while maintaining clear separation of concerns and excellent performance characteristics.
