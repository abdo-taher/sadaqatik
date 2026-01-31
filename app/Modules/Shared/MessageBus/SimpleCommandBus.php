<?php

namespace App\Modules\Shared\MessageBus;

use App\Modules\Shared\Contracts\Command;

class SimpleCommandBus
{
    protected array $handlers = [];

    public function register(string $command, string $handler): void
    {
        $this->handlers[$command] = $handler;
    }

    public function dispatch(Command $command): mixed
    {
        $handler = app($this->handlers[$command::class]);
        return $handler->handle($command);
    }
}
