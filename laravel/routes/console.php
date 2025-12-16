<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// SECURITY FIX: Reset expired location suggestions after 48 hours
// (MASTER_ARCHITECTURE.md Issue #4: Location Deadlock)
Schedule::command('swaps:reset-expired-locations')->hourly();
