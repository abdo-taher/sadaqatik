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
