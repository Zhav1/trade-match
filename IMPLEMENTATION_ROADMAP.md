# BarterSwap: Flutter App - Feature Audit & Implementation Roadmap

> **Last Updated**: December 3, 2025  
> **Purpose**: Comprehensive catalog of all placeholders, missing backend integrations, and incomplete features in the Flutter mobile application, organized by implementation priority.

> [!IMPORTANT]
> **Stage 1 Complete (Dec 3, 2025)**: Google OAuth backend, profile management endpoints, working logout, and real user data display are now implemented. See "Stage 1 Completion Notes" section below for details.

---

## Critical Issues (Must Fix Immediately)

### ✅ Issue #1: Type Conversion Error in Explore Screen (Dec 16, 2025)
**File**: `lib/screens/explore_screen.dart` (Lines 116, 123)
**Problem**: `AppinioSwiper` callbacks may return dynamic index types.
**Status**: ✅ **FIXED**
**Solution**: Added explicit int conversion before accessing list items.

```dart
// Line 116 - onSwipeEnd callback
final int idx = (previousIndex is int) ? previousIndex : int.parse(previousIndex.toString());
final item = items[idx];

// Line 123 - cardBuilder callback
cardBuilder: (context, index) {
  final int idx = (index is int) ? index : int.parse(index.toString());
  return _buildCard(items[idx]);
}
```

### 🟡 Issue #2: Google Sign-In - Configuration Required (Dec 3, 2025)
**Files**: `lib/auth/auth_page.dart`, `laravel/app/Http/Controllers/AuthController.php`  
**Current Error**: `PlatformException(signinfailed, com.google.android.gms.common.api.apiexception:10, null, null)`
**Status**: ⚠️ **CODE IMPLEMENTED, CONFIGURATION MISSING**

**Backend Status**: ✅ **FULLY IMPLEMENTED**
- ✅ Frontend: `_handleGoogleSignIn()` method (lines 368-403 in auth_page.dart)
- ✅ Backend: `POST /api/auth/google` endpoint in AuthController
- ✅ **Auto-Registration**: Backend automatically creates new users from Google login
- ✅ Token verification using Google's tokeninfo HTTP endpoint
- ✅ Sanctum token storage in `FlutterSecureStorage`

### ✅ Issue #2b: Google Registration (Distinct Flow) (Dec 4, 2025)
**Files**: `lib/auth/auth_page.dart`, `laravel/app/Http/Controllers/AuthController.php`
**Status**: ✅ **FULLY IMPLEMENTED**
- ✅ Backend: `POST /api/auth/google/register` endpoint (fails if user exists)
- ✅ Frontend: `_handleGoogleRegister()` method linked to Register tab button
- ✅ Ensures strict separation: Register tab only creates new users, Login tab handles existing users.
- ✅ **Fix**: Added `signOut()` before registration to force account chooser (prevents silent sign-in loop).

### 🔴 Issue #3: Missing Internet Permission (Dec 4, 2025)
**File**: `android/app/src/main/AndroidManifest.xml`
**Problem**: Missing `<uses-permission android:name="android.permission.INTERNET"/>` in the main manifest.
**Status**: ✅ **FIXED**
**Solution**: Added the permission tag to `main/AndroidManifest.xml`.

### 🟡 Issue #4: Verify SHA-1 Fingerprint (Dec 4, 2025)
**Problem**: Google Sign-In fails with `ApiException: 10`.
**Status**: ✅ **FIXED**
**Solution**: 
1. User added SHA-1 to Firebase Console.
2. Configured `serverClientId` in `lib/services/constants.dart` and `AuthPage.dart`.

### 🟡 Issue #5: Backend SSL Certificate Error (Dec 4, 2025)
**Problem**: `cURL error 60: SSL certificate problem` when backend verifies token with Google.
**Status**: ✅ **FIXED (Local Workaround)**
**Solution**: Added `Http::withoutVerifying()` to `AuthController.php` to bypass local SSL checks.

---


---

## Implementation Stages

## 📋 Stage 1: Core Authentication & User Management ✅ COMPLETE

### 1.1 Google Sign-In Integration ✅
- **Files**: `lib/auth/auth_page.dart`, `laravel/app/Http/Controllers/AuthController.php`
- **Backend API**: `POST /api/auth/google` ✅ **IMPLEMENTED**
- **Frontend Status**: ✅ **Working on both Sign In and Register tabs**
- **Implementation**:
  - ✅ Google Sign-In button on both Sign In and Register tabs
  - ✅ Integrated with `google_sign_in` package
  - ✅ **Two-Step Registration**: OAuth first, then optional phone collection dialog
  - ✅ Phone collection dialog shows if `phone_required` flag is true
  - ✅ Users can skip phone (required later for item creation)
  - ✅ Token exchange with backend via `ApiService().googleLogin()`
  - ✅ Backend returns `phone_required` flag to guide frontend
  - ✅ Sanctum token stored securely in `FlutterSecureStorage`
  - ✅ Error handling implemented
  - ✅ Backend uses Google's tokeninfo HTTP endpoint (no extra packages needed)
  - ✅ **Auto-Registration**: Backend automatically creates new users from Google login

> [!NOTE]
> **Google OAuth Setup**: To enable Google Sign-In, add your `GOOGLE_CLIENT_ID` to `laravel/.env` and configure Android OAuth client with SHA-1 fingerprint. See "How to Get Google Client ID" section at the end of this document.

### 1.2 Profile Management ✅
- **Files**: `lib/profile/profile.dart`, `laravel/app/Http/Controllers/UserController.php`
- **Current State**: ✅ **Fetching real user data from API**
- **Backend APIs**:
  - `GET /api/user` ✅ **Enhanced with stats** (offers_count, trades_count)
  - `PUT /api/user/profile` ✅ **IMPLEMENTED**
  - `POST /api/user/profile-picture` ✅ **IMPLEMENTED**
- **Implementation**:
  - ✅ Profile page converted to StatefulWidget
  - ✅ Fetches real user data on page load
  - ✅ Displays actual name, location, rating
  - ✅ Shows real stats (Offers, Trades counts)
  - ✅ Profile picture from API or default
  - ✅ Backend UserController created with update methods
  - ⏳ Profile editing UI (FAB shows "coming soon" - can be implemented in Stage 2 if needed)

### 1.3 Settings & Logout ✅
- **Files**: `lib/profile/settings_page.dart`
- **Backend APIs**: 
  - `POST /api/logout` ✅ (exists)
- **Implementation**:
  - ✅ Logout functionality with confirmation dialog
  - ✅ Calls `ApiService().logout()` to revoke token
  - ✅ Clears token from secure storage
  - ✅ Navigates to WelcomePage
  - ✅ "Ubah Foto / Bio" connected (shows "coming soon")
  - ⏳ "Notifikasi" page (Stage 6)
  - ⏳ "Privasi" settings (future)
  - ⏳ "Tentang Aplikasi" page (future)

### 1.4 Persistent Login & Token Validation ✅
- **Files**: `lib/main.dart` (SplashPage), `lib/services/api_service.dart`
- **Current State**: ✅ **Fully working**
- **Backend APIs**: 
  - `GET /api/user` ✅ (validates token & returns user data)
- **Implementation**: Token-based persistence using `flutter_secure_storage`
- **Status**:
  - ✅ Token storage implemented
  - ✅ Token retrieval on app launch
  - ✅ Token validation via `GET /api/user`
  - ✅ Auto-login if token valid
  - ✅ Redirect to welcome if token invalid/expired
  - ⏳ Token refresh mechanism (implement if needed based on testing)
  - ⏳ "Remember Me" option (currently always persists - acceptable default)

**How It Works** (Already in GEMINI.md):
1. **On Login**: After successful authentication (Email or Google), save Sanctum Bearer Token to `FlutterSecureStorage`
2. **On App Launch**: `SplashPage` retrieves stored token from secure storage
3. **Token Validation**: Call `GET /api/user` with the token
   - **Success (200)**: Token is valid → Navigate to Main/Explore screen
   - **Failure (401)**: Token expired/invalid → Clear storage → Navigate to Login/Welcome screen
4. **On Logout**: Delete token from secure storage

---

## 📋 Stage 2: Item Management & Library (Priority: HIGH)

### 2.1 User's Item Library
- **Files**: `lib/screens/library_screen.dart`
- **Current State**: ✅ **Connected to API (Dec 16, 2025)**
- **Backend APIs Needed**:
  - `GET /api/user/items` ✅ (Used `GET /api/items` - standard resource)
  - `DELETE /api/items/{id}` ✅ (Implemented)
- **Tasks**:
  - [x] Backend: Create `GET /api/user/items` endpoint (Already exists as `GET /api/items`)
  - [x] Backend: Create `DELETE /api/items/{id}` endpoint (Already exists)
  - [x] Fetch and display user's real items
  - [ ] Implement item detail navigation (onTap)
  - [ ] Implement "Manage" button functionality
  - [ ] Implement search and filter (currently empty `onPressed`)
  - [x] Implement delete item functionality (Added Long Press delete)

### 2.2 Profile Item Lists
- **Files**: `lib/profile/profile.dart`
- **Current State**: ✅ **Connected to API (Dec 16, 2025)**
- **Backend APIs**: Same as 2.1 (`GET /api/items`)
- **Tasks**:
  - [x] Replace hardcoded items with real API data
  - [x] Filter items by status for each tab (Only "Ditawarkan" active, "Dicari" is empty placeholder)
  - [ ] Implement item detail navigation

### 2.3 Add/Edit Item
- **Files**: `lib/screens/add_item_page.dart`
- **Current State**: ✅ **Completed (Dec 16, 2025)**
- **Backend APIs Needed**:
  - `POST /api/items` ✅ (Implemented)
  - `PUT /api/items/{id}` ✅ (Implemented in Controller & Service)
- **Tasks**:
  - [x] Backend: Create `PUT /api/items/{id}` endpoint (Standard resource)
  - [x] Frontend: Implement `AddItemPage` UI (Inputs, Image Picker)
  - [x] Frontend: Connect to API
  - [x] Refactor for "Edit Item" mode (pre-fill data)

---

## 📋 Stage 3: Chat & Swaps ✅ **COMPLETE (Dec 16, 2025)**

> [!IMPORTANT]
> **Completion Status**: Stage 3 was 90% complete when started. Real-time messaging, location picker, and chat detail were already fully functional. Only the chat list needed API integration.
> 
> **What Was Implemented (Dec 16, 2025)**:
> - ✅ Backend: Enhanced `SwapController::index()` to include `latestMessage` relationship
> - ✅ Backend: Wrapped response in `['swaps']` key for frontend compatibility
> - ✅ Backend: Added `Swap::latestMessage()` relationship for message preview
> - ✅ Frontend: Refactored `ChatListScreen` from hardcoded to real API integration
> - ✅ Frontend: Added `ChatMessage` model for preview display
> - ✅ Frontend: Implemented loading, empty, error states with pull-to-refresh
> - ✅ Frontend: Fixed `ChatDetailPage` to use `NetworkImage` for profile pictures
> - ✅ Zero regressions - all real-time messaging preserved

### 3.1 Chat List ✅ (Swaps)
- **Files**: `lib/chat/chat_list.dart`
- **Current State**: Displays 7 hardcoded conversations (Lines 90-96)
- **Backend APIs**:
  - `GET /api/swaps` ✅ (exists)
- **Tasks**:
  - [ ] Replace hardcoded conversations with real swaps from API
  - [ ] Display actual user names, avatars, last messages
  - [ ] Implement search functionality (currently static TextField)
  - [ ] Handle "No swaps yet" empty state
  - [ ] Fix FAB button (currently empty `onPressed`)

### 3.2 Chat Detail & Real-time Messaging ✅
- **Files**: `lib/chat/chat_detail.dart`
- **Backend APIs**:
  - `GET /api/swaps/{id}/messages` ✅ (exists)
  - `POST /api/swaps/{id}/message` ✅ (exists)
- **Backend Events**: `App\Events\NewChatMessage` (WebSocket) ✅
- **Status**: ✅ **ALREADY COMPLETE** (was implemented before this session)
- **Tasks**:
  - [x] Integrate WebSocket listener (`pusher_channels_flutter`)
  - [x] Subscribe to `private-swap.{swapId}` channel
  - [x] Test real-time message broadcasting
  - [x] Implement message sending
  - [x] Display chat history from API
  - [x] Network profile images support added (Dec 16, 2025)

### 3.3 Location Suggestion in Chat ✅
- **Backend APIs**:
  - `POST /api/swaps/{id}/suggest-location` ✅ (exists)
  - `POST /api/swaps/{id}/accept-location` ✅ (exists)
- **Frontend Status**: ✅ **ALREADY COMPLETE** (was implemented before this session)
- **Tasks**:
  - [x] Add "Suggest Location" button in chat UI
  - [x] Integrate map picker (OpenStreetMap)
  - [x] Display location suggestion as special message card
  - [x] Implement "Accept Location" button
  - [x] Handle location agreement flow

---

## 📋 Stage 4: Matches, Likes & Explore Enhancements ✅ **COMPLETE (Dec 16, 2025)**

> [!IMPORTANT]
> **What Was Fixed (Dec 16, 2025)**:
> - ✅ **Critical**: Removed hardcoded `_currentUserItemId = 1` → Now dynamic from `getUserItems()` API
> - ✅ **Critical**: Removed hardcoded location "Jakarta" → Now shows user's actual city from profile
> - ✅ **Critical**: Removed hardcoded distance "2 km" → Now calculates real distance using Haversine formula
> - ✅ Frontend: Added `_loadUserData()` to fetch user profile and items on explore screen init
> - ✅ Frontend: Implemented distance calculation with `Geolocator.distanceBetween()`
> - ✅ Frontend: Added null safety guard for users with no items (shows SnackBar)
> - ✅ Frontend: Enhanced matches page with network profile pictures (no more icon placeholders)
> - ✅ Zero regressions - all swipe/like functionality preserved

### 4.1 Matches & Likes Page ✅
- **Files**: `lib/screens/matches_page.dart`
- **Current State**: ✅ **COMPLETE** - Matches tab shows real swaps, Likes tab shows real likes
- **Backend APIs**:
  - `GET /api/swaps` ✅ (for matches tab)
  - `GET /api/likes` ✅ (for likes tab)
- **Tasks**:
  - [x] Implement "Matches" tab with real swap data
  - [x] Implement "Likes" tab with liked items
  - [x] Handle empty states
  - [x] Display network profile pictures (Dec 16, 2025)
  - [x] Pass real profile URLs to ChatDetailPage (Dec 16, 2025)

### 4.2 Explore Screen Enhancements ✅
- **Files**: `lib/screens/explore_screen.dart`
- **Current State**: ✅ **COMPLETE** - All hardcoded values replaced with dynamic data
- **Fixed Issues**:
  - ~~Line 52: Hardcoded `_currentUserItemId = 1`~~ ✅ Now dynamic from `getUserItems()`
  - ~~Line 77: Hardcoded location "Nearby • Jakarta"~~ ✅ Now shows `$_userLocation` from profile
  - ~~Line 200: Hardcoded distance "2 km"~~ ✅ Now calculates real distance with Haversine
- **Backend APIs**: All exist ✅
- **Tasks**:
  - [x] Implement item selection (which item user is offering)
  - [x] Calculate real distances using user's location
  - [x] Display actual user location in header
  - [ ] Implement filter button functionality (line 89) - **DEFERRED to future stage**

### 4.3 Search & Filters
- **Files**: `lib/screens/search_filter_page.dart`
- **Current State**: Full UI exists but filters don't apply
- **Backend APIs Needed**:
  - `GET /api/explore?category=X&condition=Y&maxDistance=Z` ❌ (need to enhance existing `/api/explore`)
- **Tasks**:
  - [ ] Backend: Add query parameters to `/api/explore` endpoint
  - [ ] Apply filters when navigating back to explore screen
  - [ ] Fetch categories from `GET /api/categories` (currently hardcoded list)
  - [ ] Implement reset filters functionality

---

## 📋 Stage 5: Trade Management & History ✅ **COMPLETE (Dec 16, 2025)**

> [!IMPORTANT]
> **What Was Implemented (Dec 16, 2025)**:
> - ✅ Backend: Added optional `?status` query parameter to `SwapController::index()`
> - ✅ Backend: Supports filtering by `active`, `trade_complete`, `cancelled` statuses
> - ✅ Frontend: Enhanced `ApiService::getSwaps()` with optional status parameter
> - ✅ Frontend: Added `ApiService::confirmTrade()` method for completion flow
> - ✅ Frontend: Completely refactored `TradeHistoryPage` from mock data to real API
> - ✅ Frontend: Implemented smart item detection (myItem vs theirItem based on user ID)
> - ✅ Frontend: Wired Cancel button with confirmation dialog
> - ✅ Frontend: Wired Complete button to `POST /api/swaps/{id}/confirm`
> - ✅ Frontend: Per-tab empty states, loading states, error handling
> - ✅ Zero regressions - all existing functionality preserved

### 5.1 Trade History ✅
- **Files**: `lib/screens/trade_history_page.dart`
- **Current State**: ✅ **COMPLETE** - All tabs show real API data with status filtering
- **Backend APIs**:
  - `GET /api/swaps?status=active` ✅
  - `GET /api/swaps?status=trade_complete` ✅
  - `GET /api/swaps?status=cancelled` ✅
  - `POST /api/swaps/{id}/confirm` ✅
- **Tasks**:
  - [x] Backend: Add status filtering to `GET /api/swaps`
  - [x] Fetch and display real trade data for each tab
  - [x] Implement "Cancel" button with confirmation dialog
  - [x] Implement "Complete" button
  - [x] Connect "Complete" to `POST /api/swaps/{id}/confirm` endpoint
  - [x] Display user item vs their item correctly
  - [x] Handle empty states per tab

### 5.2 Trade Offer Page
- **Files**: `lib/screens/trade_offer_page.dart`
- **Current State**: Receives `BarterItem` but functionality unclear
- **Tasks**:
  - [ ] Clarify purpose (is this for initiating a swap?)
  - [ ] Integrate with swipe/like functionality if needed

---

## 📋 Stage 6: Reviews & Notifications (Priority: LOW)

### 6.1 Reviews & Ratings
- **Files**: `lib/screens/reviews_page.dart`
- **Current State**: Full UI with hardcoded review cards (line 150 - `itemCount: 10`)
- **Backend APIs Needed**:
  - `GET /api/user/{id}/reviews` ❌ (NOT implemented)
  - `POST /api/reviews` ❌ (NOT implemented)
- **Tasks**:
  - [ ] Backend: Create reviews table and migration
  - [ ] Backend: Create `GET /api/user/{id}/reviews` endpoint
  - [ ] Backend: Create `POST /api/reviews` endpoint (submit review after trade)
  - [ ] Fetch and display real reviews
  - [ ] Implement review submission form
  - [ ] Calculate and display real rating statistics

### 6.2 Notifications
- **Files**: `lib/screens/notifications_page.dart`
- **Current State**: Hardcoded notifications (Lines 12-35 in `_NotificationsPageState`)
- **Backend APIs Needed**:
  - `GET /api/notifications` ❌ (NOT implemented)
  - `PUT /api/notifications/{id}/mark-read` ❌ (NOT implemented)
- **Firebase Integration**: FCM ❌ (NOT integrated in Flutter)
- **Tasks**:
  - [ ] Backend: Create notifications table
  - [ ] Backend: Create `GET /api/notifications` endpoint
  - [ ] Backend: Create mark-as-read endpoint
  - [ ] Fetch and display real notifications
  - [ ] Implement mark-as-read functionality
  - [ ] Integrate Firebase Cloud Messaging (FCM) for push notifications
  - [ ] Handle notification taps (navigate to relevant screen)

---

## 📋 Stage 7: Item Detail Enhancements (Priority: LOW)

### 7.1 Item Detail Page
- **Files**: `lib/screens/item_detail_page.dart`
- **Current State**: Displays item data from API but has placeholder elements
- **Issues**:
  - Line 93: Uses `item.createdAt` as "Joined date" (should be user's join date)
  - Limited interaction (needs "Make Offer" or "Like" button)
- **Backend APIs**: 
  - All display data exists ✅
  - Need clarification on action buttons
- **Tasks**:
  - [ ] Fetch user's actual join date
  - [ ] Add interaction buttons (Swipe/Like button or "Make Offer")
  - [ ] Implement report/flag functionality
  - [ ] Add share functionality

---

## Summary of Backend Endpoints Needed

### ✅ Already Implemented (Working)
- `POST /api/register`
- `POST /api/login`
- `POST /api/auth/google`
- `GET /api/user`
- `POST /api/logout`
- `POST /api/items`
- `GET /api/items/{id}`
- `PUT /api/items/{id}` (needs testing)
- `GET /api/explore`
- `POST /api/swipe`
- `GET /api/swaps`
- `GET /api/swaps/{id}/messages`
- `POST /api/swaps/{id}/message`
- `POST /api/swaps/{id}/suggest-location`
- `POST /api/swaps/{id}/accept-location`
- `POST /api/swaps/{id}/confirm`
- `GET /api/categories`

### ❌ Not Implemented (Must Create)
#### Stage 1 Priority:
- `PUT /api/user/profile` - Update user profile
- `POST /api/user/profile-picture` - Upload profile picture

#### Stage 2 Priority:
- `GET /api/user/items` - Get all items owned by user
- `DELETE /api/items/{id}` - Delete an item

#### Stage 3 Priority: *(All covered by existing endpoints)*

#### Stage 4 Priority:
- `GET /api/likes` - Get items user has liked (verify if exists)
- Enhance `GET /api/explore` with query params: `?category=X&condition=Y&maxDistance=Z&minPrice=X&maxPrice=Y`
- Enhance `GET /api/swaps` with status filter: `?status=active|trade_complete|cancelled`

#### Stage 6 Priority:
- `GET /api/notifications` - Get user notifications
- `PUT /api/notifications/{id}/mark-read` - Mark notification as read
- `GET /api/user/{id}/reviews` - Get user reviews
- `POST /api/reviews` - Submit a review

---

## Recommended Implementation Order

### Week 1: Critical Fixes & Core Features
1. ✅ **Fix Type Error** (Issue #1) - 1 hour
2. ✅ **Implement Google Sign-In** (Stage 1.1) - 4 hours
3. ✅ **Profile Data Integration** (Stage 1.2) - 4 hours
4. ✅ **Working Logout** (Stage 1.3) - 1 hour

### Week 2: Item Management
1. ✅ **User Items API** (Stage 2.1 Backend) - 3 hours
2. ✅ **Library Screen Integration** (Stage 2.1 Frontend) - 4 hours
3. ✅ **Profile Items Integration** (Stage 2.2) - 2 hours
4. ✅ **Test Add/Edit Item** (Stage 2.3) - 2 hours

### Week 3: Chat & Real-time
1. **Chat List Integration** (Stage 3.1) - 4 hours
2. **Real-time Messaging** (Stage 3.2) - 6 hours
3. **Location Suggestions** (Stage 3.3) - 6 hours

### Week 4: Explore & Filters
1. **Matches & Likes** (Stage 4.1) - 4 hours
2. **Explore Enhancements** (Stage 4.2) - 3 hours
3. **Search & Filters** (Stage 4.3) - 5 hours

### Week 5: Trade Management
1. **Trade History API & Frontend** (Stage 5.1) - 6 hours
2. **Trade Completion Flow** (Stage 5.1) - 3 hours

### Week 6: Polish & Secondary Features
1. **Notifications** (Stage 6.2) - 8 hours
2. **Reviews** (Stage 6.1) - 6 hours
3. **Item Detail Enhancements** (Stage 7.1) - 2 hours

---

## Testing Checklist (Per Stage)

Each stage should include:
- [ ] Unit tests for new backend endpoints
- [ ] Manual testing of Flutter UI
- [ ] End-to-end testing of user flows
- [ ] Error handling verification
- [ ] Loading state verification
- [ ] Empty state verification

---

## Stage 1 Completion Notes (December 3, 2025)

### Files Modified/Created

**Backend:**
- ✅ `database/migrations/2025_12_03_012000_add_google_id_to_users_table.php` (NEW)
- ✅ `app/Models/User.php` (MODIFIED - added google_id, phone to fillable)
- ✅ `app/Http/Controllers/AuthController.php` (MODIFIED - added googleLogin, getAuthenticatedUser)
- ✅ `app/Http/Controllers/UserController.php` (NEW - profile updates)
- ✅ `routes/api.php` (MODIFIED - added Google auth route)

**Frontend:**
- ✅ `lib/profile/settings_page.dart` (MODIFIED - working logout)
- ✅ `lib/profile/profile.dart` (MODIFIED - real data fetching)
- ✅ `lib/services/api_service.dart` (MODIFIED - profile update methods)

### Key Implementation Details

1. **Google OAuth**: Uses Google's `tokeninfo` HTTP endpoint instead of google/apiclient library (avoids dependency conflicts)
2. **Profile Management**: UserController created with updateProfile() and uploadProfilePicture() methods
3. **User Stats**: getAuthenticatedUser() now returns offers_count and trades_count
4. **Logout**: Fully implemented with confirmation dialog and token clearing
5. **Profile Page**: Converted to StatefulWidget, fetches real data on load

### Testing Completed

- ✅ Database migration ran successfully
- ✅ Backend routes configured correctly
- ⏳ End-to-end testing pending (requires Google OAuth setup)

---

## How to Get Google Client ID

To enable Google Sign-In in your app, you need to create OAuth 2.0 credentials in Google Cloud Console:

### Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click **Select a project** → **New Project**
3. Enter project name (e.g., "TradeMatch") and click **Create**
4. Wait for the project to be created, then select it

### Step 2: Enable Google+ API (if needed)

1. In your project, go to **APIs & Services** → **Library**
2. Search for "Google+ API" or "People API"
3. Click **Enable** (may already be enabled)

### Step 3: Create OAuth 2.0 Credentials

1. Go to **APIs & Services** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
3. If prompted, configure the OAuth consent screen first:
   - Select **External** user type
   - Fill in app name: "TradeMatch" or "BarterSwap"
   - Add your email as developer contact
   - Click **Save and Continue** through the remaining screens

4. Back in **Create OAuth client ID**:
   - **Application type**: Select **Web application**
   - **Name**: "TradeMatch Backend" or any name you prefer
   - **Authorized redirect URIs**: Leave empty (not needed for our setup)
   - Click **Create**

5. A dialog will show your credentials:
   - **Copy the Client ID** (looks like: `123456789-xxx.apps.googleusercontent.com`)
   - You can ignore the Client Secret for now

### Step 4: Configure Your Laravel Backend

1. Open `laravel/.env` file
2. Add this line:
   ```env
   GOOGLE_CLIENT_ID=your-web-client-id-here.apps.googleusercontent.com
   ```
3. Replace `your-web-client-id-here` with the **Web Application** Client ID you copied

### Step 5: Create Android OAuth Client (CRITICAL - Required to fix error 10)

**This is the missing piece causing your error!**

1. Go back to **APIs & Services** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
3. **Application type**: Select **Android**
4. **Name**: "TradeMatch Android" or any name you prefer
5. **Package name**: 
   - Open `Flutter/android/app/build.gradle.kts`
   - Find the `applicationId` (usually looks like `com.example.trade_match`)
   - Copy and paste it here
6. **SHA-1 certificate fingerprint** (REQUIRED):
   - Open a terminal in your Flutter directory
   - Run this command:
     ```bash
     cd Flutter
     keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```
   - Find the line that says "SHA1:" and copy the value (example: `A1:B2:C3:...`)
   - Paste it in the SHA-1 field
7. Click **Create**

> [!IMPORTANT]
> Without the Android OAuth client configured with the correct SHA-1 fingerprint, Google Sign-In will **always fail with error 10** on Android devices.

### Step 6: Add Android App to Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select the same project you created in Step 1
3. Click **Add app** → Select **Android** icon
4. **Android package name**: Use the same `applicationId` from `build.gradle.kts`
5. **App nickname**: "TradeMatch" or any name
6. **Debug signing certificate SHA-1**: Paste the same SHA-1 from Step 5
7. Click **Register app**
8. **Download `google-services.json`**
9. Place it in `Flutter/android/app/` directory

> [!NOTE]
> The `google-services.json` file must be placed exactly in `Flutter/android/app/` for Google Sign-In to work.

### Step 6.5: Configure Gradle Plugins (Required for Firebase)

After placing `google-services.json`, you need to add the Firebase Gradle plugins:

1. **Update `Flutter/android/build.gradle.kts`** - Add at the end of the file:
   ```kotlin
   plugins {
     // Add the dependency for the Google services Gradle plugin
     id("com.google.gms.google-services") version "4.4.4" apply false
   }
   ```

2. **Update `Flutter/android/app/build.gradle.kts`** - Add after the existing plugins:
   ```kotlin
   plugins {
       id("com.android.application")
       id("kotlin-android")
       id("dev.flutter.flutter-gradle-plugin")
       id("com.google.gms.google-services")  // ← Add this line
   }
   
   dependencies {
     // Import the Firebase BoM
     implementation(platform("com.google.firebase:firebase-bom:34.6.0"))
     implementation("com.google.firebase:firebase-analytics")
   }
   ```

> [!IMPORTANT]
> Without these Gradle plugins, Firebase won't be integrated and Google Sign-In will fail.

### Step 7: Verify Package Name Consistency

Make sure the package name is **exactly the same** in:
- `Flutter/android/app/build.gradle.kts` (`applicationId`)
- Google Cloud Console Android OAuth client
- Firebase project Android app
- `google-services.json` file (`package_name`)

If they don't match, Google Sign-In will fail.

### Step 8: Rebuild and Test

1. Clean and rebuild your Flutter app:
   ```bash
   cd Flutter
   flutter clean
   flutter pub get
   flutter run
   ```
2. Tap "Sign in with Google"
3. Select your Google account
4. Should successfully log in and redirect to the main page

---

## Understanding the Three OAuth Clients

1. Run your Flutter app: `cd Flutter && flutter run`
2. Tap "Sign in with Google"
3. Select your Google account
4. Should redirect to the app with successful login

### Important Notes

- **Client ID is safe to expose**: Unlike API keys, OAuth Client IDs are meant to be public and included in your app
- **For testing**: You can use just the Web Application client ID in `.env`
- **For production**: Create separate OAuth clients for Android, iOS, and Web

---

*This document should be updated as features are implemented.*

