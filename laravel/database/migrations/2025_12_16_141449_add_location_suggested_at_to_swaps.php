<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * SECURITY FIX: Adds timestamp to track location suggestion timeout
     * (MASTER_ARCHITECTURE.md Issue #4: Location Deadlock)
     */
    public function up(): void
    {
        Schema::table('swaps', function (Blueprint $table) {
            $table->timestamp('location_suggested_at')->nullable()->after('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('swaps', function (Blueprint $table) {
            $table->dropColumn('location_suggested_at');
        });
    }
};
