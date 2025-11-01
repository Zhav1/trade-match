<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('messages', function (Blueprint $table) {
            $table->string('type')->default('text'); // text, location, location_agreement
            $table->double('lat')->nullable();
            $table->double('lng')->nullable();
            $table->string('location_name')->nullable();
            $table->string('location_address')->nullable();
            $table->boolean('location_agreed_by_user_a')->default(false);
            $table->boolean('location_agreed_by_user_b')->default(false);
        });
    }

    public function down(): void
    {
        Schema::table('messages', function (Blueprint $table) {
            $table->dropColumn([
                'type',
                'lat',
                'lng',
                'location_name',
                'location_address',
                'location_agreed_by_user_a',
                'location_agreed_by_user_b'
            ]);
        });
    }
};