<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Service;
use App\Models\Call;
use Carbon\Carbon;
use Log;

class StatusController extends Controller
{
    public function show(Request $request)
    {

        // Get all services

        $services = Service::with('latestCall')->orderBy('key', 'asc')->get();

        // Calculate if they are good or bad

        $now = Carbon::now()->timestamp;

        foreach ($services as $service) {

            $service->created_at_unix = Carbon::parse($service->created_at)->timestamp;
            $service->latestCall->created_at_unix = Carbon::parse($service->latestCall->created_at)->timestamp;
            $service->latestCall->created_at_human = Carbon::parse($service->latestCall->created_at)->diffForHumans();
            $service->next_ping_due = $service->created_at_unix + $service->duration;
            $service->next_ping_due_human = Carbon::createFromTimestamp($service->next_ping_due)->diffForHumans();

            if ($service->next_ping_due < $now) {
                $service->status = 'bad';
            } else {
                $service->status = 'good';
            }

        }

        return response()->json($services, 200);
    }
}
