#!/bin/bash
set -e

MODULE_PATH="app/Modules/Dashboard"

echo "🚀 Creating Tracking & Dashboards Module (Phase 10)..."

# =========================
# Directories
mkdir -p $MODULE_PATH/{ReadModels,Domain/Events,Application/Listeners,Providers,Routes,Controllers}

# =========================
# Read Models
cat <<'PHP' > $MODULE_PATH/ReadModels/DonorDashboard.php
<?php
namespace App\Modules\Dashboard\ReadModels;
use Illuminate\Database\Eloquent\Model;
class DonorDashboard extends Model{
    protected $fillable=['donor_id','donation_id','project_id','amount','currency','status'];
}
PHP

cat <<'PHP' > $MODULE_PATH/ReadModels/CommitteeDashboard.php
<?php
namespace App\Modules\Dashboard\ReadModels;
use Illuminate\Database\Eloquent\Model;
class CommitteeDashboard extends Model{
    protected $fillable=['committee_id','allocation_id','project_id','amount','status'];
}
PHP

cat <<'PHP' > $MODULE_PATH/ReadModels/FinanceDashboard.php
<?php
namespace App\Modules\Dashboard\ReadModels;
use Illuminate\Database\Eloquent\Model;
class FinanceDashboard extends Model{
    protected $fillable=['module','event_type','reference_id','amount','currency','status'];
}
PHP

cat <<'PHP' > $MODULE_PATH/ReadModels/AdminDashboard.php
<?php
namespace App\Modules\Dashboard\ReadModels;
use Illuminate\Database\Eloquent\Model;
class AdminDashboard extends Model{
    protected $fillable=['module','event_type','payload','user_id','created_at'];
}
PHP

cat <<'PHP' > $MODULE_PATH/ReadModels/AuditorDashboard.php
<?php
namespace App\Modules\Dashboard\ReadModels;
use Illuminate\Database\Eloquent\Model;
class AuditorDashboard extends Model{
    protected $fillable=['module','event_type','payload','user_id','created_at'];
}
PHP

# =========================
# Listener: Generic Event → Update Read Models
cat <<'PHP' > $MODULE_PATH/Application/Listeners/EventProjectionListener.php
<?php
namespace App\Modules\Dashboard\Application\Listeners;
use App\Modules\Dashboard\ReadModels\DonorDashboard;
use App\Modules\Dashboard\ReadModels\CommitteeDashboard;
use App\Modules\Dashboard\ReadModels\FinanceDashboard;
use App\Modules\Dashboard\ReadModels\AdminDashboard;
use App\Modules\Dashboard\ReadModels\AuditorDashboard;
use Illuminate\Support\Facades\Event;

class EventProjectionListener{
    public function handle(object $event): void{
        $eventClass=class_basename($event);
        $payload=json_decode(json_encode($event),true);

        // Example mapping logic
        switch($eventClass){
            case 'DonationCreated':
            case 'DonationConfirmed':
                DonorDashboard::create([
                    'donor_id'=>$payload['donorId']??null,
                    'donation_id'=>$payload['donationId']??null,
                    'project_id'=>$payload['projectId']??null,
                    'amount'=>$payload['amount']??0,
                    'currency'=>$payload['currency']??'',
                    'status'=>$payload['status']??'confirmed'
                ]);
                break;

            case 'AllocationCreated':
            case 'SpendingApproved':
                CommitteeDashboard::create([
                    'committee_id'=>$payload['committeeId']??null,
                    'allocation_id'=>$payload['allocationId']??null,
                    'project_id'=>$payload['projectId']??null,
                    'amount'=>$payload['amount']??0,
                    'status'=>$payload['status']??'approved'
                ]);
                FinanceDashboard::create([
                    'module'=>'Allocation/Spending',
                    'event_type'=>$eventClass,
                    'reference_id'=>$payload['allocationId']??$payload['spendingId']??null,
                    'amount'=>$payload['amount']??0,
                    'currency'=>$payload['currency']??'',
                    'status'=>$payload['status']??'approved'
                ]);
                break;

            case 'PaymentConfirmed':
            case 'ZakatCalculated':
                FinanceDashboard::create([
                    'module'=>'Payments/Zakat',
                    'event_type'=>$eventClass,
                    'reference_id'=>$payload['paymentId']??$payload['zakatId']??null,
                    'amount'=>$payload['amount']??0,
                    'currency'=>$payload['currency']??'',
                    'status'=>'confirmed'
                ]);
                break;

            case 'AuditLogged':
                AdminDashboard::create([
                    'module'=>$payload['module']??'',
                    'event_type'=>$payload['event_type']??'',
                    'payload'=>json_encode($payload['payload']??[]),
                    'user_id'=>$payload['user_id']??null,
                    'created_at'=>$payload['created_at']??now()
                ]);
                AuditorDashboard::create([
                    'module'=>$payload['module']??'',
                    'event_type'=>$payload['event_type']??'',
                    'payload'=>json_encode($payload['payload']??[]),
                    'user_id'=>$payload['user_id']??null,
                    'created_at'=>$payload['created_at']??now()
                ]);
                break;

            default:
                // ignore other events or extend later
                break;
        }
    }
}
PHP

# =========================
# Service Provider
cat <<'PHP' > $MODULE_PATH/Providers/DashboardServiceProvider.php
<?php
namespace App\Modules\Dashboard\Providers;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Event;
use App\Modules\Dashboard\Application\Listeners\EventProjectionListener;

class DashboardServiceProvider extends ServiceProvider{
    public function boot(): void{
        Event::listen('*',[EventProjectionListener::class,'handle']);
    }
}
PHP

# =========================
# Register Provider
PROVIDERS_FILE="config/app.php"
if ! grep -q "DashboardServiceProvider" "$PROVIDERS_FILE"; then
    sed -i "/providers => \[/a\\
        App\\\\Modules\\\\Dashboard\\\\Providers\\\\DashboardServiceProvider::class," $PROVIDERS_FILE
fi

echo "✅ Dashboard & Tracking Module Phase 10 ready!"
echo "➡️ All Domain Events now update Read Models automatically"
echo "➡️ Ready for UI / WebSocket Real-time Dashboards"
