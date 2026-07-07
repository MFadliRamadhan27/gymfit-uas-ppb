<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
 public function up(): void
{
    Schema::create('members', function (Blueprint $table) {
        $table->id();
        $table->string('id_member', 20)->unique();
        $table->string('nama_lengkap', 100);
        $table->text('alamat');
        $table->string('kota', 50);
        $table->string('kode_pos', 5);
        $table->string('email', 100)->unique();
        $table->string('no_hp', 15);
        $table->softDeletes();
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('members');
    }
};
