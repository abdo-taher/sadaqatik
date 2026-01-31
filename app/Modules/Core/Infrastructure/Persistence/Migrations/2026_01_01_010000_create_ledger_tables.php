<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('ledger_accounts', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name');
            $table->string('type');
        });

        Schema::create('ledger_entries', function (Blueprint $table) {
            $table->id();
            $table->uuid('account_id');
            $table->decimal('amount', 15, 2);
            $table->boolean('is_debit');
            $table->string('currency', 3);
            $table->uuid('event_id');
            $table->timestamp('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ledger_entries');
        Schema::dropIfExists('ledger_accounts');
    }
};
