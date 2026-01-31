<?php
namespace App\Modules\Payments\Domain\Entities;

use App\Modules\Payments\Domain\ValueObjects\Money;
use Illuminate\Support\Str;

final class Payment
{
    public string $id;
    public string $donationId;
    public Money $amount;
    public string $status; // initiated, confirmed, paid
    public \DateTimeImmutable $createdAt;

    public function __construct(string $donationId, Money $amount)
    {
        $this->id = Str::uuid()->toString();
        $this->donationId = $donationId;
        $this->amount = $amount;
        $this->status = 'initiated';
        $this->createdAt = new \DateTimeImmutable();
    }

    public function markConfirmed(): void { $this->status='confirmed'; }
    public function markPaid(): void { $this->status='paid'; }
}
