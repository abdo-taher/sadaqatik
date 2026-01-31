<?php
namespace App\Modules\Allocation\Presentation\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Modules\Allocation\Application\Commands\CreateAllocationCommand;
use App\Modules\Allocation\Application\Handlers\CreateAllocationHandler;
use App\Modules\Allocation\Domain\ValueObjects\AllocationAmount;

/**
 * @OA\PathItem()
 */
final class AllocationController extends Controller
{
    /**
     * @OA\Post(
     *     path="/api/allocation/create",
     *     summary="Create Allocation for a donation",
     *     tags={"Allocation"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="donation_id", type="string", format="uuid"),
     *             @OA\Property(property="project_id", type="string", format="uuid"),
     *             @OA\Property(property="committee_id", type="string", format="uuid"),
     *             @OA\Property(property="amount", type="number"),
     *             @OA\Property(property="currency", type="string")
     *         )
     *     ),
     *     @OA\Response(response=200, description="Allocation created successfully")
     * )
     */
    public function create(Request $request, CreateAllocationHandler $handler): JsonResponse
    {
        $request->validate([
            'donation_id' => 'required|uuid',
            'project_id' => 'required|uuid',
            'committee_id' => 'required|uuid',
            'amount' => 'required|numeric|min:1',
            'currency' => 'required|string|size:3',
        ]);

        $command = new CreateAllocationCommand(
            $request->donation_id,
            $request->project_id,
            new AllocationAmount((float)$request->amount, $request->currency),
            $request->committee_id
        );

        $handler->handle($command);

        return response()->json(['success' => true, 'message' => 'Allocation created successfully']);
    }
}