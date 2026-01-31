<?php
namespace App\Modules\Payments\Domain\Events;

use App\Modules\Payments\Domain\Entities\Payment;

final class BeneficiaryPaid
{
    public Payment $payment;
    public function __construct(Payment $payment) { $this->payment = $payment; }
}
