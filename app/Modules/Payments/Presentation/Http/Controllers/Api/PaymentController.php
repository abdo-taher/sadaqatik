<?php
namespace App\Modules\Payments\Presentation\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Modules\Payments\Application\Commands\InitiatePaymentCommand;
use App\Modules\Payments\Application\Handlers\InitiatePaymentHandler;
use App\Modules\Payments\Domain\Entities\Payment;
use App\Modules\Payments\Domain\ValueObjects\Money;

/**
 * @OA\PathItem()
 */
final class PaymentController extends Controller
{
    /**
     * @OA\Post(
     *     path="/api/payments/initiate",
     *     summary="Initiate a payment",
     *     tags={"Payments"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="donation_id", type="string", format="uuid"),
     *             @OA\Property(property="amount", type="number"),
     *             @OA\Property(property="currency", type="string")
     *         )
     *     ),
     *     @OA\Response(response=200, description="Payment initiated successfully")
     * )
     */
    public function initiate(Request $request, InitiatePaymentHandler $handler): JsonResponse
    {
        $request->validate([
            'donation_id' => 'required|uuid',
            'amount' => 'required|numeric|min:1',
            'currency' => 'required|string|size:3',
        ]);

        $payment = new Payment(
            $request->donation_id,
            new Money((float)$request->amount, $request->currency)
        );

        $handler->handle(new InitiatePaymentCommand($payment));

        return response()->json(['success' => true, 'message' => 'Payment initiated successfully']);
    }
}
