<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Str;

class AuditModules extends Command
{
    protected $signature = 'audit:modules';
    protected $description = 'Advanced audit for all Modules: architecture, events, controllers, RBAC, migrations, projections';

    public function handle()
    {
        $modulesPath = app_path('Modules');
        $modules = File::directories($modulesPath);

        $report = [];

        foreach ($modules as $modulePath) {
            $moduleName = basename($modulePath);

            // 1️⃣ Check DB (Migration exists)
            $dbStatus = File::exists($modulePath . '/database/migrations') && count(File::files($modulePath . '/database/migrations')) > 0 ? '✅' : '❌';

            // 2️⃣ Check Events
            $eventsPath = $modulePath . '/Domain/Events';
            $hasEvents = File::exists($eventsPath) && count(File::files($eventsPath)) > 0 ? '✅' : '❌';

            // 3️⃣ Check Controllers PathItem
            $controllersPath = $modulePath . '/Presentation/Http/Controllers';
            $pathItemStatus = '❌';
            $controllerCount = 0;
            if (File::exists($controllersPath)) {
                $controllerFiles = File::allFiles($controllersPath);
                $controllerCount = count($controllerFiles);
                $allPathItem = true;
                foreach ($controllerFiles as $file) {
                    $content = File::get($file);
                    if (!preg_match('/@OA\\\\PathItem/', $content)) {
                        $allPathItem = false;
                        break;
                    }
                }
                $pathItemStatus = $allPathItem ? '✅' : '❌';
            }

            // 4️⃣ Core Ledger Checks
            $ledgerRules = 'N/A';
            if (Str::lower($moduleName) === 'core') {
                $ledgerFile = $modulePath . '/Domain/Entities/LedgerEntry.php';
                $moneyFile = $modulePath . '/Domain/ValueObjects/Money.php';
                $ledgerRules = (File::exists($ledgerFile) && File::exists($moneyFile)) ? '✅' : '❌';
            }

            // 5️⃣ RBAC / Approval Placeholder
            $rbacStatus = '⚠️'; // could be extended to check roles / approval workflow

            // 6️⃣ Projection / Dashboard Placeholder
            $projectionStatus = File::exists($modulesPath . '/Dashboard') ? '✅' : '❌';

            $report[] = [
                'Module' => $moduleName,
                'Migrations (DB)' => $dbStatus,
                'Events Emitted' => $hasEvents,
                'Controllers w/ PathItem' => $pathItemStatus,
                'Ledger Rules' => $ledgerRules,
                'RBAC/Approval' => $rbacStatus,
                'Projections/Dashboard' => $projectionStatus,
                'Controllers Count' => $controllerCount
            ];
        }

        $this->table(
            ['Module', 'Migrations (DB)', 'Events Emitted', 'Controllers w/ PathItem', 'Ledger Rules', 'RBAC/Approval', 'Projections/Dashboard', 'Controllers Count'],
            $report
        );

        $this->info("\n✅ Advanced Module Audit Complete!");
        $this->warn("⚠️ RBAC/Approval and Projections checks are placeholders – extend as needed.");
    }
}
