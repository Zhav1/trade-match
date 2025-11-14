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
        Schema::create('swipes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('swiper_user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('swiper_item_id')->constrained('items')->onDelete('cascade');
            $table->foreignId('swiped_on_item_id')->constrained('items')->onDelete('cascade');
            $table->enum('action', ['like', 'dislike']);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('swipes');
    }
};
