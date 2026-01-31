<?php

namespace App\Modules\Allocation\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Modules\Allocation\Application\Handlers\CreateAllocationHandler;
use App\Modules\Allocation\Application\Commands\CreateAllocationCommand;

class AllocationController extends Controller
{
    public function store(Request $request, CreateAllocationHandler $handler)
    {
        $data = $request->validate([
            'donation_id' => 'required|exists:donations,id',
            'project_id' => 'required|exists:projects,id',
            'amount' => 'required|numeric|min:1',
            'allocated_by' => 'required|string',
        ]);

        $allocation = $handler->handle(
            new CreateAllocationCommand(
                $data['donation_id'],
                $data['project_id'],
                $data['amount'],
                $data['allocated_by']
            )
        );

        return response()->json([
            'success' => true,
            'allocation_id' => $allocation->id,
            'status' => $allocation->status,
        ]);
    }
}
