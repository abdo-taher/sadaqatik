<?php
namespace App\Modules\Payments\Application\Commands;

use App\Modules\Payments\Domain\Entities\Payment;

final class InitiatePaymentCommand
{
    public Payment $payment;
    public function __construct(Payment $payment) { $this->payment = $payment; }
}
