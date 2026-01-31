#!/bin/bash

set -e

MODULE_PATH="app/Modules/Projects"

echo "🚀 Creating Projects Module..."

# =========================
# Directories
# =========================
mkdir -p $MODULE_PATH/{Models,Controllers/Viewer,Controllers/Admin,Routes,Database/Migrations,Providers}

# =========================
# Model
# =========================
cat <<'PHP' > $MODULE_PATH/Models/Project.php
<?php

namespace App\Modules\Projects\Models;

use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
    protected $fillable = [
        'organization_id',
        'title',
        'description',
        'target_amount',
        'current_amount',
        'status',
        'is_public',
    ];

    /* ================= Relations ================= */

    public function organization()
    {
        return $this->belongsTo(\App\Modules\Organizations\Models\Organization::class);
    }

    /* ================= Scopes ================= */

    public function scopePublic($query)
    {
        return $query->where('is_public', true);
    }

    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeVisible($query)
    {
        return $query->public()->active();
    }
}
PHP

# =========================
# Migration
# =========================
TIMESTAMP=$(date +%Y_%m_%d_%H%M%S)

cat <<PHP > $MODULE_PATH/Database/Migrations/${TIMESTAMP}_create_projects_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('projects', function (Blueprint \$table) {
            \$table->id();

            \$table->foreignId('organization_id')
                ->constrained()
                ->cascadeOnDelete();

            \$table->string('title');
            \$table->text('description')->nullable();

            \$table->decimal('target_amount', 12, 2);
            \$table->decimal('current_amount', 12, 2)->default(0);

            \$table->enum('status', ['draft', 'active', 'completed', 'archived'])
                ->default('draft');

            \$table->boolean('is_public')->default(false);

            \$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('projects');
    }
};
PHP

# =========================
# Viewer Controller
# =========================
cat <<'PHP' > $MODULE_PATH/Controllers/Viewer/ProjectViewerController.php
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
PHP

# =========================
# Routes
# =========================
cat <<'PHP' > $MODULE_PATH/Routes/viewer.php
<?php

use Illuminate\Support\Facades\Route;
use App\Modules\Projects\Controllers\Viewer\ProjectViewerController;

Route::prefix('projects')->group(function () {
    Route::get('/', [ProjectViewerController::class, 'index']);
    Route::get('{id}', [ProjectViewerController::class, 'show']);
});
PHP

# =========================
# Service Provider
# =========================
cat <<'PHP' > $MODULE_PATH/Providers/ProjectServiceProvider.php
<?php

namespace App\Modules\Projects\Providers;

use Illuminate\Support\ServiceProvider;

class ProjectServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        $this->loadRoutesFrom(__DIR__ . '/../Routes/viewer.php');
        $this->loadMigrationsFrom(__DIR__ . '/../Database/Migrations');
    }
}
PHP

# =========================
# Register Provider
# =========================
PROVIDERS_FILE="config/app.php"

if ! grep -q "ProjectServiceProvider" "$PROVIDERS_FILE"; then
    sed -i "/providers => \[/a\\
        App\\\\Modules\\\\Projects\\\\Providers\\\\ProjectServiceProvider::class," $PROVIDERS_FILE
fi

echo "✅ Projects Module created successfully!"
echo "➡️ Run: php artisan migrate"
