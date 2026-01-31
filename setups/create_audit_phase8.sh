#!/bin/bash
set -e

MODULE_PATH="app/Modules/Audit"

echo "🚀 Creating Audit Module (Phase 8)..."

# =========================
# Directories
mkdir -p $MODULE_PATH/{Models,Domain/Events,Application/Listeners,Database/Migrations,Providers}

# =========================
# Audit Model
cat <<'PHP' > $MODULE_PATH/Models/AuditLog.php
<?php
namespace App\Modules\Audit\Models;
use Illuminate\Database\Eloquent\Model;

class AuditLog extends Model {
    protected $fillable=['event_type','payload','user_id','module','created_at'];
    public $timestamps=false; // managed manually
}
PHP

# =========================
# Migration
TIMESTAMP=$(date +%Y_%m_%d_%H%M%S)
cat <<PHP > $MODULE_PATH/Database/Migrations/${TIMESTAMP}_create_audit_log_table.php
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('audit_logs',function(Blueprint \$table){
            \$table->id();
            \$table->string('event_type');
            \$table->json('payload');
            \$table->string('module');
            \$table->uuid('user_id')->nullable();
            \$table->timestamp('created_at')->useCurrent();
        });
    }
    public function down(): void { Schema::dropIfExists('audit_logs'); }
};
PHP

# =========================
# Event
cat <<'PHP' > $MODULE_PATH/Domain/Events/AuditLogged.php
<?php
namespace App\Modules\Audit\Domain\Events;
class AuditLogged {
    public function __construct(public readonly array $payload, public readonly ?string $userId, public readonly string $module, public readonly string $eventType) {}
}
PHP

# =========================
# Listener: catch all events
cat <<'PHP' > $MODULE_PATH/Application/Listeners/AuditListener.php
<?php
namespace App\Modules\Audit\Application\Listeners;
use App\Modules\Audit\Models\AuditLog;
use App\Modules\Audit\Domain\Events\AuditLogged;
use Illuminate\Support\Facades\Event;

class AuditListener {
    public function handle(object $event): void {
        $payload = json_decode(json_encode($event), true);
        $userId = auth()->check() ? auth()->id() : null;
        $module = explode('\\', get_class($event))[2] ?? 'Unknown';
        $eventType = class_basename($event);

        AuditLog::create([
            'payload'=>$payload,
            'user_id'=>$userId,
            'module'=>$module,
            'event_type'=>$eventType,
        ]);

        Event::dispatch(new AuditLogged($payload, $userId, $module, $eventType));
    }
}
PHP

# =========================
# Service Provider
cat <<'PHP' > $MODULE_PATH/Providers/AuditServiceProvider.php
<?php
namespace App\Modules\Audit\Providers;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Event;
use App\Modules\Audit\Application\Listeners\AuditListener;

class AuditServiceProvider extends ServiceProvider{
    public function boot(): void{
        $this->loadMigrationsFrom(__DIR__.'/../Database/Migrations');

        // Listen to all events dynamically
        Event::listen('*', [AuditListener::class,'handle']);
    }
}
PHP

# =========================
# Register Provider
PROVIDERS_FILE="config/app.php"
if ! grep -q "AuditServiceProvider" "$PROVIDERS_FILE"; then
    sed -i "/providers => \[/a\\
        App\\\\Modules\\\\Audit\\\\Providers\\\\AuditServiceProvider::class," $PROVIDERS_FILE
fi

echo "✅ Audit Module Phase 8 ready!"
echo "➡️ Run: php artisan migrate"
echo "➡️ All Domain Events will now be logged automatically (Immutable & Audit-ready)"
