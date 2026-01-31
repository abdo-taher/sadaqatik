<?php
namespace App\Modules\Payments\Domain\Events;

use App\Modules\Payments\Domain\Entities\Payment;

final class PaymentInitiated
{
    public Payment $payment;
    public function __construct(Payment $payment) { $this->payment = $payment; }
}
