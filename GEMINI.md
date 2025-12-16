BarterSwap: Software Architecture & Data Model (Final)
1. Overview & Core Principles
Application: A mobile bartering platform (goods/services) that uses a swipe-to-swap mechanism, inspired by dating apps.

Core Concept: A user doesn't just "like" another item; they "offer" one of their own items for a potential trade. The "swap" occurs when two items are mutually "liked" for each other.

Stack:

Backend: Laravel (REST API)

Database: MySQL

Cache/Queue: Redis

Authentication: Laravel Sanctum (Token-based) + Laravel Socialite (Google Auth)

Real-time: Laravel WebSockets (e.g., Soketi, Pusher)

Notifications: Firebase Cloud Messaging (FCM)

Core Principles:

Asynchronous: All non-critical processes (swap processing, notifications) must be handled by the Laravel Queue (Jobs) to ensure a fast, non-blocking API experience.

Cache-Intensive: The "Explore" feed (item swiping) must be aggressively cached in Redis to provide an instant, responsive feel.

Token-Based: All mobile API routes are protected by Laravel Sanctum, requiring a Bearer Token.

Barter-Centric: The database schema is designed around an Item-for-Item trade, not just a user-likes-item model.

2. Key User Flows (Architecture)
Flow 0: Authentication & Persistence (New)
Google Login (Social Auth):

Mobile Side: The Flutter app uses the native Google Sign-In SDK to authenticate the user. Google returns an id_token (identity token).

API Call: Flutter sends this token to the backend via POST /api/auth/google.

Backend Verification: Laravel (via Socialite) validates the token directly with Google servers.

User Logic:

If the email exists in users: Log the user in.

If the email is new: Create a new user record, then log them in.

Response: The API returns a standard Sanctum Bearer Token. This unifies the logic so the rest of the app doesn't care if the user used Google or a Password.

**Phone Number Collection (Two-Step Registration)**:

Since Google OAuth doesn't provide phone numbers, but phone numbers are critical for trade communication in the bartering platform, the system uses a two-step approach:

1. **Google OAuth completes**: User authenticates via Google → Backend creates/finds user account → Returns Sanctum token with `phone_required` flag.

2. **Phone collection (if needed)**: 
   - Frontend checks the `phone_required` flag in the response
   - If `true` (phone is null), shows a modal dialog requesting phone number
   - User can provide phone or skip (phone will be required later for creating items)
   - If provided, calls `PUT /api/user/profile` to update the phone
   - Navigates to main page

This ensures minimal friction (users only fill one field after OAuth) while maintaining data integrity for trades.

**Backend Response Example**:
```json
{
  "message": "Login successful",
  "user": {
    "id": 123,
    "name": "John Doe",
    "email": "john@gmail.com",
    "phone": null,  // or "+628123456789" if exists
    "profile_picture_url": "https://..."
  },
  "token": "1|abc123...",
  "phone_required": true  // Flag tells frontend to show phone dialog
}
```

Persistent Login ("Stay Logged In"):

Storage: Upon any successful login (Email or Google), the Flutter app must securely store the received Sanctum Token (e.g., using flutter_secure_storage).

App Launch (Splash Screen):

The app retrieves the stored token.

If a token exists, the app calls GET /api/user immediately.

Success (200 OK): The token is still valid. Redirect the user directly to the Home/Explore Screen.

Failure (401 Unauthorized): The token has expired or is invalid. Clear the storage and redirect the user to the Login Screen.

Flow 1: Explore & Swipe (The Core Loop)
Get Feed (GET /api/explore):

The Flutter app requests a feed of items for the user to swipe.

The user's location (and preferences, like distance) are sent.

Performance: This controller must not hit the database directly. It must query a pre-compiled, cached list from Redis.

A separate, scheduled job (UpdateExploreCacheJob) runs in the background to keep this Redis cache warm.

User Swipes (POST /api/swipe):

This is the most critical action. The user swipes right ("like") or left ("dislike") on an item.

The Flutter app must send three key pieces of data:

swiper_item_id: The ID of the user's own item they are offering.

swiped_on_item_id: The ID of the item they are swiping on.

action: like or dislike.

Controller Logic: The API controller's only job is to validate the data, create a single record in the swipes table, and immediately dispatch a ProcessSwipeJob to the queue.

It returns a 200 OK response instantly.

Flow 2: The /Swap (Asynchronous)
Background Job (ProcessSwipeJob):

A Laravel Queue worker picks up the job.

It only processes like actions.

The job checks for a mutual "like": "Does the other item (swiped_on_item_id) also have a like record for my item (swiper_item_id)?"

A Swap is Created!

If a mutual "like" exists, the job creates a new record in the swaps table (e.g., item_a_id: 10, item_b_id: 20, status: 'active').

The job then dispatches a SendNotificationJob for both users involved.

Send Notifications (SendNotificationJob):

A queue worker picks up this job.

It retrieves the fcm_token for both users.

It sends a push notification (FCM) to both users: "You have a new swap for your Item Name!"

Flow 3: Chat & Negotiation
Get Chats (GET /api/swaps):

The app's "Chats" screen calls this endpoint to get all swaps records where status = 'active' or 'chatting'.

Open Chat Room:

User opens a specific chat. This loads all messages from the chat_messages table for that swap_id.

Real-time: The app connects to a WebSocket channel (e.g., private-swap.{{swap_id}}).

Send Message (POST /api/swaps/{swap_id}/message):

The user sends a message. The API saves it to chat_messages and broadcasts it over the WebSocket channel so the other user receives it instantly.

Suggest & Agree on Location (Feature):

Suggest: User A taps a "Suggest Location" button in the chat UI. This opens a map. They select a place and time, which calls POST /api/swaps/{swap_id}/suggest-location.

Display: This suggestion appears as a special "card" in the chat UI for both users, broadcast via WebSocket. The swaps status becomes 'location_suggested'.

Accept: User B sees the suggestion and can tap "Accept." This calls POST /api/swaps/{swap_id}/accept-location.

Confirm: The backend updates the swaps table with the agreed-upon location/time and sets the status to 'location_agreed'. This "locks in" the location.

Flow 4: Trade Confirmation
Confirm Trade (POST /api/swaps/{swap_id}/confirm):

After meeting (and ideally after status = 'location_agreed'), User A confirms the trade. The backend updates their side of the swap (e.g., status = 'confirmed_a').

When User B also calls this endpoint, the backend sees the trade is mutually confirmed.

Finalize Trade (Backend Logic):

The swaps table status is set to 'trade_complete'.

The status for both items (item_a and item_b) is set to 'traded' so they are removed from the public "Explore" feed.

3. Final Database Schema
This is the definitive, non-conflicting schema.

users: Stores user account data, Google ID, and default location.

categories: A single table to manage all categories and subcategories.

items: The "dating profile" for each item. This is the central table.

item_images: Links multiple images to a single item.

item_wants: Stores the categories an item is "looking for." Used for matching.

swipes: This is the core "dating app" action log. It replaces any "likes" table.

swaps: Stores successful mutual "likes" to enable chat.

chat_messages: All messages between swapped users.

4. Summary of Key API Endpoints
Auth:

POST /api/register (Email registration)

POST /api/login (Email login - Returns Sanctum Token)

POST /api/auth/google (New): Handles Google Token verification and returns Sanctum Token.

GET /api/user (Check Token Validity / Get Profile - Vital for persistent login)

POST /api/logout

Items (CRUD):

POST /api/items (Create a new item - a complex, transactional endpoint)

GET /api/items/{id} (Get item details)

PUT /api/items/{id} (Update item)

Explore & Swap:

GET /api/explore (Get cached item feed for swiping)

POST /api/swipe (The core swipe action)

GET /api/swaps (Get all of user's active swaps)

Chat:

GET /api/swaps/{swap_id}/messages (Get chat history for a swap)

POST /api/swaps/{swap_id}/message (Send a text message)

POST /api/swaps/{swap_id}/suggest-location (Body: name, lat, lon, time)

POST /api/swaps/{swap_id}/accept-location (Accepts the current location suggestion)

Static Data:

GET /api/categories (Get all item categories)

Trade:

POST /api/swaps/{swap_id}/confirm (Two-way trade confirmation)

5. Additional Considerations
Authorization (Laravel Policies): You define what to do, but not who is allowed to do it. For example: "A user can only send a message in a swap (swap_id) if their user_id is linked to item_a_id or item_b_id in that swap." Adding a small section on "Key Authorization Rules" (which would map to Laravel Policies) would be the final piece of the puzzle.

Job Failure & Idempotency: Since queues are central, what happens if a ProcessSwipeJob fails? Does it retry? What if it runs twice? This is a more advanced topic, but adding a note like "All jobs should be idempotent" (meaning they can run multiple times without causing a problem) is a good principle to add.

6. Backend Development Constraints
Naming Conventions & Reserved Keywords
match is a Reserved Keyword: The term match is a reserved keyword in PHP 8+ (for match expressions). To prevent syntax errors and conflicts in the Laravel backend, DO NOT use match as a name for models, database tables, columns, or significant variables.

Avoid Ambiguous Terms: The project has several related but distinct concepts like swipe, swap, and previously match. To maintain clarity:

A swipe is a user's unilateral action (like/dislike) on an item.

A swap is a confirmed, mutual like between two items, which creates a chat and a potential trade.

Deprecation of match and bartermatch: The concepts/variables named match and bartermatch have been deprecated and should be completely avoided in the backend codebase. The correct term for a mutual like is a swap.

## 7. Technical Implementation Details

### Real-time Chat & Broadcasting
- **Event**: `App\Events\NewChatMessage` is dispatched whenever a message is sent.
- **Channel**: `private-swap.{swapId}` (Defined in `routes/channels.php`).
- **Authorization**: `SwapPolicy` ensures only the two users involved in the swap can listen to the channel.
- **Frontend**: Flutter uses `pusher_channels_flutter` to subscribe to this channel and listen for the event.

### Redis Caching Strategy
- **Key**: `explore:active_items`
- **Content**: A serialized collection of all `Item` models with `status='active'`, eager loaded with `user`, `category`, `images`, and `wants`.
- **Flow**:
    1. User A suggests -> `POST .../suggest-location` -> Message type `location` created -> Broadcast.
    2. User B accepts -> `POST .../accept-location` -> Message updated (`location_agreed_by_user_b = true`) -> Swap status becomes `location_agreed` -> Broadcast.

## 8. How to Run & Configuration

### Prerequisites
- PHP 8.2+ & Composer
- Flutter SDK 3.x
- MySQL
- Redis
- Node.js (for Reverb/Soketi/Pusher simulation if self-hosted)

### Backend (Laravel) Setup
1. **Navigate to directory**: `cd laravel`
2. **Install Dependencies**:
   ```bash
   composer install
   ```
3. **Environment Setup**:
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```
   - Configure database credentials in `.env` (`DB_DATABASE`, `DB_USERNAME`, etc.).
   - Configure Redis: `CACHE_STORE=redis`, `QUEUE_CONNECTION=redis`.
   - Configure Broadcasting: `BROADCAST_CONNECTION=pusher` (or `reverb`).
   - Configure Pusher/Reverb credentials in `.env`.
4. **Database Migration**:
   ```bash
   php artisan migrate
   ```
5. **Start Services**:
   - **API Server**: `php artisan serve`
   - **Queue Worker** (Critical for Swipes/Notifications): `php artisan queue:work`
   - **WebSocket Server** (if using Reverb): `php artisan reverb:start`

### Mobile (Flutter) Setup
1. **Navigate to directory**: `cd Flutter`
2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```
3. **Configuration**:
   - Open `lib/services/constants.dart`.
   - Set `API_BASE` to your local IP (e.g., `http://10.0.2.2:8000` for Android Emulator, or your LAN IP).
   - Set `PUSHER_KEY` and `PUSHER_CLUSTER` to match your backend.
4. **Firebase & Google Sign-In**:
   - Place `google-services.json` in `android/app/`.
   - Place `GoogleService-Info.plist` in `ios/Runner/`.
5. **Run App**:
   ```bash
   flutter run
   ```

### Troubleshooting
- **Images not loading**: Ensure `php artisan storage:link` is run and the `APP_URL` in `.env` matches your server URL.
- **Chat not working**: Check if `php artisan queue:work` is running (events are broadcast via queue) and WebSocket server is active.
- **Login fails**: Check `storage/logs/laravel.log` for Google Auth errors.

## 9. Running External Services (Redis & WebSockets)

### 1. Redis: **YES, Run Separately**
Laravel **does not** include the Redis server itself. It only includes the library (`predis`) to talk to it.
*   **Action**: You must install and run a Redis server on your machine (e.g., via Docker, WSL, or a Windows installer).
*   **Verify**: Run `redis-cli ping` in your terminal. If it replies `PONG`, it's running.

### 2. Pusher / WebSockets: **Depends**
You have two options here:

*   **Option A: Pusher.com (SaaS) - EASIEST**
    *   **Run Server?**: **NO**. You use their cloud servers.
    *   **Action**: Create an account at pusher.com, get your keys (`APP_ID`, `KEY`, `SECRET`, `CLUSTER`), and put them in your Laravel `.env` and Flutter `constants.dart`.

*   **Option B: Self-Hosted (Laravel Reverb / Soketi)**
    *   **Run Server?**: **YES**.
    *   **Action**:
        *   If using **Laravel Reverb** (recommended for Laravel 11+): Run `php artisan reverb:start`.
        *   If using **Soketi**: Run it via Node.js (`npx soketi start`).

### 3. Laravel Queue: **YES, Run Separately**
For the "Swipe" and "Notification" features to work, you **must** run the queue worker.
*   **Command**: `php artisan queue:work`
*   **Note**: Keep this terminal window open while developing.

### Summary of Terminals to Keep Open
If you are developing locally, you will typically have 3-4 terminals open:
1.  `php artisan serve` (Laravel API)
2.  `php artisan queue:work` (Background Jobs)
3.  `flutter run` (Mobile App)
4.  *(Optional)* `php artisan reverb:start` (Only if self-hosting WebSockets)