<?php

namespace App\Http\Controllers\Viewer;

use App\Http\Controllers\Controller;
use App\Modules\Organizations\Models\Organization;
use App\Modules\Projects\Models\Project;

class HomeController extends Controller
{
    public function index()
    {
        return response()->json([
            'featured_organizations' => Organization::visible()
                ->limit(5)
                ->get(['id', 'name']),

            'active_projects' => Project::visible()
                ->limit(5)
                ->get(['id', 'title', 'current_amount', 'target_amount']),
        ]);
    }
}
