<?php

namespace App\Modules\Shared\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use App\Modules\Shared\Events\DomainEvent;

class DispatchDomainEventJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        public DomainEvent $event
    ) {}

    public function handle(): void
    {
        event($this->event);
    }
}
