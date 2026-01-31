<?php

namespace App\Modules\Zakat\Presentation\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Zakat\Application\Commands\CalculateZakatCommand;
use App\Modules\Zakat\Application\Handlers\CalculateZakatHandler;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

use App\Modules\Zakat\Domain\ValueObjects\Money;

/**
 * @OA\PathItem()
 */
final class ZakatController extends Controller
{
    /**
     * @OA\Post(
     *     path="/api/zakat/compute",
     *     summary="Compute Zakat for a donation",
     *     tags={"Zakat"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="donation_id", type="string", format="uuid"),
     *             @OA\Property(property="amount", type="number"),
     *             @OA\Property(property="currency", type="string")
     *         )
     *     ),
     *     @OA\Response(response=200, description="Zakat computed successfully")
     * )
     */
    public function compute(Request $request, CalculateZakatHandler $handler): JsonResponse
    {
        $request->validate([
            'donation_id' => 'required|uuid',
            'amount' => 'required|numeric|min:1',
            'currency' => 'required|string|size:3',
        ]);

        $command = new CalculateZakatCommand(
            $request->donation_id,
            new Money((float)$request->amount, $request->currency)
        );

        $handler->handle($command);

        return response()->json([
            'success' => true,
            'message' => 'Zakat computed successfully'
        ]);
    }
}
