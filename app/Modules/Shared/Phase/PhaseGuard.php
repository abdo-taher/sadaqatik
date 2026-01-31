<?php

namespace App\Modules\Shared\Phase;

class PhaseGuard
{
    protected array $completed = [];

    public function markCompleted(Phase $phase): void
    {
        $this->completed[$phase->value] = true;
    }

    public function ensureCompleted(Phase ...$phases): void
    {
        foreach ($phases as $phase) {
            if (!($this->completed[$phase->value] ?? false)) {
                throw new \RuntimeException("Phase {$phase->name} not completed.");
            }
        }
    }
}
