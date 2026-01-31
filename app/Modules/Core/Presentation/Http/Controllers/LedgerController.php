<?php

namespace App\Modules\Core\Presentation\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Modules\Core\Application\Commands\RecordLedgerEntryCommand;
use App\Modules\Core\Application\Handlers\RecordLedgerEntryHandler;
use App\Modules\Core\Domain\ValueObjects\Money;

final class LedgerController extends Controller
{
    public function record(Request $request, RecordLedgerEntryHandler $handler): JsonResponse
    {
        $request->validate([
            'account_id' => 'required|uuid',
            'amount' => 'required|numeric',
            'currency' => 'required|string|size:3',
            'type' => 'required|in:debit,credit',
            'description' => 'required|string',
        ]);

        $command = new RecordLedgerEntryCommand(
            $request->account_id,
            new Money((float)$request->amount, $request->currency),
            $request->type,
            $request->description
        );

        $handler->handle($command);

        return response()->json(['success' => true]);
    }
}
