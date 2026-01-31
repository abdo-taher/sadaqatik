#!/bin/bash

set -e

MODULE_PATH="app/Modules/Organizations"

echo "🚀 Creating Organizations Module..."

# =========================
# Directories
# =========================
mkdir -p $MODULE_PATH/{Models,Controllers/Viewer,Controllers/Admin,Routes,Database/Migrations,Providers}

# =========================
# Model
# =========================
cat <<'PHP' > $MODULE_PATH/Models/Organization.php
<?php

namespace App\Modules\Organizations\Models;

use Illuminate\Database\Eloquent\Model;

class Organization extends Model
{
    protected $fillable = [
        'name',
        'description',
        'license_number',
        'status',
        'is_public',
    ];

    /* ================= Relations ================= */

    public function projects()
    {
        return $this->hasMany(\App\Modules\Projects\Models\Project::class);
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

cat <<PHP > $MODULE_PATH/Database/Migrations/${TIMESTAMP}_create_organizations_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('organizations', function (Blueprint \$table) {
            \$table->id();

            \$table->string('name');
            \$table->text('description')->nullable();

            \$table->string('license_number')->unique();

            \$table->enum('status', ['pending', 'active', 'suspended'])
                ->default('pending');

            \$table->boolean('is_public')->default(false);

            \$table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('organizations');
    }
};
PHP

# =========================
# Viewer Controller
# =========================
cat <<'PHP' > $MODULE_PATH/Controllers/Viewer/OrganizationViewerController.php
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
PHP

# =========================
# Routes
# =========================
cat <<'PHP' > $MODULE_PATH/Routes/viewer.php
<?php

use Illuminate\Support\Facades\Route;
use App\Modules\Organizations\Controllers\Viewer\OrganizationViewerController;

Route::prefix('organizations')->group(function () {
    Route::get('/', [OrganizationViewerController::class, 'index']);
    Route::get('{id}', [OrganizationViewerController::class, 'show']);
});
PHP

# =========================
# Service Provider
# =========================
cat <<'PHP' > $MODULE_PATH/Providers/OrganizationServiceProvider.php
<?php

namespace App\Modules\Organizations\Providers;

use Illuminate\Support\ServiceProvider;

class OrganizationServiceProvider extends ServiceProvider
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

if ! grep -q "OrganizationServiceProvider" "$PROVIDERS_FILE"; then
    sed -i "/providers => \[/a\\
        App\\\\Modules\\\\Organizations\\\\Providers\\\\OrganizationServiceProvider::class," $PROVIDERS_FILE
fi

echo "✅ Organizations Module created successfully!"
echo "➡️ Run: php artisan migrate"
