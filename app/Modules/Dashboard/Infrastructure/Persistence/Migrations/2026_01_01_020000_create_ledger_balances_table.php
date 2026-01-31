<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('ledger_balances', function (Blueprint $table) {
            $table->id();
            $table->uuid('account_id')->index();
            $table->decimal('balance', 15, 2);
            $table->string('currency', 3);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ledger_balances');
    }
};
