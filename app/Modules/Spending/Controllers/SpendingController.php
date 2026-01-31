<?php
namespace App\Modules\Spending\Controllers;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Modules\Spending\Application\Commands\CreateSpendingCommand;
use App\Modules\Spending\Application\Handlers\CreateSpendingHandler;

class SpendingController extends Controller {
    public function store(Request $request, CreateSpendingHandler $handler){
        $data=$request->validate([
            'allocation_id'=>'required|exists:allocations,id',
            'amount'=>'required|numeric|min:1',
            'spent_by'=>'required|string',
            'description'=>'nullable|string',
        ]);
        $spending=$handler->handle(new CreateSpendingCommand($data['allocation_id'],$data['amount'],$data['spent_by'],$data['description']??null));
        return response()->json(['success'=>true,'spending_id'=>$spending->id,'status'=>$spending->status]);
    }
}
