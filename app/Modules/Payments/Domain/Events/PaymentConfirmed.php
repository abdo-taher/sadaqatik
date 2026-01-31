<?php
namespace App\Modules\Payments\Domain\Events;

use App\Modules\Payments\Domain\Entities\Payment;

final class PaymentConfirmed
{
    public Payment $payment;
    public function __construct(Payment $payment) { $this->payment = $payment; }
}
