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
        Schema::table('users', function (Blueprint $table) {
            $table->string('profile_picture_url')->nullable()->after('password');
            $table->string('default_location_city')->nullable()->after('profile_picture_url');
            $table->decimal('rating', 3, 2)->nullable();
        });

        // Rename columns if they exist
        if (Schema::hasColumn('users', 'lat')) {
            Schema::table('users', function (Blueprint $table) {
                $table->renameColumn('lat', 'default_lat');
            });
        }
        if (Schema::hasColumn('users', 'lng')) {
            Schema::table('users', function (Blueprint $table) {
                $table->renameColumn('lng', 'default_lon');
            });
        }

        // Drop columns if they exist
        $columnsToDrop = ['email_verified_at', 'fcm_token', 'remember_token', 'phone'];
        foreach ($columnsToDrop as $column) {
            if (Schema::hasColumn('users', 'fcm_token')) {
                Schema::table('users', function (Blueprint $table) use ($column) {
                    $table->dropColumn('fcm_token');
                });
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['profile_picture_url', 'default_location_city', 'rating']);
        });

        // Rename columns back
        if (Schema::hasColumn('users', 'default_lat')) {
            Schema::table('users', function (Blueprint $table) {
                $table->renameColumn('default_lat', 'lat');
            });
        }
        if (Schema::hasColumn('users', 'default_lon')) {
            Schema::table('users', function (Blueprint $table) {
                $table->renameColumn('default_lon', 'lng');
            });
        }

        Schema::table('users', function (Blueprint $table) {
            $table->timestamp('email_verified_at')->nullable();
            $table->string('fcm_token')->nullable();
            $table->rememberToken();
            $table->string('phone')->nullable();
        });
    }
};
