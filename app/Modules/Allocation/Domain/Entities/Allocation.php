<?php
namespace App\Modules\Allocation\Domain\Entities;

use App\Modules\Allocation\Domain\ValueObjects\AllocationAmount;
use Illuminate\Support\Str;

final class Allocation
{
    public string $id;
    public string $donationId;
    public string $projectId;
    public AllocationAmount $amount;
    public string $committeeId;
    public \DateTimeImmutable $createdAt;

    public function __construct(
        string $donationId,
        string $projectId,
        AllocationAmount $amount,
        string $committeeId
    ) {
        $this->id = Str::uuid()->toString();
        $this->donationId = $donationId;
        $this->projectId = $projectId;
        $this->amount = $amount;
        $this->committeeId = $committeeId;
        $this->createdAt = new \DateTimeImmutable();
    }
}