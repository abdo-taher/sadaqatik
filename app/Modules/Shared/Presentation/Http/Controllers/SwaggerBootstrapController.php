<?php

namespace App\Modules\Shared\Presentation\Http\Controllers;

use App\Http\Controllers\Controller;

/**
 * @OA\Info(title="Sadaqatik API", version="1.0")
 * @OA\Server(url="http://localhost/api")
 *
 * @OA\PathItem(path="/dummy")  <-- PathItem صالح لإزالة الخطأ
 */
final class SwaggerBootstrapController extends Controller
{
    /**
     * @OA\Get(
     *     path="/dummy",
     *     summary="Bootstrap path to satisfy Swagger-PHP",
     *     tags={"Bootstrap"},
     *     @OA\Response(response=200, description="OK")
     * )
     */
    public function dummy() {}
}
