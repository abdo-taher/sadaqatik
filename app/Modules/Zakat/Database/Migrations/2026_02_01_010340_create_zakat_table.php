<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('zakat',function(Blueprint $table){
            $table->id();
            $table->string('reference_type');
            $table->unsignedBigInteger('reference_id');
            $table->decimal('amount',12,2);
            $table->enum('status',['pending','calculated','posted'])->default('pending');
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('zakat'); }
};
