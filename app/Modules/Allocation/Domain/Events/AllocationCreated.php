<?php
namespace App\Modules\Allocation\Domain\Events;
class AllocationCreated {
    public function __construct(public readonly int $allocationId,public readonly int $donationId,public readonly int $projectId,public readonly float $amount) {}
}
