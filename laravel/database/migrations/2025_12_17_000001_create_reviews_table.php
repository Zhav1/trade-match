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
        Schema::create('reviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('swap_id')->constrained('swaps')->onDelete('cascade');
            $table->foreignId('reviewer_user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('reviewed_user_id')->constrained('users')->onDelete('cascade');
            $table->tinyInteger('rating')->unsigned(); // 1-5 stars
            $table->text('comment')->nullable();
            $table->json('photos')->nullable(); // Array of photo URLs for future enhancement
            $table->timestamps();

            // Prevent duplicate reviews: one review per user per swap
            $table->unique(['swap_id', 'reviewer_user_id']);
            
            // Indexes for performance
            $table->index('reviewed_user_id');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};
