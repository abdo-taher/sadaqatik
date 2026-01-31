<?php

namespace App\Modules\Donations\Presentation\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Modules\Donations\Application\Commands\CreateDonationCommand;
use App\Modules\Donations\Application\Handlers\CreateDonationHandler;
use App\Modules\Donations\Domain\Entities\Donation;
use App\Modules\Donations\Domain\ValueObjects\Money;
use Illuminate\Support\Str;

/**
 * @OA\PathItem()
 */
final class DonorController extends Controller
{
    /**
     * @OA\Post(
     *     path="/api/donor/donate",
     *     summary="Create a donation",
     *     tags={"Donor"},
     *     ...
     * )
     */
    public function donate(Request $request, CreateDonationHandler $handler): JsonResponse
    {
        $request->validate([
            'donor_id' => 'required|uuid',
            'project_id' => 'required|uuid',
            'amount' => 'required|numeric|min:1',
            'currency' => 'required|string|size:3',
        ]);

        $donation = new Donation(
            id: (string)Str::uuid(),
            donorName: $request->input('donor_name'),
            amount: new Money((float)$request->amount, $request->currency),
            projectId: $request->project_id,
            committeeId: $request->input('committee_id'),
        );

        $handler->handle(new CreateDonationCommand($donation));

        return response()->json([
            'success' => true,
            'message' => 'Donation created successfully',
            'data' => [
                'donation_id' => $donation->id,
                'project_id' => $donation->projectId,
                'amount' => $donation->amount->amount,
                'currency' => $donation->amount->currency,
            ],
        ]);
    }
}
