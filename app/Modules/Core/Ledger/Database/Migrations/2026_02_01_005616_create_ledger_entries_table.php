<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void{
        Schema::create('ledger_entries',function(Blueprint $table){
            $table->id();
            $table->string('reference_type');
            $table->unsignedBigInteger('reference_id');
            $table->string('account_debit');
            $table->string('account_credit');
            $table->decimal('amount',14,2);
            $table->string('currency',3);
            $table->enum('status',['pending','posted','failed'])->default('pending');
            $table->timestamps();
        });
    }
    public function down(): void{ Schema::dropIfExists('ledger_entries'); }
};
