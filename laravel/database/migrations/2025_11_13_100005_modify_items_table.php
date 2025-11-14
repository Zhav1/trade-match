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
        Schema::table('items', function (Blueprint $table) {
            $table->foreignId('category_id')->nullable()->constrained()->onDelete('set null')->after('user_id');
            $table->enum('condition', ['new', 'like_new', 'good', 'fair'])->default('good')->after('description');
            $table->decimal('estimated_value', 12, 2)->nullable()->after('condition');
            $table->string('currency', 3)->default('IDR')->after('estimated_value');
            $table->string('location_city')->nullable()->after('currency');
            $table->text('wants_description')->nullable();
            $table->enum('status', ['active', 'pending', 'traded', 'hidden'])->default('active')->change();
        });

        if (Schema::hasColumn('items', 'lat')) {
            Schema::table('items', function (Blueprint $table) {
                $table->renameColumn('lat', 'location_lat');
            });
        }
        if (Schema::hasColumn('items', 'lng')) {
            Schema::table('items', function (Blueprint $table) {
                $table->renameColumn('lng', 'location_lon');
            });
        }

        $columnsToDrop = ['cover_image_path', 'photo_url'];
        foreach ($columnsToDrop as $column) {
            if (Schema::hasColumn('items', $column)) {
                Schema::table('items', function (Blueprint $table) use ($column) {
                    $table->dropColumn($column);
                });
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('items', function (Blueprint $table) {
            $table->dropForeign(['category_id']);
            $table->dropColumn(['category_id', 'condition', 'estimated_value', 'currency', 'location_city', 'wants_description']);
            $table->string('status')->default('active')->change();
        });

        if (Schema::hasColumn('items', 'location_lat')) {
            Schema::table('items', function (Blueprint $table) {
                $table->renameColumn('location_lat', 'lat');
            });
        }
        if (Schema::hasColumn('items', 'location_lon')) {
            Schema::table('items', function (Blueprint $table) {
                $table->renameColumn('location_lon', 'lng');
            });
        }

        Schema::table('items', function (Blueprint $table) {
            $table->string('cover_image_path')->nullable();
            $table->string('photo_url')->nullable();
        });
    }
};
