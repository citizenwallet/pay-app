# Interaction Caching System

## Overview

The interaction caching system provides offline-first functionality by storing interactions in a local SQLite database and syncing with the remote API. This ensures fast loading times and offline access to interaction data.

## Architecture

### Components

1. **InteractionState** (`lib/state/interactions/interactions.dart`)
   - Manages the caching logic
   - Handles loading from local database and syncing with remote API
   - Provides state management for UI components

2. **InteractionsTable** (`lib/services/db/app/interactions.dart`)
   - SQLite table for storing interactions
   - Provides CRUD operations for local data
   - Handles database migrations

3. **InteractionService** (`lib/services/pay/interactions.dart`)
   - Handles remote API calls
   - Fetches interactions from the server

## How It Works

### Initial Load
1. **Load from Local Database**: First, interactions are loaded from the local SQLite database for immediate display
2. **Sync with Remote API**: In the background, the system fetches fresh data from the remote API
3. **Update Local Database**: Remote data is stored in the local database
4. **Reload from Local**: The UI is updated with the fresh data from the local database

### Polling
- The system polls for new interactions every 3 seconds
- New interactions are stored in the local database
- The UI is updated with the latest data

### Offline Support
- If the remote API is unavailable, the app continues to work with cached data
- No error state is shown to the user when offline
- Data syncs automatically when connection is restored

## Key Features

### State Management
- `loading`: Shows loading indicator during initial load
- `syncing`: Shows syncing indicator during remote API calls
- `error`: Handles error states gracefully

### Database Operations
- **Upsert**: Updates existing interactions or creates new ones
- **Sorting**: Interactions are sorted by `lastMessageAt` (most recent first)
- **Filtering**: Support for filtering by account, place, and unread status

### UI Integration
- Pull-to-refresh triggers a remote sync
- Syncing state is shown in the search bar
- Immediate UI updates for read/unread status

## Usage

### Basic Usage
```dart
// Get interactions (loads from local, then syncs with remote)
await interactionState.getInteractions();

// Force refresh from remote API
await interactionState.refreshFromRemote();

// Mark interaction as read
await interactionState.markInteractionAsRead(interaction);
```

### Advanced Queries
```dart
// Get interactions for specific account
final accountInteractions = await interactionState.getInteractionsForAccount(account);

// Get place interactions only
final placeInteractions = await interactionState.getPlaceInteractions();

// Get unread interactions
final unreadInteractions = await interactionState.getUnreadInteractions();
```

## Database Schema

The interactions table includes:
- `id`: Unique interaction identifier
- `direction`: Exchange direction (sent/received)
- `with_account`: Account address
- `name`: Display name
- `image_url`: Profile image URL
- `contract`: Contract address
- `amount`: Transaction amount
- `description`: Transaction description
- `is_place`: Whether interaction is with a place
- `is_treasury`: Whether interaction is with treasury
- `place_id`: Place ID (if applicable)
- `has_unread_messages`: Unread status
- `last_message_at`: Timestamp of last message
- `has_menu_item`: Whether place has menu
- `place`: Place data (JSON)
- `profile`: Profile data (JSON)

## Performance Considerations

- Database indexes are created for efficient queries
- Pagination support for large datasets
- Background syncing to avoid blocking UI
- Optimistic updates for better UX

## Error Handling

- Network failures don't break the UI
- Database errors are logged but don't crash the app
- Graceful degradation when offline
- Automatic retry mechanisms for failed syncs 