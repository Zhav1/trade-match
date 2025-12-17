# BarterSwap - Code Snippets Library

> **Purpose**: High-value code solutions, configurations, and patterns extracted from implementation.

---

## Google OAuth Backend Verification

**Context**: Verify Google idToken without using google/apiclient package (avoids dependency conflicts).

**Code**:
```php
// Laravel: app/Http/Controllers/AuthController.php
public function googleLogin(Request $request)
{
    $request->validate(['idToken' => 'required|string']);
    
    $idToken = $request->input('idToken');
    
    // Verify token with Google
    $response = Http::withoutVerifying()->get("https://oauth2.googleapis.com/tokeninfo", [
        'id_token' => $idToken
    ]);
    
    if (!$response->successful()) {
        return response()->json(['error' => 'Invalid Google token'], 401);
    }
    
    $googleData = $response->json();
    
    // Check if user exists or create new
    $user = User::updateOrCreate(
        ['email' => $googleData['email']],
        [
            'name' => $googleData['name'],
            'google_id' => $googleData['sub'],
        ]
    );
    
    $token = $user->createToken('auth-token')->plainTextToken;
    
    return response()->json([
        'token' => $token,
        'user' => $user,
    ]);
}
```

**Tags**: #Laravel #GoogleOAuth #Authentication

---

## AppinioSwiper Type-Safe Index Handling

**Context**: `AppinioSwiper` callbacks sometimes return dynamic types. Fixes `type 'String' is not a subtype of type 'int'` errors.

**Code**:
```dart
// Flutter: lib/screens/explore_screen.dart
AppinioSwiper(
  onSwipeEnd: (int previousIndex, int targetIndex, SwiperActivity activity) {
    // Safe index conversion
    final int idx = (previousIndex is int) 
        ? previousIndex 
        : int.parse(previousIndex.toString());
    
    final item = items[idx];
    // Use item...
  },
  cardBuilder: (context, index) {
    // Safe index conversion
    final int idx = (index is int) 
        ? index 
        : int.parse(index.toString());
    
    return _buildCard(items[idx]);
  },
)
```

**Tags**: #Flutter #TypeSafety #AppinioSwiper #Fix

---

## Haversine Distance Calculation (Flutter)

**Context**: Calculate distance between two lat/lng points without backend geospatial queries.

**Code**:
```dart
// Flutter: lib/screens/explore_screen.dart
import 'package:geolocator/geolocator.dart';

double calculateDistance(double userLat, double userLon, double itemLat, double itemLon) {
  final distanceInMeters = Geolocator.distanceBetween(
    userLat,
    userLon,
    itemLat,
    itemLon,
  );
  
  return distanceInMeters / 1000; // Convert to kilometers
}

// Usage in UI:
final distance = calculateDistance(
  _userLat!, _userLon!, 
  item.locationLat, item.locationLon
);
final distanceText = distance < 1 
    ? '${(distance * 1000).round()} m' 
    : '${distance.toStringAsFixed(1)} km';
```

**Tags**: #Flutter #Geolocator #Distance #Haversine

---

## Laravel Eager Loading with Latest Relationship

**Context**: Load swaps with their latest message for chat list preview (avoids N+1 queries).

**Code**:
```php
// Laravel: app/Http/Controllers/SwapController.php
public function index(Request $request)
{
    $status = $request->query('status');
    
    $swaps = Swap::with([
        'itemA.user',
        'itemA.images',
        'itemB.user',
        'itemB.images',
        'latestMessage', // Key: Load latest message relationship
    ])
    ->when($status, function($query, $status) {
        return $query->where('status', $status);
    })
    ->where(function ($query) use ($userId) {
        $query->where('user_a_id', $userId)
              ->orWhere('user_b_id', $userId);
    })
    ->orderBy('updated_at', 'desc')
    ->get();
    
    return response()->json(['swaps' => $swaps]);
}

// Define in Swap model:
public function latestMessage()
{
    return $this->hasOne(Message::class)->latestOfMany();
}
```

**Tags**: #Laravel #Eloquent #EagerLoading #Performance

---

## Flutter Multipart Image Upload

**Context**: Upload images with form data to Laravel backend.

**Code**:
```dart
// Flutter: lib/services/api_service.dart
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> createItem({
  required String title,
  required String description,
  required List<File> images,
  // ... other fields
}) async {
  final token = await _storage.read(key: 'auth_token');
  
  var request = http.MultipartRequest('POST', Uri.parse('$API_BASE/api/items'));
  request.headers['Authorization'] = 'Bearer $token';
  request.headers['Accept'] = 'application/json';
  
  // Add text fields
  request.fields['title'] = title;
  request.fields['description'] = description;
  
  // Add multiple images
  for (int i = 0; i < images.length; i++) {
    var stream = http.ByteStream(images[i].openRead());
    var length = await images[i].length();
    var multipartFile = http.MultipartFile(
      'images[]', // Note the [] for arrays
      stream,
      length,
      filename: 'image_$i.jpg',
    );
    request.files.add(multipartFile);
  }
  
  var response = await request.send();
  var responseBody = await response.stream.bytesToString();
  
  if (response.statusCode == 200 || response.statusCode == 201) {
    return json.decode(responseBody);
  } else {
    throw Exception(json.decode(responseBody)['message'] ?? 'Upload failed');
  }
}
```

**Tags**: #Flutter #MultipartUpload #ImageUpload #HTTP

---

## Laravel Multipart Image Handling

**Context**: Receive and store multiple images from Flutter.

**Code**:
```php
// Laravel: app/Http/Controllers/ItemController.php
public function store(Request $request)
{
    $validated = $request->validate([
        'title' => 'required|string|max:255',
        'images' => 'array|max:5',
        'images.*' => 'image|mimes:jpeg,png,jpg|max:5120', // 5MB per image
    ]);
    
    $item = Item::create([
        'user_id' => auth()->id(),
        'title' => $validated['title'],
        // ... other fields
    ]);
    
    // Store images
    if ($request->hasFile('images')) {
        foreach ($request->file('images') as $index => $image) {
            $path = $image->store('images', 'public');
            
            ItemImage::create([
                'item_id' => $item->id,
                'image_url' => Storage::url($path), // e.g., /storage/images/xyz.jpg
                'display_order' => $index,
            ]);
        }
    }
    
    return response()->json($item->load('images'), 201);
}
```

**Note**: Run `php artisan storage:link` to create public symlink.

**Tags**: #Laravel #FileUpload #Storage #Images

---

## Pusher Real-time Chat Integration (Flutter)

**Context**: Listen to private Pusher channels for real-time messages.

**Code**:
```dart
// Flutter: lib/chat/chat_detail.dart
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class _ChatDetailPageState extends State<ChatDetailPage> {
  late PusherChannelsFlutter pusher;
  
  @override
  void initState() {
    super.initState();
    _initPusher();
  }
  
  Future<void> _initPusher() async {
    pusher = PusherChannelsFlutter.getInstance();
    
    await pusher.init(
      apiKey: PUSHER_KEY,
      cluster: PUSHER_CLUSTER,
      authEndpoint: '$API_BASE/broadcasting/auth',
      onAuthorizer: (channelName, socketId, options) async {
        final token = await _storage.read(key: 'auth_token');
        return {
          'Authorization': 'Bearer $token',
        };
      },
    );
    
    await pusher.subscribe(
      channelName: 'private-swap.${widget.swap.id}',
      onEvent: (event) {
        if (event.eventName == 'NewChatMessage') {
          final messageData = json.decode(event.data);
          setState(() {
            _messages.add(Message.fromJson(messageData['message']));
          });
        }
      },
    );
    
    await pusher.connect();
  }
  
  @override
  void dispose() {
    pusher.disconnect();
    super.dispose();
  }
}
```

**Tags**: #Flutter #Pusher #WebSocket #RealTime

---

## Laravel Broadcast Private Channel Authorization

**Context**: Authorize user access to private Pusher channels.

**Code**:
```php
// Laravel: routes/channels.php
use App\Models\Swap;

Broadcast::channel('swap.{swapId}', function ($user, $swapId) {
    $swap = Swap::find($swapId);
    
    if (!$swap) {
        return false;
    }
    
    // Check if user is participant in this swap
    return $swap->user_a_id === $user->id || $swap->user_b_id === $user->id;
});
```

```php
// Laravel: app/Events/NewChatMessage.php
class NewChatMessage implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $message;
    public $swap;

    public function __construct($message, $swap)
    {
        $this->message = $message;
        $this->swap = $swap;
    }

    public function broadcastOn()
    {
        return new PrivateChannel('swap.' . $this->swap->id);
    }
}
```

**Tags**: #Laravel #Pusher #Broadcasting #Authorization

---

## Dynamic Current User Item Selection

**Context**: Get user's first available item for swipe functionality (fixes hardcoded item ID issue).

**Code**:
```dart
// Flutter: lib/screens/explore_screen.dart
class _ExploreScreenState extends State<ExploreScreen> {
  int? _currentUserItemId;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    try {
      final userItems = await _apiService.getUserItems();
      
      if (userItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please create an item first to start swiping')),
        );
        return;
      }
      
      setState(() {
        _currentUserItemId = userItems.first.id;
      });
      
      _loadItems();
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> _handleSwipe(BarterItem item, String action) async {
    if (_currentUserItemId == null) return;
    
    await _apiService.swipe(_currentUserItemId!, item.id, action);
  }
}
```

**Tags**: #Flutter #DynamicData #StateManagement

---

## Laravel Sanctum Token Verification Middleware

**Context**: Validate Bearer token on every API request.

**Code**:
```php
// Laravel: routes/api.php
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [UserController::class, 'getAuthenticatedUser']);
    Route::post('/items', [ItemController::class, 'store']);
    // ... all protected routes
});
```

```php
// Laravel: app/Http/Controllers/UserController.php
public function getAuthenticatedUser(Request $request)
{
    $user = $request->user(); // Automatically from token
    
    return response()->json([
        'user' => $user,
        'offers_count' => $user->items()->count(),
        'trades_count' => $user->swaps()->count(),
    ]);
}
```

**Tags**: #Laravel #Sanctum #Authentication #Middleware

---

## Flutter Secure Token Storage

**Context**: Store Sanctum Bearer token securely (not SharedPreferences).

**Code**:
```dart
// Flutter: lib/services/api_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
  
  // Add token to all requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
```

**Tags**: #Flutter #Security #TokenStorage #FlutterSecureStorage

---

## ProcessSwipeJob - Async Swap Creation

**Context**: Check for mutual likes and create swap asynchronously when both users like each other's items.

**Code**:
```php
// Laravel: app/Jobs/ProcessSwipeJob.php
class ProcessSwipeJob implements ShouldQueue
{
    public $swipe;

    public function handle()
    {
        $swiper = Item::find($this->swipe->swiper_item_id);
        $swipedOn = Item::find($this->swipe->swiped_on_item_id);
        
        if ($this->swipe->action !== 'like') return;
        
        // Check for mutual like
        $mutualSwipe = Swipe::where('swiper_item_id', $swipedOn->id)
            ->where('swiped_on_item_id', $swiper->id)
            ->where('action', 'like')
            ->first();
        
        if (!$mutualSwipe) return;
        
        // Create swap (use min/max to avoid duplicates)
        $swap = Swap::firstOrCreate([
            'item_a_id' => min($swiper->id, $swipedOn->id),
            'item_b_id' => max($swiper->id, $swipedOn->id),
        ], [
            'status' => 'active',
        ]);
        
        // Send notifications to both users
        NotificationService::createSwapNotification($swap, $swiper->user_id);
        NotificationService::createSwapNotification($swap, $swipedOn->user_id);
    }
}
```

**Tags**: #Laravel #Jobs #Queue #BusinessLogic

---

## Flutter Pull-to-Refresh Pattern

**Context**: Standard pull-to-refresh implementation for API-driven lists.

**Code**:
```dart
// Flutter: Generic pattern
class _MyPageState extends State<MyPage> {
  List<Item> _items = [];
  bool _isLoading = true;
  
  Future<void> _loadData({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      final data = await _apiService.getData();
      setState(() {
        _items = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _loadData(refresh: true),
      child: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(_items[index].name));
              },
            ),
    );
  }
}
```

**Tags**: #Flutter #UI #RefreshIndicator #Pattern

---

## Review Constraint Validation (Laravel)

**Context**: Enforce business rules for review submission (one review per user per swap).

**Code**:
```php
// Laravel: app/Http/Controllers/Api/ReviewController.php
public function store(Request $request)
{
    $validated = $request->validate([
        'swap_id' => 'required|exists:swaps,id',
        'reviewed_user_id' => 'required|exists:users,id',
        'rating' => 'required|integer|min:1|max:5',
        'comment' => 'nullable|string|max:500',
    ]);
    
    $swap = Swap::findOrFail($validated['swap_id']);
    
    // 1. Check swap is complete
    if ($swap->status !== 'trade_complete') {
        return response()->json(['error' => 'Can only review completed trades'], 400);
    }
    
    // 2. Check user is participant
    $userId = auth()->id();
    $isParticipant = $swap->user_a_id == $userId || $swap->user_b_id == $userId;
    if (!$isParticipant) {
        return response()->json(['error' => 'You are not a participant'], 403);
    }
    
    // 3. Check reviewed user is OTHER participant
    $otherUserId = $swap->user_a_id == $userId ? $swap->user_b_id : $swap->user_a_id;
    if ($validated['reviewed_user_id'] != $otherUserId) {
        return response()->json(['error' => 'Invalid reviewed user'], 400);
    }
    
    // 4. Check for duplicate (database will also enforce)
    $existing = Review::where('swap_id', $swap->id)
        ->where('reviewer_user_id', $userId)
        ->first();
    if ($existing) {
        return response()->json(['error' => 'Already reviewed'], 400);
    }
    
    $review = Review::create([
        'swap_id' => $swap->id,
        'reviewer_user_id' => $userId,
        'reviewed_user_id' => $otherUserId,
        'rating' => $validated['rating'],
        'comment' => $validated['comment'] ?? null,
    ]);
    
    return response()->json($review->load('reviewer', 'swap'), 201);
}
```

**Tags**: #Laravel #Validation #BusinessLogic #Reviews

---

## Notification Service Pattern

**Context**: Centralize notification creation logic to avoid duplication.

**Code**:
```php
// Laravel: app/Services/NotificationService.php
class NotificationService
{
    public static function createSwapNotification($swap, $userId)
    {
        $otherUser = $swap->user_a_id == $userId 
            ? $swap->userB 
            : $swap->userA;
        
        Notification::create([
            'user_id' => $userId,
            'type' => 'new_swap',
            'title' => 'New Match!',
            'message' => "You matched with {$otherUser->name}",
            'data' => json_encode(['swap_id' => $swap->id]),
        ]);
    }
    
    public static function createMessageNotification($swap, $recipientId, $message)
    {
        Notification::create([
            'user_id' => $recipientId,
            'type' => 'new_message',
            'title' => 'New Message',
            'message' => $message->message_text,
            'data' => json_encode(['swap_id' => $swap->id]),
        ]);
    }
}
```

**Usage**:
```php
// In controller or job:
NotificationService::createSwapNotification($swap, $user->id);
```

**Tags**: #Laravel #ServicePattern #Notifications #DRY

---

## Race Condition Prevention with Database Locking

**Context**: Preventing duplicate record creation during concurrent requests (e.g., swap creation when both users swipe simultaneously).

**Problem**: `firstOrCreate()` is not atomic - can create duplicates or miss records under concurrency.

**Solution Pattern**:
```php
use Illuminate\Support\Facades\DB;

// Race-safe record creation
DB::transaction(function () use ($id1, $id2, &$result) {
    // 1. Lock rows to prevent concurrent access
    $existing = Model::where('field_a', $id1)
        ->where('field_b', $id2)
        ->lockForUpdate()  // Pessimistic lock - blocks other transactions
        ->first();
    
    // 2. Early return if already exists
    if ($existing) {
        $result = $existing;
        return;
    }
    
    // 3. Create new record safely
    $result = Model::create([
        'field_a' => $id1,
        'field_b' => $id2,
        'status' => 'active',
    ]);
});
```

**Key Points**:
- `lockForUpdate()` acquires row-level lock in database
- Other transactions wait until first commits
- Use `&$result` to pass variable out of closure
- Always wrap in `DB::transaction()` for automatic rollback on error

**Applied In**: `app/Jobs/ProcessSwipeJob.php` - Swap creation on mutual likes

**Tags**: #Laravel #Concurrency #DatabaseLocking #RaceCondition

---

## API Resource for Data Sanitization

**Context**: Filtering sensitive user data from public API responses (GDPR compliance, privacy protection).

**Use Case**: Remove email/phone, fuzzy GPS coordinates to prevent exact location tracking.

**Pattern**:
```php
namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

// Parent resource - filters sensitive fields
class UserPublicResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'profile_picture_url' => $this->profile_picture_url,
            'rating' => $this->average_rating ?? null,
            // SECURITY: Removed email, phone, google_id, exact coordinates
        ];
    }
}

// Child resource - applies parent filtering + adds custom filters
class ItemResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            
            // SECURITY: Fuzzy location (3 decimals = ~100m precision)
            // 14.550431 → 14.550 (30-100m error radius)
            'location_lat' => $this->location_lat ? round($this->location_lat, 3) : null,
            'location_lon' => $this->location_lon ? round($this->location_lon, 3) : null,
            
            // Nested resource filtering
            'user' => new UserPublicResource($this->whenLoaded('user')),
            'category' => $this->whenLoaded('category'),
            'images' => $this->whenLoaded('images'),
        ];
    }
}
```

**Usage in Controller**:
```php
// Single resource
return new ItemResource($item);

// Collection
return ItemResource::collection($items);

// With pagination
return ItemResource::collection($items->paginate(20));
```

**Applied In**: All responses in `ExploreController`, `ItemController`, `SwapController`

**Tags**: #Laravel #APIResource #DataPrivacy #GDPR #Security

---

## Form Request Validation Pattern (DoS Prevention)

**Context**: Centralized input validation with size limits to prevent Denial of Service attacks.

**Problem**: Manual validation is repetitive and size limits are scattered across controllers.

**Pattern**:
```php
namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class CreateItemRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // Auth handled by 'auth:sanctum' middleware
    }

    public function rules(): array
    {
        return [
            // String size limits
            'title' => 'required|string|max:100',
            'description' => 'required|string|max:2000',
            'location_name' => 'required|string|max:255',
            
            // Array size limits (prevent flooding)
            'image_urls' => 'required|array|max:10',  // Max 10 images
            'image_urls.*' => 'url|max:500',
            'wanted_category_ids' => 'nullable|array|max:5',  // Max 5 categories
            
            // Enum validation
            'condition' => ['required', Rule::in(['new', 'like_new', 'good', 'fair'])],
            
            // Numeric bounds
            'estimated_value' => 'nullable|numeric|min:0|max:10000000',
            'location_lat' => 'required|numeric|between:-90,90',
            'location_lon' => 'required|numeric|between:-180,180',
        ];
    }
}
```

**Usage in Controller**:
```php
// Type-hint Form Request instead of Request
public function store(CreateItemRequest $request): JsonResponse
{
    // Validation already happened automatically
    // Returns 422 with error details if validation fails
    $validatedData = $request->validated();
    
    // Use validated data safely
    $item = Item::create($validatedData);
    return new ItemResource($item);
}
```

**Benefits**:
- Automatic 422 validation error responses
- Centralized rule management
- Type-safe validated data
- DRY principle (remove repetitive `validate()` calls)
- DoS prevention via size limits

**Applied In**: `ItemController::store()`, `SwapController::sendMessage()`, `SwapController::suggestLocation()`

**Tags**: #Laravel #FormRequest #Validation #DoSPrevention #Security

---

## Laravel 11 Scheduled Task Registration

**Context**: Laravel 11 removed `app/Console/Kernel.php`. Task scheduling now lives in `routes/console.php`.

**Pattern**:
```php
// routes/console.php
use Illuminate\Support\Facades\Schedule;

// Register hourly task
Schedule::command('swaps:reset-expired-locations')->hourly();

// Other scheduling intervals
Schedule::command('daily:cleanup')->daily();
Schedule::command('weekly:report')->weekly();
Schedule::command('monthly:billing')->monthly();
Schedule::command('frequent:check')->everyFiveMinutes();

// With custom time
Schedule::command('daily:backup')->dailyAt('02:00');

// Conditional scheduling
Schedule::command('heavy:job')->weekly()->when(function () {
    return DB::table('settings')->where('key', 'maintenance_mode')->value('value') === 'off';
});
```

**Command Example**:
```php
// app/Console/Commands/ResetExpiredLocationSuggestions.php
class ResetExpiredLocationSuggestions extends Command
{
    protected $signature = 'swaps:reset-expired-locations';
    protected $description = 'Reset location suggestions pending > 48 hours';

    public function handle(): void
    {
        $resetCount = Swap::where('status', 'location_suggested')
            ->where('location_suggested_at', '<', now()->subHours(48))
            ->update([
                'status' => 'active',
                'location_suggested_at' => null
            ]);

        $this->info("Reset {$resetCount} expired suggestions.");
    }
}
```

**Applied In**: Location timeout reset command runs hourly

**Remember**: Laravel 11 structure differs significantly from Laravel 10.x documentation!

**Tags**: #Laravel #Laravel11 #Scheduling #Cron #TaskScheduler

---

## Rate Limiting Middleware (Spam Prevention)

**Context**: Prevent API abuse and DoS attacks on critical endpoints.

**Pattern**:
```php
// routes/api.php

Route::middleware('auth:sanctum')->group(function () {
    // Format: throttle:{max_attempts},{decay_minutes}
    
    // High-frequency actions (per minute)
    Route::post('/swipe', [SwipeController::class, 'store'])
        ->middleware('throttle:100,1');  // 100 swipes per minute
    
    Route::post('/swaps/{swap}/messages', [SwapController::class, 'sendMessage'])
        ->middleware('throttle:60,1');  // 60 messages per minute
    
    // Low-frequency actions (per hour)
    Route::post('/items', [ItemController::class, 'store'])
        ->middleware('throttle:10,60');  // 10 items per 60 minutes
    
    // Custom rate limits by user type
    Route::post('/premium-feature', [Controller::class, 'method'])
        ->middleware('throttle:rate_limit_premium');  // Define in RouteServiceProvider
});
```

**Response When Exceeded**:
```json
HTTP/1.1 429 Too Many Requests
Retry-After: 42
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 0

{
    "message": "Too Many Requests",
    "retry_after": 42
}
```

**Frontend Handling**:
```dart
// Flutter example
try {
  await apiService.swipe(itemId);
} on DioError catch(e) {
  if (e.response?.statusCode == 429) {
    final retryAfter = e.response?.headers.value('retry-after');
    showSnackBar('Slow down! Try again in ${retryAfter}s');
  }
}
```

**Applied In**: Swipe (100/min), Item creation (10/hr), Messaging (60/min)

**Tags**: #Laravel #RateLimiting #ThrottleMiddleware #DoSPrevention #SpamProtection

---

## Flutter UI/UX Components

### Glassmorphism Card
**Usage**: Create frosted glass effect cards

```dart
import 'package:trade_match/theme.dart';

GlassCard(
  padding: const EdgeInsets.all(16),
  borderRadius: 16,
  onTap: () => print('Tapped'),
  child: Column(
    children: [
      Text('Glass Effect Card'),
      // Your content
    ],
  ),
)
```

**Tags**: #Flutter #Glassmorphism #UI #ModernDesign

---

### Gradient Button with Loading State
**Usage**: Modern gradient buttons with built-in loading and icons

```dart
import 'package:trade_match/theme.dart';

GradientButton(
  text: 'Submit Form',
  onPressed: _isLoading ? null : _handleSubmit,
  icon: Icons.send,
  isLoading: _isLoading, // Shows spinner when true
  gradient: AppGradients.primary, // Optional: defaults to primary
)
```

**Tags**: #Flutter #GradientButton #ModernUI #LoadingState

---

### Skeleton Loading Pattern
**Usage**: Professional loading states with shimmer + glassmorphism

```dart
import 'package:shimmer/shimmer.dart';
import 'package:trade_match/theme.dart';

// For grid skeleton
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: ResponsiveUtils.getGridColumns(context),
  ),
  itemCount: 6, // Number of skeleton cards
  itemBuilder: (context, index) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Expanded(child: Container(color: Colors.white)),
            // Add placeholder text boxes
          ],
        ),
      ),
    );
  },
)
```

**Tags**: #Flutter #SkeletonLoading #Shimmer #Glassmorphism #UX

---

### Responsive Grid Columns
**Usage**: Auto-adjusting grid columns based on screen size

```dart
import 'package:trade_match/theme.dart';

GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: ResponsiveUtils.getGridColumns(
      context,
      mobile: 2,   // < 600px
      tablet: 3,   // 600-1024px
      desktop: 4,  // > 1024px
    ),
    crossAxisSpacing: AppSpacing.sm,
    mainAxisSpacing: AppSpacing.sm,
  ),
  // ...
)
```

**Tags**: #Flutter #ResponsiveDesign #Grid #Breakpoints

---

### Responsive Value Selection
**Usage**: Select different values based on device type

```dart
import 'package:trade_match/theme.dart';

final padding = ResponsiveUtils.responsiveValue<double>(
  context,
  mobile: 16,
  tablet: 24,
  desktop: 32,
);

// Or use helper for padding
final edgeInsets = ResponsiveUtils.getResponsivePadding(
  context,
  mobile: EdgeInsets.all(16),
  tablet: EdgeInsets.all(24),
);
```

**Tags**: #Flutter #Responsive #ContextExtensions #Utilities

---

### Custom Page Transitions
**Usage**: Animated navigation between screens

```dart
import 'package:trade_match/theme.dart';

// Slide transition
AnimatedNavigation.slideToPage(
  context,
  DetailPage(),
  direction: AxisDirection.right, // left/right/up/down
);

// Fade transition
AnimatedNavigation.fadeToPage(context, NextPage());

// Scale + fade transition
AnimatedNavigation.scaleToPage(context, NextPage());
```

**Tags**: #Flutter #Animation #PageTransition #Navigation

---

### Staggered List Animation
**Usage**: Animated list items with staggered entrance

```dart
import 'package:trade_match/theme.dart';

ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return AnimatedListItem(
      index: index,
      delay: Duration(milliseconds: 50), // Delay between items
      child: ListTile(
        title: Text(items[index]),
      ),
    );
  },
)
```

**Tags**: #Flutter #Animation #StaggeredAnimation #Lists

---

### Design System Usage
**Usage**: Consistent styling across app

```dart
import 'package:trade_match/theme.dart';

// Typography
Text('Heading', style: AppTextStyles.heading1);
Text('Body', style: AppTextStyles.bodyMedium);
Text('Label', style: AppTextStyles.labelBold);

// Colors
Container(color: AppColors.primary);
Text('Text', style: TextStyle(color: AppColors.textPrimary));

// Spacing
Padding(padding: EdgeInsets.all(AppSpacing.md));
SizedBox(height: AppSpacing.lg);

// Border Radius
BorderRadius.circular(AppRadius.card);

// Shadows
BoxDecoration(
  boxShadow: [
    BoxShadow(
      blurRadius: AppElevation.medium,
      color: Colors.black.withOpacity(0.1),
    ),
  ],
)
```

**Tags**: #Flutter #DesignSystem #Tokens #Consistency

---

## Summary of Patterns

1. **Google OAuth**: Direct HTTP tokeninfo verification
2. **Type Safety**: Defensive casting for third-party types
3. **Distance**: Client-side Haversine formula
4. **Uploads**: Multipart with `images[]` array notation
5. **Real-time**: Pusher private channels with auth
6. **Token**: Secure storage + Bearer header pattern
7. **Jobs**: Async swap creation on mutual like
8. **Validation**: Multi-layer business rule enforcement
9. **Services**: Centralized notification creation
10. **UI Patterns**: Pull-to-refresh + loading/error/empty states
11. **Race Conditions**: DB transactions with `lockForUpdate()`
12. **Data Privacy**: API Resources for field filtering
13. **Input Validation**: Form Requests with size limits
14. **Task Scheduling**: Laravel 11 `routes/console.php` pattern
15. **Rate Limiting**: Throttle middleware for spam prevention
16. **Design System**: Token-based styling with centralized theme
17. **Responsive Design**: Breakpoint system with adaptive layouts
18. **Glassmorphism**: Frosted glass effects for modern UI
19. **Gradients**: Visual hierarchy with gradient buttons
20. **Skeleton Loading**: Shimmer + glass for professional loading states
21. **Animations**: Custom page routes and micro-interactions
22. **Local Caching**: Hive with TTL-based expiration
23. **Image Optimization**: CachedNetworkImage with memory limits
24. **Memory Management**: Proper disposal patterns
25. **Debouncing**: Prevent API spam on rapid input

---

## Hive Cache-First Pattern

**Context**: Implement local caching with fallback to API if cache is invalid or unavailable (zero-regression pattern).

**Code**:
```dart
// Flutter: lib/services/api_service.dart
import 'package:trade_match/services/storage_service.dart';

Future<List<Category>> getCategories() async {
  try {
    // CHECKPOINT 1: Check cache metadata
    final meta = await StorageService.getCacheMetadata('categories');
    
    if (meta != null && !meta.isExpired) {
      // Cache hit - return immediately
      final categoriesBox = StorageService.categoriesBox;
      if (categoriesBox != null && categoriesBox.isNotEmpty) {
        print('✅ Categories loaded from cache (${categoriesBox.length} items)');
        return categoriesBox.values.toList();
      }
    }
  } catch (e) {
    print('⚠️ Cache check failed: $e, falling back to API');
  }
  
  // CHECKPOINT 2: Fetch from network
  final response = await http.get(Uri.parse('$API_BASE/api/categories'));
  final categories = parseCategories(response);
  
  // CHECKPOINT 3: Update cache (best-effort)
  try {
    await StorageService.cacheCategories(categories);
  } catch (e) {
    // Don't fail request if caching fails
  }
  
  return categories;
}
```

**Tags**: #Flutter #Hive #Caching #ZeroRegression #Performance

---

## CachedNetworkImage with Shimmer Placeholder

**Context**: Replace Image.network with cached version.

**Code**:
```dart
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: imageUrl,
  fit: BoxFit.cover,
  memCacheWidth: 1200, // Memory optimization
  placeholder: (context, url) => Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(color: Colors.white),
  ),
  errorWidget: (context, url, error) => Icon(Icons.broken_image),
)
```

**Tags**: #Flutter #ImageCaching #Performance

---

## AnimationController Disposal Pattern

**Context**: Prevent memory leaks.

**Code**:
```dart
class MyScreen extends StatefulWidget with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
  }
  
  @override
  void dispose() {
    _controller.dispose(); // CRITICAL
    super.dispose();
  }
}
```

**Tags**: #Flutter #MemoryManagement

---

## Debouncer for Search Input

**Context**: Prevent API spam on search-as-you-type.

**Code**:
```dart
class Debouncer {
  Timer? _timer;
  final Duration delay;
  
  Debouncer({this.delay = const Duration(milliseconds: 300)});
  
  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
  
  void dispose() => _timer?.cancel();
}

// Usage
final debouncer = Debouncer();
TextField(onChanged: (q) => debouncer.call(() => search(q)))
```

**Tags**: #Flutter #APIOptimization


## SNIPPETS.md

**Add these entries at the end of the file:**

```markdown
---

## Supabase Service Pattern (Flutter)

**Context**: Centralized service for all Supabase operations with automatic JWT management.

**Code**:
```dart
// Flutter: lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Auth Methods
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signInWithGoogleIdToken(String idToken) async {
    return await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  // Data Methods with Type Transformation
  Future<List<Map<String, dynamic>>> getUserItems() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _client
        .from('items')
        .select('*, category(*), images(*), wants(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Edge Function Calls
  Future<Map<String, dynamic>> swipe(
    int userItemId,
    int targetItemId,
    String action,
  ) async {
    final response = await _client.functions.invoke(
      'process-swipe',
      body: {
        'user_item_id': userItemId,
        'target_item_id': targetItemId,
        'action': action,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  // Storage Methods
  Future<String> uploadImage(File file) async {
    final userId = _client.auth.currentUser?.id;
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    await _client.storage
        .from('item-images')
        .upload(fileName, file);

    return _client.storage
        .from('item-images')
        .getPublicUrl(fileName);
  }
}

Usage:

dart
// In screens
final _supabaseService = SupabaseService();
// Fetch data
final itemsData = await _supabaseService.getUserItems();
final items = itemsData.map((data) => Item.fromJson(data)).toList();
// Call Edge Function
await _supabaseService.swipe(myItemId, theirItemId, 'like');
Tags: #Flutter #Supabase #ServicePattern #Architecture

Supabase Edge Function Template
Context: TypeScript serverless function for business logic with auth and error handling.

Code:

typescript
// supabase/functions/my-function/index.ts
import { serve } from '[https://deno.land/std@0.168.0/http/server.ts'](https://deno.land/std@0.168.0/http/server.ts')
import { createClient } from '[https://esm.sh/@supabase/supabase-js@2'](https://esm.sh/@supabase/supabase-js@2')
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}
serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }
  try {
    // Get authenticated user
    const authHeader = req.headers.get('Authorization')!
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
    // Parse request body
    const { param1, param2 } = await req.json()
    // Business logic here
    const { data, error } = await supabase
      .from('table_name')
      .select('*')
      .eq('user_id', user.id)
    if (error) throw error
    // Return response
    return new Response(
      JSON.stringify({ data }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
Deployment:

bash
supabase functions deploy my-function
Tags: #Supabase #EdgeFunctions #TypeScript #Serverless

Supabase Row Level Security (RLS) Policy Pattern
Context: Secure database access by ensuring users can only access their own data.

Code:

sql
-- Enable RLS on table
ALTER TABLE items ENABLE ROW LEVEL SECURITY;
-- Policy: Users can view their own items
CREATE POLICY "Users can view own items"
ON items FOR SELECT
USING (auth.uid() = user_id);
-- Policy: Users can insert their own items
CREATE POLICY "Users can insert own items"
ON items FOR INSERT
WITH CHECK (auth.uid() = user_id);
-- Policy: Users can update their own items
CREATE POLICY "Users can update own items"
ON items FOR UPDATE
USING (auth.uid() = user_id);
-- Policy: Users can delete their own items
CREATE POLICY "Users can delete own items"
ON items FOR DELETE
USING (auth.uid() = user_id);
-- Policy: Users can view items they're involved in (for swaps)
CREATE POLICY "Users can view swap items"
ON items FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM swaps
    WHERE (swaps.item_a_id = items.id OR swaps.item_b_id = items.id)
    AND (swaps.user_a_id = auth.uid() OR swaps.user_b_id = auth.uid())
  )
);
Tags: #Supabase #RLS #Security #PostgreSQL

Flutter Data Transformation Pattern (Supabase)
Context: Transform Supabase JSON responses to typed Flutter models.

Code:

dart
// Model with fromJson factory
class Item {
  final int id;
  final String title;
  final String description;
  // ... other fields
  Item({required this.id, required this.title, required this.description});
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: int.parse(json['id'].toString()),
      title: json['title'],
      description: json['description'],
      // ... other fields
    );
  }
}
// In screen/service
Future<List<Item>> loadItems() async {
  // Supabase returns List<Map<String, dynamic>>
  final itemsData = await _supabaseService.getUserItems();
  
  // Transform to typed models
  final items = itemsData.map((data) => Item.fromJson(data)).toList();
  
  return items;
}
// Alternative: Direct transformation in service
class SupabaseService {
  Future<List<Map<String, dynamic>>> getUserItemsRaw() async {
    final response = await _client.from('items').select('*');
    return List<Map<String, dynamic>>.from(response);
  }
}
Tags: #Flutter #Supabase #DataTransformation #TypeSafety

Supabase Realtime Subscription (Flutter)
Context: Listen to database changes in real-time.

Code:

dart
import 'package:supabase_flutter/supabase_flutter.dart';
class ChatService {
  final SupabaseClient _client = Supabase.instance.client;
  RealtimeChannel? _channel;
  void subscribeToMessages(String swapId, Function(Map<String, dynamic>) onMessage) {
    _channel = _client
        .channel('messages:$swapId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'swap_id',
            value: swapId,
          ),
          callback: (payload) {
            onMessage(payload.newRecord);
          },
        )
        .subscribe();
  }
  void unsubscribe() {
    _channel?.unsubscribe();
  }
}
// Usage in screen
@override
void initState() {
  super.initState();
  _chatService.subscribeToMessages(widget.swapId, (message) {
    setState(() {
      _messages.add(Message.fromJson(message));
    });
  });
}
@override
void dispose() {
  _chatService.unsubscribe();
  super.dispose();
}
Tags: #Flutter #Supabase #Realtime #WebSockets