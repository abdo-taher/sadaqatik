<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('payments',function(Blueprint $table){
            $table->id();
            $table->foreignId('donation_id')->constrained('donations')->cascadeOnDelete();
            $table->decimal('amount',12,2);
            $table->string('currency',3);
            $table->string('payment_method');
            $table->enum('status',['pending','confirmed','failed'])->default('pending');
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('payments'); }
};
