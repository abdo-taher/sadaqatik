<?php


/**
 * Run with: php add-swagger-pathitem.php
 *
 * This script scans all Controllers in app/Modules and adds @OA\PathItem() if missing
 */

$basePath = __DIR__ . '/app/Modules';

$directoryIterator = new RecursiveIteratorIterator(
    new RecursiveDirectoryIterator($basePath)
);

$controllers = [];
foreach ($directoryIterator as $file) {
    if ($file->isFile() && preg_match('/Controller\.php$/', $file->getFilename())) {
        $controllers[] = $file->getPathname();
    }
}

echo "Found " . count($controllers) . " controllers.\n";

foreach ($controllers as $controllerFile) {
    $content = file_get_contents($controllerFile);

    // تحقق إذا Class-level @OA\PathItem موجود بالفعل
    if (preg_match('/@OA\\\\PathItem/', $content)) {
        echo "✅ PathItem exists in: $controllerFile\n";
        continue;
    }

    // أضف Annotation فوق final class / class
    $newContent = preg_replace(
        '/(final\s+class\s+\w+|class\s+\w+)/',
        "/**\n * @OA\\PathItem()\n */\n\$1",
        $content,
        1,
        $count
    );

    if ($count > 0) {
        file_put_contents($controllerFile, $newContent);
        echo "🛠️ Added @OA\\PathItem() to: $controllerFile\n";
    } else {
        echo "⚠️ Could not modify class in: $controllerFile\n";
    }
}

echo "\n🎉 All done! You can now run: php artisan l5-swagger:generate\n";
