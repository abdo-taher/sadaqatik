<?php
namespace App\Modules\Zakat\Application\Handlers;
use App\Modules\Zakat\Application\Commands\CalculateZakatCommand;
use App\Modules\Zakat\Models\Zakat;
use App\Modules\Zakat\Domain\Events\ZakatCalculated;
use Illuminate\Support\Facades\Event;

class CalculateZakatHandler{
    public function handle(CalculateZakatCommand $command): Zakat{
        $zakatAmount=round($command->amount*0.025,2);
        $zakat=Zakat::create([
            'reference_type'=>$command->referenceType,
            'reference_id'=>$command->referenceId,
            'amount'=>$zakatAmount,
            'status'=>'calculated',
        ]);
        Event::dispatch(new ZakatCalculated($command->referenceType,$command->referenceId,$zakatAmount));
        return $zakat;
    }
}
