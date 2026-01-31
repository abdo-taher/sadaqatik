<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('budget_forecasts', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('project_id')->nullable();
            $table->uuid('committee_id')->nullable();
            $table->decimal('forecasted_income', 15, 2)->default(0);
            $table->decimal('forecasted_expense', 15, 2)->default(0);
            $table->decimal('budget_threshold', 15, 2)->default(0);
            $table->string('currency', 3)->default('EGP');
            $table->uuid('event_id');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('budget_forecasts');
    }
};
