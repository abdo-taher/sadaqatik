<?php
namespace App\Modules\Payments\Application\Handlers;
use App\Modules\Payments\Application\Commands\ProcessPaymentCommand;
use App\Modules\Payments\Models\Payment;
use App\Modules\Payments\Domain\Events\PaymentConfirmed;
use Illuminate\Support\Facades\Event;

class ProcessPaymentHandler{
    public function handle(ProcessPaymentCommand $command): Payment{
        // Here you can integrate external gateway API
        $payment=Payment::create([
            'donation_id'=>$command->donationId,
            'amount'=>$command->amount,
            'currency'=>$command->currency,
            'payment_method'=>$command->paymentMethod,
            'status'=>'confirmed',
        ]);

        Event::dispatch(new PaymentConfirmed($payment->id,$payment->donation_id,$payment->amount,$payment->currency,$payment->payment_method));
        return $payment;
    }
}
