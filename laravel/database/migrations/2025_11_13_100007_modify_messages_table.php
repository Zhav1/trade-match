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
        Schema::table('messages', function (Blueprint $table) {
            $table->renameColumn('user_id', 'sender_user_id');
            $table->renameColumn('content', 'message_text');
        });

        if (Schema::hasColumn('messages', 'updated_at')) {
            Schema::table('messages', function (Blueprint $table) {
                $table->dropColumn('updated_at');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('messages', function (Blueprint $table) {
            $table->renameColumn('sender_user_id', 'user_id');
            $table->renameColumn('message_text', 'content');
            $table->timestamp('updated_at')->nullable();
        });
    }
};
