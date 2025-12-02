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