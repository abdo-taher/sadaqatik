#!/bin/bash

set -e

echo "🚀 Creating Viewer / Explorer Dashboard..."

# ==============================
# Directories
# ==============================
mkdir -p app/Http/Controllers/Viewer
mkdir -p routes/viewer

# ==============================
# Home Controller
# ==============================
cat <<'PHP' > app/Http/Controllers/Viewer/HomeController.php
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
PHP

# ==============================
# Organizations Viewer Controller
# ==============================
cat <<'PHP' > app/Http/Controllers/Viewer/OrganizationController.php
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
PHP

# ==============================
# Projects Viewer Controller
# ==============================
cat <<'PHP' > app/Http/Controllers/Viewer/ProjectController.php
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
PHP

# ==============================
# Viewer Routes
# ==============================
cat <<'PHP' > routes/viewer/api.php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Viewer\HomeController;
use App\Http\Controllers\Viewer\OrganizationController;
use App\Http\Controllers\Viewer\ProjectController;

Route::prefix('viewer')->group(function () {

    Route::get('/home', [HomeController::class, 'index']);

    Route::get('/organizations', [OrganizationController::class, 'index']);
    Route::get('/organizations/{id}', [OrganizationController::class, 'show']);
    Route::get('/organizations/{id}/projects', [OrganizationController::class, 'projects']);

    Route::get('/projects', [ProjectController::class, 'index']);
    Route::get('/projects/{id}', [ProjectController::class, 'show']);
});
PHP

# ==============================
# Register Routes
# ==============================
ROUTES_FILE="routes/api.php"

if ! grep -q "viewer/api.php" "$ROUTES_FILE"; then
    echo "require __DIR__.'/viewer/api.php';" >> $ROUTES_FILE
fi

echo "✅ Viewer / Explorer Dashboard Ready!"
echo "➡️ Available under /api/viewer/*"
