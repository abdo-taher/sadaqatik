<?php
namespace App\Modules\Payments\Controllers;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Modules\Payments\Application\Commands\ProcessPaymentCommand;
use App\Modules\Payments\Application\Handlers\ProcessPaymentHandler;

class PaymentController extends Controller {
    public function pay(Request $request, ProcessPaymentHandler $handler){
        $data=$request->validate([
            'donation_id'=>'required|exists:donations,id',
            'amount'=>'required|numeric|min:1',
            'currency'=>'required|string|size:3',
            'payment_method'=>'required|string',
        ]);
        $payment=$handler->handle(new ProcessPaymentCommand($data['donation_id'],$data['amount'],$data['currency'],$data['payment_method']));
        return response()->json(['success'=>true,'payment_id'=>$payment->id,'status'=>$payment->status]);
    }
}
