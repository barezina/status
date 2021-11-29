<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Service;
use App\Models\Call;
use Carbon\Carbon;
use Log;
use Cache;
use Illuminate\Support\Facades\Redis;

class StatusController extends Controller
{
    public function show(Request $request)
    {
        // Get all services
        $serviceKeys = Redis::keys('*service_*');

        // Calculate if they are good or bad

        $now = Carbon::now()->timestamp;
        $services = [];

        foreach ($serviceKeys as $serviceKey) {

            $serviceKey = str_replace('laravel_database_', '', $serviceKey);
            $service = unserialize(Redis::get($serviceKey));

            $service->created_at_unix = $service->timestamp;
            $service->latestCall = new Call;
            $service->latestCall->created_at_unix = $service->timestamp;
            $service->latestCall->created_at_human = Carbon::parse($service->latestCall->created_at)->diffForHumans();
            $service->next_ping_due = $service->latestCall->created_at_unix + $service->duration;
            $service->next_ping_due_human = Carbon::createFromTimestamp($service->next_ping_due)->diffForHumans();

            if ($service->next_ping_due < $now) {
                $service->status = 'bad';
            } else {
                $service->status = 'good';
            }

            $services[] = $service;

        }

        return response()->json($services, 200);
    }
}
