<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Call;

class Service extends Model
{
    use HasFactory;

    public function calls()
    {
        return $this->hasMany(Call::class);
    }

    public function latestCall()
    {
        return $this->hasOne(Call::class)->latest();
    }
}
