<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Log;
use App\Models\Service;
use App\Models\Call;

class CallController extends Controller
{
    public function notify($serviceKey, Request $request)
    {
        return response()->json([], 200);
        
        if ($request->has('duration') && $request->has('description')) {

            // Create a new service if we have all the stuff, and also log the call

            $duration = $request->duration;
            $description = $request->description;

            $service = Service::where('key', $serviceKey)->firstOrNew();
            $service->key = $serviceKey;
            $service->duration = $duration;
            $service->name = $description;
            $service->save();

            $newCall = new Call;
            $newCall->service_id = $service->id;
            $newCall->save();

            return response()->json($newCall, 201);

        } else {

            // Attempt to find this key and log a call.
            $service = Service::where('key', $serviceKey)->firstOrFail();

            $newCall = new Call;
            $newCall->service_id = $service->id;
            $newCall->save();

            return response()->json($newCall, 201);
        }
    }
}
