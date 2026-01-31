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
