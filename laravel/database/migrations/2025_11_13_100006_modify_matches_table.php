<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Simply skip this migration if matches table doesn't exist
        if (!Schema::hasTable('matches')) {
            return;
        }

        $existingColumns = DB::select("SHOW COLUMNS FROM matches");
        $columnNames = array_map(fn($col) => $col->Field, $existingColumns);
        
        Schema::table('matches', function (Blueprint $table) use ($columnNames) {
            // Drop foreign keys if the columns exist
            if (in_array('user_a_id', $columnNames)) {
                try {
                    $table->dropForeign('matches_user_a_id_foreign');
                } catch (\Exception $e) {
                    // Foreign key doesn't exist, continue
                }
            }
            
            if (in_array('user_b_id', $columnNames)) {
                try {
                    $table->dropForeign('matches_user_b_id_foreign');
                } catch (\Exception $e) {
                    // Foreign key doesn't exist, continue
                }
            }
        });

        // Drop columns one by one
        foreach (['user_a_id', 'user_b_id', 'confirm_user1', 'confirm_user2'] as $column) {
            if (in_array($column, $columnNames)) {
                try {
                    DB::statement("ALTER TABLE matches DROP COLUMN $column");
                } catch (\Exception $e) {
                    // Column doesn't exist or has constraints
                }
            }
        }

        // Change status enum if exists
        if (in_array('status', $columnNames)) {
            try {
                DB::statement("ALTER TABLE matches MODIFY COLUMN status ENUM('matched', 'chatting', 'trade_complete') DEFAULT 'matched'");
            } catch (\Exception $e) {
                // Can't change status column
            }
        }
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
