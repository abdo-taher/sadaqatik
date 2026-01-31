<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('spending',function(Blueprint $table){
            $table->id();
            $table->foreignId('allocation_id')->constrained('allocations')->cascadeOnDelete();
            $table->decimal('amount',12,2);
            $table->string('spent_by');
            $table->string('description')->nullable();
            $table->enum('status',['pending','completed'])->default('pending');
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('spending'); }
};
