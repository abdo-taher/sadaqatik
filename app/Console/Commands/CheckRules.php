<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;
use ReflectionClass;

class CheckRules extends Command
{
    protected $signature = 'check:rules';
    protected $description = 'Check if all Modules comply with architecture & business rules';

    public function handle()
    {
        $modulesPath = app_path('Modules');
        $modules = File::directories($modulesPath);

        $report = [];

        foreach ($modules as $modulePath) {
            $moduleName = basename($modulePath);
            $controllersPath = $modulePath . '/Presentation/Http/Controllers';
            $hasControllers = File::exists($controllersPath);

            $pathItemMissing = false;
            $eventsDir = $modulePath . '/Domain/Events';
            $hasEvents = File::exists($eventsDir) && count(File::files($eventsDir)) > 0;

            if ($hasControllers) {
                $controllerFiles = File::allFiles($controllersPath);
                foreach ($controllerFiles as $file) {
                    $content = File::get($file);
                    if (!preg_match('/@OA\\\\PathItem/', $content)) {
                        $pathItemMissing = true;
                        break;
                    }
                }
            }

            $report[] = [
                'Module' => $moduleName,
                'Own DB' => File::exists($modulePath . '/database/migrations') ? '✅' : '❌',
                'Events emitted' => $hasEvents ? '✅' : '❌',
                'PathItem Controller' => !$pathItemMissing ? '✅' : '❌',
            ];
        }

        $this->table(
            ['Module', 'Own DB', 'Events emitted', 'PathItem Controller'],
            $report
        );

        $this->info("\n✅ Checked Modules for rules compliance!");
    }
}
