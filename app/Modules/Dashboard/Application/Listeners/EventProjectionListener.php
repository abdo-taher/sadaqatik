<?php
namespace App\Modules\Dashboard\Application\Listeners;
use App\Modules\Dashboard\ReadModels\DonorDashboard;
use App\Modules\Dashboard\ReadModels\CommitteeDashboard;
use App\Modules\Dashboard\ReadModels\FinanceDashboard;
use App\Modules\Dashboard\ReadModels\AdminDashboard;
use App\Modules\Dashboard\ReadModels\AuditorDashboard;
use Illuminate\Support\Facades\Event;

class EventProjectionListener{
//    public function handle(object $event): void{
    public function handle($event): void{
        if (!is_object($event)) {
            return;
        }
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
