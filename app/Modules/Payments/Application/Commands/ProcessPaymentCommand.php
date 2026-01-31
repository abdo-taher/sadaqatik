<?php
namespace App\Modules\Payments\Application\Commands;
class ProcessPaymentCommand {
    public function __construct(public readonly int $donationId, public readonly float $amount, public readonly string $currency, public readonly string $paymentMethod) {}
}
