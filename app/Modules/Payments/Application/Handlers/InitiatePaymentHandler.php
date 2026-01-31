<?php
namespace App\Modules\Payments\Application\Handlers;

use App\Modules\Payments\Application\Commands\InitiatePaymentCommand;
use App\Modules\Payments\Domain\Events\PaymentInitiated;
use Illuminate\Support\Facades\Event;

final class InitiatePaymentHandler
{
    public function handle(InitiatePaymentCommand $command): void
    {
        Event::dispatch(new PaymentInitiated($command->payment));
    }
}
