<?php

namespace App\Modules\Organizations\Controllers\Viewer;

use App\Http\Controllers\Controller;
use App\Modules\Organizations\Models\Organization;

class OrganizationViewerController extends Controller
{
    public function index()
    {
        return response()->json(
            Organization::visible()->paginate(10)
        );
    }

    public function show($id)
    {
        $organization = Organization::visible()
            ->with('projects')
            ->findOrFail($id);

        return response()->json($organization);
    }
}
