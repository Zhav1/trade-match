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
        Schema::rename('matches', 'trades');
        Schema::rename('messages', 'trade_chats');

        Schema::table('trade_chats', function (Blueprint $table) {
            $table->renameColumn('match_id', 'trade_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('trade_chats', function (Blueprint $table) {
            $table->renameColumn('trade_id', 'match_id');
        });

        Schema::rename('trade_chats', 'messages');
        Schema::rename('trades', 'matches');
    }
};
