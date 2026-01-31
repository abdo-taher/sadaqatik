#!/bin/bash

echo "🛠️ Setting up Swagger for Sadaqatik Modular Project..."

# =========================
# 1️⃣ Shared Swagger Controller
# =========================
SWAGGER_CONTROLLER="app/Modules/Shared/Presentation/Http/Controllers/SwaggerController.php"

mkdir -p $(dirname $SWAGGER_CONTROLLER)

cat <<'PHP' > $SWAGGER_CONTROLLER
<?php

namespace App\Modules\Shared\Presentation\Http\Controllers;

use App\Http\Controllers\Controller;

/**
 * @OA\Info(
 *     version="1.0.0",
 *     title="Sadaqatik API",
 *     description="API Documentation for Sadaqatik Project"
 * )
 *
 * @OA\Server(
 *     url="http://localhost/api",
 *     description="Local server"
 * )
 *
 * @OA\Tag(
 *     name="Donor",
 *     description="Operations related to Donor and Donations"
 * )
 *
 * @OA\Tag(
 *     name="Projects",
 *     description="Operations related to Projects"
 * )
 */
final class SwaggerController extends Controller
{
    // فقط Bootstrap Swagger Info + Tags
}
PHP

echo "✅ SwaggerController created at $SWAGGER_CONTROLLER"

# =========================
# 2️⃣ Add @OA\PathItem() to ProjectController
# =========================
PROJECT_CONTROLLER="app/Modules/Donations/Presentation/Http/Controllers/Api/ProjectController.php"

if [ -f "$PROJECT_CONTROLLER" ]; then
    sed -i '1i /**\n * @OA\PathItem()\n */' $PROJECT_CONTROLLER
    echo "✅ Added @OA\PathItem() to ProjectController"
else
    echo "⚠️ ProjectController not found, skipping..."
fi

# =========================
# 3️⃣ Add @OA\PathItem() to DonorController
# =========================
DONOR_CONTROLLER="app/Modules/Donations/Presentation/Http/Controllers/Api/DonorController.php"

if [ -f "$DONOR_CONTROLLER" ]; then
    sed -i '1i /**\n * @OA\PathItem()\n */' $DONOR_CONTROLLER
    echo "✅ Added @OA\PathItem() to DonorController"
else
    echo "⚠️ DonorController not found, skipping..."
fi

# =========================
# 4️⃣ Update L5-Swagger config
# =========================
CONFIG_FILE="config/l5-swagger.php"

if [ -f "$CONFIG_FILE" ]; then
    sed -i "s|base_path('app')|base_path('app/Modules')|g" $CONFIG_FILE
    echo "✅ L5-Swagger config updated to scan app/Modules"
else
    echo "⚠️ config/l5-swagger.php not found, make sure L5-Swagger is installed"
fi

# =========================
# 5️⃣ Generate Swagger Docs
# =========================
echo "📌 Generating Swagger documentation..."
php artisan l5-swagger:generate

echo "✅ Swagger setup completed! Open http://localhost/api/documentation"
