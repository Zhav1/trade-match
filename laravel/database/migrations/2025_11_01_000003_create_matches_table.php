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
        Schema::create('matches', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_a_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('user_b_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('item_a_id')->constrained('items')->onDelete('cascade');
            $table->foreignId('item_b_id')->constrained('items')->onDelete('cascade');
            $table->string('status')->default('active');
            $table->timestamps();

            // Prevent duplicate matches between same users/items
            $table->unique(['user_a_id', 'user_b_id', 'item_a_id', 'item_b_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('matches');
    }
};