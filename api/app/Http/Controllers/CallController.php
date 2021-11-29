<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Log;
use App\Models\Service;
use App\Models\Call;
use Cache;
use Carbon\Carbon;
use Illuminate\Support\Facades\Redis;

class CallController extends Controller
{
    public function notify($serviceKey, Request $request)
    {
        if ($request->has('duration') && $request->has('description')) {

            // Create a new service if we have all required parameters, and also log the call

            $duration = $request->duration;
            $description = $request->description;

            $service = new Service;
            $service->key = $serviceKey;
            $service->duration = $duration;
            $service->name = $description;
            $service->timestamp = Carbon::now()->timestamp;

            Redis::set('service_' . $serviceKey, serialize($service));

            return response()->json($service, 201);
        }
    }
}
