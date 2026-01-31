<?php

namespace App\Http\Controllers\Viewer;

use App\Http\Controllers\Controller;
use App\Modules\Organizations\Models\Organization;
use App\Modules\Projects\Models\Project;

class OrganizationController extends Controller
{
    public function index()
    {
        return Organization::visible()
            ->withCount('projects')
            ->paginate(10);
    }

    public function show($id)
    {
        return Organization::visible()->findOrFail($id);
    }

    public function projects($id)
    {
        return Project::visible()
            ->where('organization_id', $id)
            ->paginate(10);
    }
}
