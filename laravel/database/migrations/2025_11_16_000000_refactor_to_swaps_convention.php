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
        // Rename the 'trades' table (which was previously 'matches') to 'swaps'
        if (Schema::hasTable('trades') && !Schema::hasTable('swaps')) {
            Schema::rename('trades', 'swaps');
        }

        // Rename the 'trade_chats' table back to 'messages'
        if (Schema::hasTable('trade_chats') && !Schema::hasTable('messages')) {
            Schema::rename('trade_chats', 'messages');
        }

        // Correct the column naming in the 'messages' table
        if (Schema::hasTable('messages')) {
            Schema::table('messages', function (Blueprint $table) {
                if (Schema::hasColumn('messages', 'trade_id') && !Schema::hasColumn('messages', 'swap_id')) {
                    $table->renameColumn('trade_id', 'swap_id');
                }
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Revert the column name in 'messages'
        if (Schema::hasTable('messages')) {
            Schema::table('messages', function (Blueprint $table) {
                if (Schema::hasColumn('messages', 'swap_id') && !Schema::hasColumn('messages', 'trade_id')) {
                    $table->renameColumn('swap_id', 'trade_id');
                }
            });
        }
        
        // Revert table renames
        if (Schema::hasTable('messages') && !Schema::hasTable('trade_chats')) {
            Schema::rename('messages', 'trade_chats');
        }
        if (Schema::hasTable('swaps') && !Schema::hasTable('trades')) {
            Schema::rename('swaps', 'trades');
        }
    }
};
