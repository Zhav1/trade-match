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
            if (Schema::hasColumn('matches', 'user_a_id')) {
                $table->dropForeign(['user_a_id']);
            }
            if (Schema::hasColumn('matches', 'user_b_id')) {
                $table->dropForeign(['user_b_id']);
            }
            $columnsToDrop = ['user_a_id', 'user_b_id', 'confirm_user1', 'confirm_user2'];
            $existingColumns = Schema::getColumnListing('matches');
            $columnsToDrop = array_intersect($columnsToDrop, $existingColumns);

            if(!empty($columnsToDrop)) {
                $table->dropColumn($columnsToDrop);
            }

            $table->enum('status', ['matched', 'chatting', 'trade_complete'])->default('matched')->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('matches', function (Blueprint $table) {
            $table->foreignId('user_a_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('user_b_id')->constrained('users')->onDelete('cascade');
            $table->boolean('confirm_user1')->default(false);
            $table->boolean('confirm_user2')->default(false);
            $table->string('status')->default('active')->change();
        });
    }
};
