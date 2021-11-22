<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Service;
use App\Models\Call;


class StatusController extends Controller
{
    public function show(Request $request)
    {
        // Show all the services, and whether they have been called yet, and whether they are in a good or bad state
        return response()->json(Service::with('latestCall')->orderBy('key', 'asc')->get());
    }
}
