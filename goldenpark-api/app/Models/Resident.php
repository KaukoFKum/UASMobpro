<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Resident extends Model
{
    protected $fillable = [
        'nama',
        'blok',
        'nomor_rumah',
        'no_hp',
        'tanggal_masuk',
        'status'
    ];
}
