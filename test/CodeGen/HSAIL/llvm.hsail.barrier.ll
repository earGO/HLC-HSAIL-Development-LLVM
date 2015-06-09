; RUN: llc -march=hsail -verify-machineinstrs < %s | FileCheck -check-prefix=HSAIL %s

; HSAIL-LABEL: {{^}}prog function &test_barrier_all(
; HSAIL: barrier;
; HSAIL-NEXT: ret;
define void @test_barrier_all(i32 addrspace(1)* %out) #1 {
  call void @llvm.hsail.barrier(i32 34) #2
  ret void
}

; HSAIL-LABEL: {{^}}prog function &test_barrier_wavesize(
; HSAIL: barrier_width(WAVESIZE);
; HSAIL-NEXT: ret;
define void @test_barrier_wavesize(i32 addrspace(1)* %out) #1 {
  call void @llvm.hsail.barrier(i32 33) #2
  ret void
}

; HSAIL-LABEL: {{^}}prog function &test_barrier_1(
; HSAIL: barrier_width(1);
; HSAIL-NEXT: ret;
define void @test_barrier_1(i32 addrspace(1)* %out) #1 {
  call void @llvm.hsail.barrier(i32 1) #2
  ret void
}

; HSAIL-LABEL: {{^}}prog function &test_barrier_64(
; HSAIL: barrier_width(64);
; HSAIL-NEXT: ret;
define void @test_barrier_64(i32 addrspace(1)* %out) #1 {
  call void @llvm.hsail.barrier(i32 7) #2
  ret void
}

; HSAIL-LABEL: {{^}}prog function &test_barrier_2147483648(
; HSAIL: barrier_width(2147483648);
; HSAIL-NEXT: ret;
define void @test_barrier_2147483648(i32 addrspace(1)* %out) #1 {
  call void @llvm.hsail.barrier(i32 32) #2
  ret void
}

; HSAIL-LABEL: {{^}}prog function &test_barrier_mem(
; HSAIL: st_global_align(4)_u32
; HSAIL: barrier;
; HSAIL: ld_global_align(4)_u32
define void @test_barrier_mem(i32 addrspace(1)* %out) #1 {
  %tmp = call i32 @llvm.HSAIL.get.global.id(i32 0)
  %tmp1 = getelementptr i32, i32 addrspace(1)* %out, i32 %tmp
  store i32 %tmp, i32 addrspace(1)* %tmp1
  call void @llvm.hsail.barrier(i32 34) #1
  %tmp2 = call i32 @llvm.HSAIL.workgroup.size(i32 0) #0
  %tmp3 = sub i32 %tmp2, 1
  %tmp4 = sub i32 %tmp3, %tmp
  %tmp5 = getelementptr i32, i32 addrspace(1)* %out, i32 %tmp4
  %tmp6 = load i32, i32 addrspace(1)* %tmp5
  store i32 %tmp6, i32 addrspace(1)* %tmp1
  ret void
}

; HSAIL-LABEL: {{^}}prog function &test_legacy_barrier_0(
; HSAIL: barrier;
; HSAIL-NEXT: ret;
define void @test_legacy_barrier_0(i32 addrspace(1)* %out) #1 {
  call void @llvm.HSAIL.barrier() #1
  ret void
}

declare void @llvm.HSAIL.barrier() #1
declare void @llvm.hsail.barrier(i32) #2

; Function Attrs: nounwind readnone
declare i32 @llvm.HSAIL.get.global.id(i32) #0

; Function Attrs: nounwind readnone
declare i32 @llvm.HSAIL.workgroup.size(i32) #0

attributes #0 = { nounwind readnone }
attributes #1 = { nounwind noduplicate }
attributes #2 = { nounwind noduplicate convergent }
