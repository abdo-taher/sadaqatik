<?php
namespace App\Modules\Allocation\Domain\Events;

use App\Modules\Allocation\Domain\Entities\Allocation;

final class AllocationCreated
{
    public Allocation $allocation;

    public function __construct(Allocation $allocation)
    {
        $this->allocation = $allocation;
    }
}