<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('forecast',function(Blueprint $table){
            $table->id();
            $table->foreignId('project_id')->constrained('projects')->cascadeOnDelete();
            $table->decimal('budget',12,2)->default(0);
            $table->decimal('allocated',12,2)->default(0);
            $table->decimal('spent',12,2)->default(0);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('forecast'); }
};
