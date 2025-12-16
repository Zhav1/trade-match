<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->enum('type', ['new_swap', 'new_message', 'swap_status_change', 'system']);
            $table->string('title');
            $table->text('message');
            $table->json('data')->nullable(); // Additional data like swap_id, item_id, etc.
            $table->boolean('is_read')->default(false);
            $table->timestamps();

            // Index for efficient queries (get unread notifications for user)
            $table->index(['user_id', 'is_read']);
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};
