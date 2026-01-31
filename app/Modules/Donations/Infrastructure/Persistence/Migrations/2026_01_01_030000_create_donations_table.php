<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('donations', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('donor_name');
            $table->decimal('amount', 15, 2);
            $table->string('currency', 3);
            $table->uuid('project_id')->nullable();
            $table->uuid('committee_id')->nullable();
            $table->string('status')->default('pending');
            $table->uuid('event_id');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('donations');
    }
};
