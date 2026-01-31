<?php

namespace App\Modules\Spending\Application\Commands;

use App\Modules\Spending\Domain\Entities\Spending;
use App\Modules\Shared\Contracts\Command;

final class ApproveSpendingCommand implements Command
{
    public function __construct(
        public readonly Spending $spending
    ) {}
}
