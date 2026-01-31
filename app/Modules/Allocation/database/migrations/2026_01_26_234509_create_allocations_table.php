<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('allocations', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('donation_id');
            $table->uuid('project_id');
            $table->decimal('amount', 18, 2);
            $table->string('currency', 3);
            $table->uuid('committee_id');
            $table->timestamp('created_at')->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('allocations');
    }
};
