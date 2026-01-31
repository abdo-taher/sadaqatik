<?php
namespace App\Modules\Donations\Domain\Events;
class DonationCreated {
    public function __construct(public readonly int $donationId, public readonly int $projectId, public readonly float $amount, public readonly string $currency) {}
}
