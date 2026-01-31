<?php

namespace App\Modules\Projects\Controllers\Viewer;

use App\Http\Controllers\Controller;
use App\Modules\Projects\Models\Project;

class ProjectViewerController extends Controller
{
    public function index()
    {
        return response()->json(
            Project::visible()->paginate(10)
        );
    }

    public function show($id)
    {
        $project = Project::visible()->findOrFail($id);

        return response()->json($project);
    }
}
