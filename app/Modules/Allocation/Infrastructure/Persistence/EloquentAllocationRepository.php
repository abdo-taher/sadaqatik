<?php
namespace App\Modules\Allocation\Infrastructure\Persistence;

use App\Modules\Allocation\Domain\Entities\Allocation;
use Illuminate\Support\Facades\DB;

final class EloquentAllocationRepository
{
    public function save(Allocation $allocation): void
    {
        DB::table('allocations')->insert([
            'id' => $allocation->id,
            'donation_id' => $allocation->donationId,
            'project_id' => $allocation->projectId,
            'amount' => $allocation->amount->amount,
            'currency' => $allocation->amount->currency,
            'committee_id' => $allocation->committeeId,
            'created_at' => $allocation->createdAt,
        ]);
    }
}