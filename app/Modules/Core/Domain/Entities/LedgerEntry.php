<?php

namespace App\Modules\Core\Domain\Entities;

use App\Modules\Core\Domain\ValueObjects\Money;
use Illuminate\Support\Str;

final class LedgerEntry
{
    public string $id;
    public string $accountId;
    public Money $amount;
    public string $type; // debit / credit
    public string $description;
    public \DateTimeImmutable $createdAt;

    public function __construct(
        string $accountId,
        Money $amount,
        string $type,
        string $description
    ) {
        $this->id = Str::uuid()->toString();
        $this->accountId = $accountId;
        $this->amount = $amount;
        $this->type = $type;
        $this->description = $description;
        $this->createdAt = new \DateTimeImmutable();
    }
}
