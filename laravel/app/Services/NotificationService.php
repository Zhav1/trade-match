<?php

namespace App\Services;

use App\Models\Notification;

class NotificationService
{
    /**
     * Create a notification for a new swap (match).
     *
     * @param int $userId
     * @param int $swapId
     * @param string $otherUserName
     * @return Notification
     */
    public function createSwapNotification($userId, $swapId, $otherUserName)
    {
        return Notification::create([
            'user_id' => $userId,
            'type' => 'new_swap',
            'title' => 'New Match!',
            'message' => "You and {$otherUserName} have matched!",
            'data' => ['swap_id' => $swapId],
        ]);
    }

    /**
     * Create a notification for a new message.
     *
     * @param int $userId
     * @param int $swapId
     * @param string $senderName
     * @return Notification
     */
    public function createMessageNotification($userId, $swapId, $senderName)
    {
        return Notification::create([
            'user_id' => $userId,
            'type' => 'new_message',
            'title' => 'New Message',
            'message' => "{$senderName} sent you a message",
            'data' => ['swap_id' => $swapId],
        ]);
    }

    /**
     * Create a notification for a swap status change.
     *
     * @param int $userId
     * @param int $swapId
     * @param string $newStatus
     * @return Notification
     */
    public function createSwapStatusChangeNotification($userId, $swapId, $newStatus)
    {
        $statusMessages = [
            'location_suggested' => 'A location has been suggested for your trade',
            'location_agreed' => 'Location confirmed for your trade',
            'trade_complete' => 'Your trade has been completed!',
            'cancelled' => 'Your trade has been cancelled',
        ];

        $message = $statusMessages[$newStatus] ?? "Your trade status changed to {$newStatus}";

        return Notification::create([
            'user_id' => $userId,
            'type' => 'swap_status_change',
            'title' => 'Trade Update',
            'message' => $message,
            'data' => ['swap_id' => $swapId, 'new_status' => $newStatus],
        ]);
    }

    /**
     * Create a system notification.
     *
     * @param int $userId
     * @param string $title
     * @param string $message
     * @param array|null $data
     * @return Notification
     */
    public function createSystemNotification($userId, $title, $message, $data = null)
    {
        return Notification::create([
            'user_id' => $userId,
            'type' => 'system',
            'title' => $title,
            'message' => $message,
            'data' => $data,
        ]);
    }
}
