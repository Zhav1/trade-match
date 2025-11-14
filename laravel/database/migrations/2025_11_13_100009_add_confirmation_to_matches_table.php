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
        Schema::table('matches', function (Blueprint $table) {
            $table->boolean('item_a_owner_confirmed')->default(false)->after('status');
            $table->boolean('item_b_owner_confirmed')->default(false)->after('item_a_owner_confirmed');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('matches', function (Blueprint $table) {
            $table->dropColumn(['item_a_owner_confirmed', 'item_b_owner_confirmed']);
        });
    }
};
