<?php
namespace App\Modules\Allocation\Application\Commands;
class CreateAllocationCommand {
    public function __construct(public readonly int $donationId,public readonly int $projectId,public readonly float $amount,public readonly string $allocatedBy) {}
}
