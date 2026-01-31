<?php
namespace App\Modules\Payments\Domain\Events;
class PaymentConfirmed {
    public function __construct(public readonly int $paymentId, public readonly int $donationId, public readonly float $amount, public readonly string $currency, public readonly string $paymentMethod) {}
}
