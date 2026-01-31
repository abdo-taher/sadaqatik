<?php


namespace App\Modules\Donations\Presentation\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;


/**
 * @OA\PathItem()
 */
final class ProjectController extends Controller
{
    /**
     * @OA\Get(
     *     path="/api/donor/projects",
     *     summary="Get active projects",
     *     tags={"Donor"},
     *     @OA\Response(
     *         response=200,
     *         description="List of active projects",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean"),
     *             @OA\Property(
     *                 property="data",
     *                 type="array",
     *                 @OA\Items(
     *                     @OA\Property(property="id", type="string", format="uuid"),
     *                     @OA\Property(property="name", type="string"),
     *                     @OA\Property(property="description", type="string"),
     *                     @OA\Property(property="target_amount", type="number"),
     *                     @OA\Property(property="collected_amount", type="number"),
     *                     @OA\Property(property="currency", type="string")
     *                 )
     *             )
     *         )
     *     )
     * )
     */
    public function index(): JsonResponse
    {
        $projects = DB::table('projects')
            ->where('status', 'active')
            ->select('id', 'name', 'description', 'target_amount', 'collected_amount', 'currency')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $projects,
        ]);
    }
}
