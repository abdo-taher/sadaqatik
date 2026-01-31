#!/bin/bash
set -e

echo "🚀 Setting up Phase 3 (Donations) → Phase 4 (Allocation) → Ledger cycle"

# =========================
# Directories
# =========================
mkdir -p app/Modules/Donations/{Models,Domain/Events,Application/Commands,Application/Handlers,Controllers,Routes,Database/Migrations,Providers}
mkdir -p app/Modules/Allocation/{Models,Domain/Events,Application/Commands,Application/Handlers,Application/Listeners,Controllers,Routes,Database/Migrations,Providers}
mkdir -p app/Modules/Core/Ledger/{Models,Database/Migrations,Providers}

# =========================
# Donations Model
# =========================
cat <<'PHP' > app/Modules/Donations/Models/Donation.php
<?php
namespace App\Modules\Donations\Models;
use Illuminate\Database\Eloquent\Model;

class Donation extends Model {
    protected $fillable = ['donor_id','project_id','amount','currency','status'];
}
PHP

# =========================
# Donations Migration
TIMESTAMP=$(date +%Y_%m_%d_%H%M%S)
cat <<PHP > app/Modules/Donations/Database/Migrations/${TIMESTAMP}_create_donations_table.php
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('donations', function (Blueprint \$table) {
            \$table->id();
            \$table->uuid('donor_id');
            \$table->foreignId('project_id')->constrained()->cascadeOnDelete();
            \$table->decimal('amount',12,2);
            \$table->string('currency',3);
            \$table->enum('status',['pending','confirmed','failed'])->default('pending');
            \$table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('donations'); }
};
PHP

# =========================
# DonationCreated & DonationConfirmed Events
cat <<'PHP' > app/Modules/Donations/Domain/Events/DonationCreated.php
<?php
namespace App\Modules\Donations\Domain\Events;
class DonationCreated {
    public function __construct(public readonly int $donationId, public readonly int $projectId, public readonly float $amount, public readonly string $currency) {}
}
PHP

cat <<'PHP' > app/Modules/Donations/Domain/Events/DonationConfirmed.php
<?php
namespace App\Modules\Donations\Domain\Events;
class DonationConfirmed {
    public function __construct(public readonly int $donationId, public readonly int $projectId, public readonly float $amount, public readonly string $currency) {}
}
PHP

# =========================
# Donation Command + Handler
cat <<'PHP' > app/Modules/Donations/Application/Commands/CreateDonationCommand.php
<?php
namespace App\Modules\Donations\Application\Commands;
class CreateDonationCommand {
    public function __construct(
        public readonly string $donorId,
        public readonly int $projectId,
        public readonly float $amount,
        public readonly string $currency
    ) {}
}
PHP

cat <<'PHP' > app/Modules/Donations/Application/Handlers/CreateDonationHandler.php
<?php
namespace App\Modules\Donations\Application\Handlers;
use App\Modules\Donations\Application\Commands\CreateDonationCommand;
use App\Modules\Donations\Models\Donation;
use App\Modules\Donations\Domain\Events\DonationCreated;
use App\Modules\Donations\Domain\Events\DonationConfirmed;
use Illuminate\Support\Facades\Event;
class CreateDonationHandler {
    public function handle(CreateDonationCommand $command): Donation {
        $donation = Donation::create([
            'donor_id'=>$command->donorId,
            'project_id'=>$command->projectId,
            'amount'=>$command->amount,
            'currency'=>$command->currency,
            'status'=>'confirmed', // مباشرة Confirmed
        ]);
        Event::dispatch(new DonationCreated($donation->id,$donation->project_id,$donation->amount,$donation->currency));
        Event::dispatch(new DonationConfirmed($donation->id,$donation->project_id,$donation->amount,$donation->currency));
        return $donation;
    }
}
PHP

# =========================
# Donation Controller
cat <<'PHP' > app/Modules/Donations/Controllers/DonationController.php
<?php
namespace App\Modules\Donations\Controllers;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Modules\Donations\Application\Commands\CreateDonationCommand;
use App\Modules\Donations\Application\Handlers\CreateDonationHandler;
class DonationController extends Controller {
    public function store(Request $request, CreateDonationHandler $handler){
        $data=$request->validate([
            'donor_id'=>'required|uuid',
            'project_id'=>'required|exists:projects,id',
            'amount'=>'required|numeric|min:1',
            'currency'=>'required|string|size:3',
        ]);
        $donation=$handler->handle(new CreateDonationCommand($data['donor_id'],$data['project_id'],$data['amount'],$data['currency']));
        return response()->json(['success'=>true,'donation_id'=>$donation->id,'status'=>$donation->status]);
    }
}
PHP

# =========================
# Donations Routes
cat <<'PHP' > app/Modules/Donations/Routes/api.php
<?php
use Illuminate\Support\Facades\Route;
use App\Modules\Donations\Controllers\DonationController;
Route::post('/donations',[DonationController::class,'store']);
PHP

# =========================
# Allocation Model + Migration
cat <<'PHP' > app/Modules/Allocation/Models/Allocation.php
<?php
namespace App\Modules\Allocation\Models;
use Illuminate\Database\Eloquent\Model;
class Allocation extends Model { protected $fillable=['donation_id','project_id','amount','allocated_by','status']; }
PHP

TIMESTAMP=$(date +%Y_%m_%d_%H%M%S)
cat <<PHP > app/Modules/Allocation/Database/Migrations/${TIMESTAMP}_create_allocations_table.php
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('allocations',function(Blueprint \$table){
            \$table->id();
            \$table->foreignId('donation_id')->constrained('donations')->cascadeOnDelete();
            \$table->foreignId('project_id')->constrained('projects')->cascadeOnDelete();
            \$table->decimal('amount',12,2);
            \$table->string('allocated_by');
            \$table->enum('status',['pending','completed'])->default('pending');
            \$table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('allocations'); }
};
PHP

# =========================
# Allocation Command + Handler
cat <<'PHP' > app/Modules/Allocation/Application/Commands/CreateAllocationCommand.php
<?php
namespace App\Modules\Allocation\Application\Commands;
class CreateAllocationCommand {
    public function __construct(public readonly int $donationId,public readonly int $projectId,public readonly float $amount,public readonly string $allocatedBy) {}
}
PHP

cat <<'PHP' > app/Modules/Allocation/Application/Handlers/CreateAllocationHandler.php
<?php
namespace App\Modules\Allocation\Application\Handlers;
use App\Modules\Allocation\Application\Commands\CreateAllocationCommand;
use App\Modules\Allocation\Models\Allocation;
use App\Modules\Allocation\Domain\Events\AllocationCreated;
use Illuminate\Support\Facades\Event;
class CreateAllocationHandler{
    public function handle(CreateAllocationCommand $command): Allocation{
        $allocation=Allocation::create([
            'donation_id'=>$command->donationId,
            'project_id'=>$command->projectId,
            'amount'=>$command->amount,
            'allocated_by'=>$command->allocatedBy,
            'status'=>'completed',
        ]);
        Event::dispatch(new AllocationCreated($allocation->id,$allocation->donation_id,$allocation->project_id,$allocation->amount));
        return $allocation;
    }
}
PHP

# =========================
# Allocation Event
cat <<'PHP' > app/Modules/Allocation/Domain/Events/AllocationCreated.php
<?php
namespace App\Modules\Allocation\Domain\Events;
class AllocationCreated {
    public function __construct(public readonly int $allocationId,public readonly int $donationId,public readonly int $projectId,public readonly float $amount) {}
}
PHP

# =========================
# Listener: DonationConfirmed → CreateAllocationCommand
cat <<'PHP' > app/Modules/Allocation/Application/Listeners/DonationConfirmedListener.php
<?php
namespace App\Modules\Allocation\Application\Listeners;
use App\Modules\Donations\Domain\Events\DonationConfirmed;
use App\Modules\Allocation\Application\Commands\CreateAllocationCommand;
use App\Modules\Allocation\Application\Handlers\CreateAllocationHandler;
class DonationConfirmedListener{
    protected CreateAllocationHandler $handler;
    public function __construct(CreateAllocationHandler $handler){ $this->handler=$handler; }
    public function handle(DonationConfirmed $event): void{
        $command=new CreateAllocationCommand($event->donationId,$event->projectId,$event->amount,'system');
        $this->handler->handle($command);
    }
}
PHP

# =========================
# Ledger Model + Migration
cat <<'PHP' > app/Modules/Core/Ledger/Models/LedgerEntry.php
<?php
namespace App\Modules\Core\Ledger\Models;
use Illuminate\Database\Eloquent\Model;
class LedgerEntry extends Model{ protected $fillable=['reference_type','reference_id','account_debit','account_credit','amount','currency','status']; }
PHP

TIMESTAMP=$(date +%Y_%m_%d_%H%M%S)
cat <<PHP > app/Modules/Core/Ledger/Database/Migrations/${TIMESTAMP}_create_ledger_entries_table.php
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void{
        Schema::create('ledger_entries',function(Blueprint \$table){
            \$table->id();
            \$table->string('reference_type');
            \$table->unsignedBigInteger('reference_id');
            \$table->string('account_debit');
            \$table->string('account_credit');
            \$table->decimal('amount',14,2);
            \$table->string('currency',3);
            \$table->enum('status',['pending','posted','failed'])->default('pending');
            \$table->timestamps();
        });
    }
    public function down(): void{ Schema::dropIfExists('ledger_entries'); }
};
PHP

# =========================
# AllocationCreated → LedgerEntry Listener
cat <<'PHP' > app/Modules/Allocation/Application/Listeners/AllocationCreatedListener.php
<?php
namespace App\Modules\Allocation\Application\Listeners;
use App\Modules\Allocation\Domain\Events\AllocationCreated;
use App\Modules\Core\Ledger\Models\LedgerEntry;
class AllocationCreatedListener{
    public function handle(AllocationCreated $event): void{
        LedgerEntry::create([
            'reference_type'=>'Allocation',
            'reference_id'=>$event->allocationId,
            'account_debit'=>'Project Fund',
            'account_credit'=>'Donations Revenue',
            'amount'=>$event->amount,
            'currency'=>'EGP',
            'status'=>'posted',
        ]);
    }
}
PHP

echo "✅ Donations → Allocation → Ledger cycle created!"
echo "➡️ Run: php artisan migrate"
echo "➡️ POST /api/donations to create Donation (Allocation + Ledger auto)"
