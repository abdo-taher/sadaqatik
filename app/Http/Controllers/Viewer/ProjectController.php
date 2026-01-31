<?php

namespace App\Http\Controllers\Viewer;

use App\Http\Controllers\Controller;
use App\Modules\Projects\Models\Project;

class ProjectController extends Controller
{
    public function index()
    {
        return Project::visible()->paginate(10);
    }

    public function show($id)
    {
        return Project::visible()
            ->with('organization')
            ->findOrFail($id);
    }
}
