; ModuleID = 'redirect_kern.c'
source_filename = "redirect_kern.c"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf"

%struct.bpf_map_def = type { i32, i32, i32, i32, i32 }
%struct.xdp_md = type { i32, i32, i32, i32, i32 }
%struct.bpf_fib_lookup = type { i8, i8, i16, i16, i16, i32, %union.anon, %union.anon.0, %union.anon.1, i16, i16, [6 x i8], [6 x i8] }
%union.anon = type { i32 }
%union.anon.0 = type { [4 x i32] }
%union.anon.1 = type { [4 x i32] }
%struct.ethhdr = type { [6 x i8], [6 x i8], i16 }
%struct.iphdr = type { i8, i8, i16, i16, i16, i8, i8, i16, i32, i32 }

@tx_port = dso_local global %struct.bpf_map_def { i32 14, i32 4, i32 4, i32 256, i32 0 }, section "maps", align 4, !dbg !0
@__const.xdp_router_func.____fmt = private unnamed_addr constant [23 x i8] c"[xdp_router] action %d\00", align 1
@_license = dso_local global [4 x i8] c"GPL\00", section "license", align 1, !dbg !21
@llvm.used = appending global [4 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (%struct.bpf_map_def* @tx_port to i8*), i8* bitcast (i32 (%struct.xdp_md*)* @xdp_pass_func to i8*), i8* bitcast (i32 (%struct.xdp_md*)* @xdp_router_func to i8*)], section "llvm.metadata"

; Function Attrs: nounwind
define dso_local i32 @xdp_router_func(%struct.xdp_md* %0) #0 section "xdp_router" !dbg !99 {
  %2 = alloca %struct.bpf_fib_lookup, align 4
  %3 = alloca [23 x i8], align 1
  call void @llvm.dbg.value(metadata %struct.xdp_md* %0, metadata !111, metadata !DIExpression()), !dbg !151
  %4 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 1, !dbg !152
  %5 = load i32, i32* %4, align 4, !dbg !152, !tbaa !153
  %6 = zext i32 %5 to i64, !dbg !158
  %7 = inttoptr i64 %6 to i8*, !dbg !159
  call void @llvm.dbg.value(metadata i8* %7, metadata !112, metadata !DIExpression()), !dbg !151
  %8 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 0, !dbg !160
  %9 = load i32, i32* %8, align 4, !dbg !160, !tbaa !161
  %10 = zext i32 %9 to i64, !dbg !162
  %11 = inttoptr i64 %10 to i8*, !dbg !163
  call void @llvm.dbg.value(metadata i8* %11, metadata !113, metadata !DIExpression()), !dbg !151
  %12 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %2, i64 0, i32 0, !dbg !164
  call void @llvm.lifetime.start.p0i8(i64 64, i8* nonnull %12) #4, !dbg !164
  call void @llvm.dbg.declare(metadata %struct.bpf_fib_lookup* %2, metadata !114, metadata !DIExpression()), !dbg !165
  call void @llvm.memset.p0i8.i64(i8* nonnull align 4 dereferenceable(64) %12, i8 0, i64 64, i1 false), !dbg !165
  %13 = inttoptr i64 %10 to %struct.ethhdr*, !dbg !166
  call void @llvm.dbg.value(metadata %struct.ethhdr* %13, metadata !115, metadata !DIExpression()), !dbg !151
  call void @llvm.dbg.value(metadata i32 2, metadata !144, metadata !DIExpression()), !dbg !151
  call void @llvm.dbg.value(metadata i64 14, metadata !142, metadata !DIExpression()), !dbg !151
  %14 = getelementptr i8, i8* %11, i64 14, !dbg !167
  %15 = icmp ugt i8* %14, %7, !dbg !169
  br i1 %15, label %67, label %16, !dbg !170

16:                                               ; preds = %1
  %17 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %13, i64 0, i32 2, !dbg !171
  %18 = load i16, i16* %17, align 1, !dbg !171, !tbaa !172
  call void @llvm.dbg.value(metadata i16 %18, metadata !141, metadata !DIExpression()), !dbg !151
  %19 = icmp eq i16 %18, 8, !dbg !175
  br i1 %19, label %20, label %67, !dbg !177

20:                                               ; preds = %16
  call void @llvm.dbg.value(metadata i8* %14, metadata !124, metadata !DIExpression()), !dbg !151
  %21 = getelementptr i8, i8* %11, i64 34, !dbg !178
  %22 = bitcast i8* %21 to %struct.iphdr*, !dbg !178
  %23 = inttoptr i64 %6 to %struct.iphdr*, !dbg !181
  %24 = icmp ugt %struct.iphdr* %22, %23, !dbg !182
  br i1 %24, label %67, label %25, !dbg !183

25:                                               ; preds = %20
  %26 = getelementptr i8, i8* %11, i64 22, !dbg !184
  %27 = load i8, i8* %26, align 4, !dbg !184, !tbaa !186
  %28 = icmp ult i8 %27, 2, !dbg !188
  br i1 %28, label %67, label %29, !dbg !189

29:                                               ; preds = %25
  store i8 2, i8* %12, align 4, !dbg !190, !tbaa !191
  %30 = getelementptr i8, i8* %11, i64 15, !dbg !193
  %31 = load i8, i8* %30, align 1, !dbg !193, !tbaa !194
  %32 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %2, i64 0, i32 6, !dbg !195
  %33 = bitcast %union.anon* %32 to i8*, !dbg !195
  store i8 %31, i8* %33, align 4, !dbg !196, !tbaa !197
  %34 = getelementptr i8, i8* %11, i64 23, !dbg !198
  %35 = load i8, i8* %34, align 1, !dbg !198, !tbaa !199
  %36 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %2, i64 0, i32 1, !dbg !200
  store i8 %35, i8* %36, align 1, !dbg !201, !tbaa !202
  %37 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %2, i64 0, i32 2, !dbg !203
  store i16 0, i16* %37, align 2, !dbg !204, !tbaa !205
  %38 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %2, i64 0, i32 3, !dbg !206
  store i16 0, i16* %38, align 4, !dbg !207, !tbaa !208
  %39 = getelementptr i8, i8* %11, i64 16, !dbg !209
  %40 = bitcast i8* %39 to i16*, !dbg !209
  %41 = load i16, i16* %40, align 2, !dbg !209, !tbaa !210
  %42 = tail call i16 @llvm.bswap.i16(i16 %41)
  %43 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %2, i64 0, i32 4, !dbg !211
  store i16 %42, i16* %43, align 2, !dbg !212, !tbaa !213
  %44 = getelementptr i8, i8* %11, i64 26, !dbg !214
  %45 = bitcast i8* %44 to i32*, !dbg !214
  %46 = load i32, i32* %45, align 4, !dbg !214, !tbaa !215
  %47 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %2, i64 0, i32 7, i32 0, i64 0, !dbg !216
  store i32 %46, i32* %47, align 4, !dbg !217, !tbaa !197
  %48 = getelementptr i8, i8* %11, i64 30, !dbg !218
  %49 = bitcast i8* %48 to i32*, !dbg !218
  %50 = load i32, i32* %49, align 4, !dbg !218, !tbaa !219
  %51 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %2, i64 0, i32 8, i32 0, i64 0, !dbg !220
  store i32 %50, i32* %51, align 4, !dbg !221, !tbaa !197
  %52 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 3, !dbg !222
  %53 = load i32, i32* %52, align 4, !dbg !222, !tbaa !223
  %54 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %2, i64 0, i32 5, !dbg !224
  store i32 %53, i32* %54, align 4, !dbg !225, !tbaa !226
  %55 = bitcast %struct.xdp_md* %0 to i8*, !dbg !227
  %56 = call i32 inttoptr (i64 69 to i32 (i8*, %struct.bpf_fib_lookup*, i32, i32)*)(i8* %55, %struct.bpf_fib_lookup* nonnull %2, i32 64, i32 0) #4, !dbg !228
  call void @llvm.dbg.value(metadata i32 %56, metadata !143, metadata !DIExpression()), !dbg !151
  switch i32 %56, label %67 [
    i32 0, label %57
    i32 1, label %66
    i32 2, label %66
    i32 3, label %66
  ], !dbg !229

57:                                               ; preds = %29
  call void @llvm.dbg.value(metadata i8* %14, metadata !230, metadata !DIExpression()), !dbg !235
  %58 = load i8, i8* %26, align 4, !dbg !239, !tbaa !186
  %59 = add i8 %58, -1, !dbg !239
  store i8 %59, i8* %26, align 4, !dbg !239, !tbaa !186
  %60 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %13, i64 0, i32 0, i64 0, !dbg !240
  %61 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %2, i64 0, i32 12, i64 0, !dbg !240
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 dereferenceable(6) %60, i8* nonnull align 2 dereferenceable(6) %61, i64 6, i1 false), !dbg !240
  %62 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %13, i64 0, i32 1, i64 0, !dbg !241
  %63 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %2, i64 0, i32 11, i64 0, !dbg !241
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 dereferenceable(6) %62, i8* nonnull align 4 dereferenceable(6) %63, i64 6, i1 false), !dbg !241
  %64 = load i32, i32* %54, align 4, !dbg !242, !tbaa !226
  %65 = call i32 inttoptr (i64 51 to i32 (i8*, i32, i64)*)(i8* bitcast (%struct.bpf_map_def* @tx_port to i8*), i32 %64, i64 0) #4, !dbg !243
  call void @llvm.dbg.value(metadata i32 %65, metadata !144, metadata !DIExpression()), !dbg !151
  br label %67, !dbg !244

66:                                               ; preds = %29, %29, %29
  call void @llvm.dbg.value(metadata i32 1, metadata !144, metadata !DIExpression()), !dbg !151
  br label %67, !dbg !245

67:                                               ; preds = %20, %1, %57, %66, %29, %16, %25
  %68 = phi i32 [ 2, %25 ], [ 2, %29 ], [ 1, %66 ], [ %65, %57 ], [ 2, %16 ], [ 1, %1 ], [ 1, %20 ], !dbg !151
  call void @llvm.dbg.value(metadata i32 %68, metadata !144, metadata !DIExpression()), !dbg !151
  call void @llvm.dbg.label(metadata !150), !dbg !246
  %69 = getelementptr inbounds [23 x i8], [23 x i8]* %3, i64 0, i64 0, !dbg !247
  call void @llvm.lifetime.start.p0i8(i64 23, i8* nonnull %69) #4, !dbg !247
  call void @llvm.dbg.declare(metadata [23 x i8]* %3, metadata !145, metadata !DIExpression()), !dbg !247
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 dereferenceable(23) %69, i8* nonnull align 1 dereferenceable(23) getelementptr inbounds ([23 x i8], [23 x i8]* @__const.xdp_router_func.____fmt, i64 0, i64 0), i64 23, i1 false), !dbg !247
  %70 = call i32 (i8*, i32, ...) inttoptr (i64 6 to i32 (i8*, i32, ...)*)(i8* nonnull %69, i32 23, i32 %68) #4, !dbg !247
  call void @llvm.lifetime.end.p0i8(i64 23, i8* nonnull %69) #4, !dbg !248
  call void @llvm.lifetime.end.p0i8(i64 64, i8* nonnull %12) #4, !dbg !249
  ret i32 %68, !dbg !250
}

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare i16 @llvm.bswap.i16(i16) #1

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.label(metadata) #1

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: norecurse nounwind readnone
define dso_local i32 @xdp_pass_func(%struct.xdp_md* nocapture readnone %0) #3 section "xdp_pass" !dbg !251 {
  call void @llvm.dbg.value(metadata %struct.xdp_md* undef, metadata !253, metadata !DIExpression()), !dbg !254
  ret i32 2, !dbg !255
}

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #1

attributes #0 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { norecurse nounwind readnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!95, !96, !97}
!llvm.ident = !{!98}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "tx_port", scope: !2, file: !3, line: 16, type: !87, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 10.0.0-4ubuntu1 ", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !14, globals: !20, splitDebugInlining: false, nameTableKind: None)
!3 = !DIFile(filename: "redirect_kern.c", directory: "/mydata/mtcp/afxdp/mtcp_xdp_pktio")
!4 = !{!5}
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "xdp_action", file: !6, line: 2845, baseType: !7, size: 32, elements: !8)
!6 = !DIFile(filename: "../headers/linux/bpf.h", directory: "/mydata/mtcp/afxdp/mtcp_xdp_pktio")
!7 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!8 = !{!9, !10, !11, !12, !13}
!9 = !DIEnumerator(name: "XDP_ABORTED", value: 0, isUnsigned: true)
!10 = !DIEnumerator(name: "XDP_DROP", value: 1, isUnsigned: true)
!11 = !DIEnumerator(name: "XDP_PASS", value: 2, isUnsigned: true)
!12 = !DIEnumerator(name: "XDP_TX", value: 3, isUnsigned: true)
!13 = !DIEnumerator(name: "XDP_REDIRECT", value: 4, isUnsigned: true)
!14 = !{!15, !16, !17}
!15 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!16 = !DIBasicType(name: "long int", size: 64, encoding: DW_ATE_signed)
!17 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u16", file: !18, line: 24, baseType: !19)
!18 = !DIFile(filename: "/usr/include/asm-generic/int-ll64.h", directory: "")
!19 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!20 = !{!0, !21, !27, !73, !80}
!21 = !DIGlobalVariableExpression(var: !22, expr: !DIExpression())
!22 = distinct !DIGlobalVariable(name: "_license", scope: !2, file: !3, line: 112, type: !23, isLocal: false, isDefinition: true)
!23 = !DICompositeType(tag: DW_TAG_array_type, baseType: !24, size: 32, elements: !25)
!24 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!25 = !{!26}
!26 = !DISubrange(count: 4)
!27 = !DIGlobalVariableExpression(var: !28, expr: !DIExpression())
!28 = distinct !DIGlobalVariable(name: "bpf_fib_lookup", scope: !2, file: !29, line: 1764, type: !30, isLocal: true, isDefinition: true)
!29 = !DIFile(filename: "/usr/include/bpf/bpf_helper_defs.h", directory: "")
!30 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !31, size: 64)
!31 = !DISubroutineType(types: !32)
!32 = !{!33, !15, !34, !33, !47}
!33 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!34 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !35, size: 64)
!35 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "bpf_fib_lookup", file: !6, line: 3179, size: 512, elements: !36)
!36 = !{!37, !40, !41, !44, !45, !46, !48, !55, !61, !66, !67, !68, !72}
!37 = !DIDerivedType(tag: DW_TAG_member, name: "family", scope: !35, file: !6, line: 3183, baseType: !38, size: 8)
!38 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u8", file: !18, line: 21, baseType: !39)
!39 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!40 = !DIDerivedType(tag: DW_TAG_member, name: "l4_protocol", scope: !35, file: !6, line: 3186, baseType: !38, size: 8, offset: 8)
!41 = !DIDerivedType(tag: DW_TAG_member, name: "sport", scope: !35, file: !6, line: 3187, baseType: !42, size: 16, offset: 16)
!42 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be16", file: !43, line: 25, baseType: !17)
!43 = !DIFile(filename: "/usr/include/linux/types.h", directory: "")
!44 = !DIDerivedType(tag: DW_TAG_member, name: "dport", scope: !35, file: !6, line: 3188, baseType: !42, size: 16, offset: 32)
!45 = !DIDerivedType(tag: DW_TAG_member, name: "tot_len", scope: !35, file: !6, line: 3191, baseType: !17, size: 16, offset: 48)
!46 = !DIDerivedType(tag: DW_TAG_member, name: "ifindex", scope: !35, file: !6, line: 3196, baseType: !47, size: 32, offset: 64)
!47 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u32", file: !18, line: 27, baseType: !7)
!48 = !DIDerivedType(tag: DW_TAG_member, scope: !35, file: !6, line: 3198, baseType: !49, size: 32, offset: 96)
!49 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !35, file: !6, line: 3198, size: 32, elements: !50)
!50 = !{!51, !52, !54}
!51 = !DIDerivedType(tag: DW_TAG_member, name: "tos", scope: !49, file: !6, line: 3200, baseType: !38, size: 8)
!52 = !DIDerivedType(tag: DW_TAG_member, name: "flowinfo", scope: !49, file: !6, line: 3201, baseType: !53, size: 32)
!53 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be32", file: !43, line: 27, baseType: !47)
!54 = !DIDerivedType(tag: DW_TAG_member, name: "rt_metric", scope: !49, file: !6, line: 3204, baseType: !47, size: 32)
!55 = !DIDerivedType(tag: DW_TAG_member, scope: !35, file: !6, line: 3207, baseType: !56, size: 128, offset: 128)
!56 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !35, file: !6, line: 3207, size: 128, elements: !57)
!57 = !{!58, !59}
!58 = !DIDerivedType(tag: DW_TAG_member, name: "ipv4_src", scope: !56, file: !6, line: 3208, baseType: !53, size: 32)
!59 = !DIDerivedType(tag: DW_TAG_member, name: "ipv6_src", scope: !56, file: !6, line: 3209, baseType: !60, size: 128)
!60 = !DICompositeType(tag: DW_TAG_array_type, baseType: !47, size: 128, elements: !25)
!61 = !DIDerivedType(tag: DW_TAG_member, scope: !35, file: !6, line: 3216, baseType: !62, size: 128, offset: 256)
!62 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !35, file: !6, line: 3216, size: 128, elements: !63)
!63 = !{!64, !65}
!64 = !DIDerivedType(tag: DW_TAG_member, name: "ipv4_dst", scope: !62, file: !6, line: 3217, baseType: !53, size: 32)
!65 = !DIDerivedType(tag: DW_TAG_member, name: "ipv6_dst", scope: !62, file: !6, line: 3218, baseType: !60, size: 128)
!66 = !DIDerivedType(tag: DW_TAG_member, name: "h_vlan_proto", scope: !35, file: !6, line: 3222, baseType: !42, size: 16, offset: 384)
!67 = !DIDerivedType(tag: DW_TAG_member, name: "h_vlan_TCI", scope: !35, file: !6, line: 3223, baseType: !42, size: 16, offset: 400)
!68 = !DIDerivedType(tag: DW_TAG_member, name: "smac", scope: !35, file: !6, line: 3224, baseType: !69, size: 48, offset: 416)
!69 = !DICompositeType(tag: DW_TAG_array_type, baseType: !38, size: 48, elements: !70)
!70 = !{!71}
!71 = !DISubrange(count: 6)
!72 = !DIDerivedType(tag: DW_TAG_member, name: "dmac", scope: !35, file: !6, line: 3225, baseType: !69, size: 48, offset: 464)
!73 = !DIGlobalVariableExpression(var: !74, expr: !DIExpression())
!74 = distinct !DIGlobalVariable(name: "bpf_redirect_map", scope: !2, file: !29, line: 1254, type: !75, isLocal: true, isDefinition: true)
!75 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !76, size: 64)
!76 = !DISubroutineType(types: !77)
!77 = !{!33, !15, !47, !78}
!78 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u64", file: !18, line: 31, baseType: !79)
!79 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!80 = !DIGlobalVariableExpression(var: !81, expr: !DIExpression())
!81 = distinct !DIGlobalVariable(name: "bpf_trace_printk", scope: !2, file: !29, line: 152, type: !82, isLocal: true, isDefinition: true)
!82 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !83, size: 64)
!83 = !DISubroutineType(types: !84)
!84 = !{!33, !85, !47, null}
!85 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !86, size: 64)
!86 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !24)
!87 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "bpf_map_def", file: !88, line: 33, size: 160, elements: !89)
!88 = !DIFile(filename: "/usr/include/bpf/bpf_helpers.h", directory: "")
!89 = !{!90, !91, !92, !93, !94}
!90 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !87, file: !88, line: 34, baseType: !7, size: 32)
!91 = !DIDerivedType(tag: DW_TAG_member, name: "key_size", scope: !87, file: !88, line: 35, baseType: !7, size: 32, offset: 32)
!92 = !DIDerivedType(tag: DW_TAG_member, name: "value_size", scope: !87, file: !88, line: 36, baseType: !7, size: 32, offset: 64)
!93 = !DIDerivedType(tag: DW_TAG_member, name: "max_entries", scope: !87, file: !88, line: 37, baseType: !7, size: 32, offset: 96)
!94 = !DIDerivedType(tag: DW_TAG_member, name: "map_flags", scope: !87, file: !88, line: 38, baseType: !7, size: 32, offset: 128)
!95 = !{i32 7, !"Dwarf Version", i32 4}
!96 = !{i32 2, !"Debug Info Version", i32 3}
!97 = !{i32 1, !"wchar_size", i32 4}
!98 = !{!"clang version 10.0.0-4ubuntu1 "}
!99 = distinct !DISubprogram(name: "xdp_router_func", scope: !3, file: !3, line: 33, type: !100, scopeLine: 34, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !110)
!100 = !DISubroutineType(types: !101)
!101 = !{!33, !102}
!102 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !103, size: 64)
!103 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "xdp_md", file: !6, line: 2856, size: 160, elements: !104)
!104 = !{!105, !106, !107, !108, !109}
!105 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !103, file: !6, line: 2857, baseType: !47, size: 32)
!106 = !DIDerivedType(tag: DW_TAG_member, name: "data_end", scope: !103, file: !6, line: 2858, baseType: !47, size: 32, offset: 32)
!107 = !DIDerivedType(tag: DW_TAG_member, name: "data_meta", scope: !103, file: !6, line: 2859, baseType: !47, size: 32, offset: 64)
!108 = !DIDerivedType(tag: DW_TAG_member, name: "ingress_ifindex", scope: !103, file: !6, line: 2861, baseType: !47, size: 32, offset: 96)
!109 = !DIDerivedType(tag: DW_TAG_member, name: "rx_queue_index", scope: !103, file: !6, line: 2862, baseType: !47, size: 32, offset: 128)
!110 = !{!111, !112, !113, !114, !115, !124, !141, !142, !143, !144, !145, !150}
!111 = !DILocalVariable(name: "ctx", arg: 1, scope: !99, file: !3, line: 33, type: !102)
!112 = !DILocalVariable(name: "data_end", scope: !99, file: !3, line: 35, type: !15)
!113 = !DILocalVariable(name: "data", scope: !99, file: !3, line: 36, type: !15)
!114 = !DILocalVariable(name: "fib_params", scope: !99, file: !3, line: 37, type: !35)
!115 = !DILocalVariable(name: "eth", scope: !99, file: !3, line: 38, type: !116)
!116 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !117, size: 64)
!117 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ethhdr", file: !118, line: 163, size: 112, elements: !119)
!118 = !DIFile(filename: "/usr/include/linux/if_ether.h", directory: "")
!119 = !{!120, !122, !123}
!120 = !DIDerivedType(tag: DW_TAG_member, name: "h_dest", scope: !117, file: !118, line: 164, baseType: !121, size: 48)
!121 = !DICompositeType(tag: DW_TAG_array_type, baseType: !39, size: 48, elements: !70)
!122 = !DIDerivedType(tag: DW_TAG_member, name: "h_source", scope: !117, file: !118, line: 165, baseType: !121, size: 48, offset: 48)
!123 = !DIDerivedType(tag: DW_TAG_member, name: "h_proto", scope: !117, file: !118, line: 166, baseType: !42, size: 16, offset: 96)
!124 = !DILocalVariable(name: "iph", scope: !99, file: !3, line: 39, type: !125)
!125 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !126, size: 64)
!126 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "iphdr", file: !127, line: 86, size: 160, elements: !128)
!127 = !DIFile(filename: "/usr/include/linux/ip.h", directory: "")
!128 = !{!129, !130, !131, !132, !133, !134, !135, !136, !137, !139, !140}
!129 = !DIDerivedType(tag: DW_TAG_member, name: "ihl", scope: !126, file: !127, line: 88, baseType: !38, size: 4, flags: DIFlagBitField, extraData: i64 0)
!130 = !DIDerivedType(tag: DW_TAG_member, name: "version", scope: !126, file: !127, line: 89, baseType: !38, size: 4, offset: 4, flags: DIFlagBitField, extraData: i64 0)
!131 = !DIDerivedType(tag: DW_TAG_member, name: "tos", scope: !126, file: !127, line: 96, baseType: !38, size: 8, offset: 8)
!132 = !DIDerivedType(tag: DW_TAG_member, name: "tot_len", scope: !126, file: !127, line: 97, baseType: !42, size: 16, offset: 16)
!133 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !126, file: !127, line: 98, baseType: !42, size: 16, offset: 32)
!134 = !DIDerivedType(tag: DW_TAG_member, name: "frag_off", scope: !126, file: !127, line: 99, baseType: !42, size: 16, offset: 48)
!135 = !DIDerivedType(tag: DW_TAG_member, name: "ttl", scope: !126, file: !127, line: 100, baseType: !38, size: 8, offset: 64)
!136 = !DIDerivedType(tag: DW_TAG_member, name: "protocol", scope: !126, file: !127, line: 101, baseType: !38, size: 8, offset: 72)
!137 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !126, file: !127, line: 102, baseType: !138, size: 16, offset: 80)
!138 = !DIDerivedType(tag: DW_TAG_typedef, name: "__sum16", file: !43, line: 31, baseType: !17)
!139 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !126, file: !127, line: 103, baseType: !53, size: 32, offset: 96)
!140 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !126, file: !127, line: 104, baseType: !53, size: 32, offset: 128)
!141 = !DILocalVariable(name: "h_proto", scope: !99, file: !3, line: 40, type: !17)
!142 = !DILocalVariable(name: "nh_off", scope: !99, file: !3, line: 41, type: !78)
!143 = !DILocalVariable(name: "rc", scope: !99, file: !3, line: 42, type: !33)
!144 = !DILocalVariable(name: "action", scope: !99, file: !3, line: 43, type: !33)
!145 = !DILocalVariable(name: "____fmt", scope: !146, file: !3, line: 102, type: !147)
!146 = distinct !DILexicalBlock(scope: !99, file: !3, line: 102, column: 5)
!147 = !DICompositeType(tag: DW_TAG_array_type, baseType: !24, size: 184, elements: !148)
!148 = !{!149}
!149 = !DISubrange(count: 23)
!150 = !DILabel(scope: !99, name: "out", file: !3, line: 101)
!151 = !DILocation(line: 0, scope: !99)
!152 = !DILocation(line: 35, column: 38, scope: !99)
!153 = !{!154, !155, i64 4}
!154 = !{!"xdp_md", !155, i64 0, !155, i64 4, !155, i64 8, !155, i64 12, !155, i64 16}
!155 = !{!"int", !156, i64 0}
!156 = !{!"omnipotent char", !157, i64 0}
!157 = !{!"Simple C/C++ TBAA"}
!158 = !DILocation(line: 35, column: 27, scope: !99)
!159 = !DILocation(line: 35, column: 19, scope: !99)
!160 = !DILocation(line: 36, column: 34, scope: !99)
!161 = !{!154, !155, i64 0}
!162 = !DILocation(line: 36, column: 23, scope: !99)
!163 = !DILocation(line: 36, column: 15, scope: !99)
!164 = !DILocation(line: 37, column: 2, scope: !99)
!165 = !DILocation(line: 37, column: 24, scope: !99)
!166 = !DILocation(line: 38, column: 23, scope: !99)
!167 = !DILocation(line: 46, column: 11, scope: !168)
!168 = distinct !DILexicalBlock(scope: !99, file: !3, line: 46, column: 6)
!169 = !DILocation(line: 46, column: 20, scope: !168)
!170 = !DILocation(line: 46, column: 6, scope: !99)
!171 = !DILocation(line: 51, column: 17, scope: !99)
!172 = !{!173, !174, i64 12}
!173 = !{!"ethhdr", !156, i64 0, !156, i64 6, !174, i64 12}
!174 = !{!"short", !156, i64 0}
!175 = !DILocation(line: 52, column: 14, scope: !176)
!176 = distinct !DILexicalBlock(scope: !99, file: !3, line: 52, column: 6)
!177 = !DILocation(line: 52, column: 6, scope: !99)
!178 = !DILocation(line: 55, column: 11, scope: !179)
!179 = distinct !DILexicalBlock(scope: !180, file: !3, line: 55, column: 7)
!180 = distinct !DILexicalBlock(scope: !176, file: !3, line: 52, column: 38)
!181 = !DILocation(line: 55, column: 17, scope: !179)
!182 = !DILocation(line: 55, column: 15, scope: !179)
!183 = !DILocation(line: 55, column: 7, scope: !180)
!184 = !DILocation(line: 60, column: 12, scope: !185)
!185 = distinct !DILexicalBlock(scope: !180, file: !3, line: 60, column: 7)
!186 = !{!187, !156, i64 8}
!187 = !{!"iphdr", !156, i64 0, !156, i64 0, !156, i64 1, !174, i64 2, !174, i64 4, !174, i64 6, !156, i64 8, !156, i64 9, !174, i64 10, !155, i64 12, !155, i64 16}
!188 = !DILocation(line: 60, column: 16, scope: !185)
!189 = !DILocation(line: 60, column: 7, scope: !180)
!190 = !DILocation(line: 63, column: 27, scope: !180)
!191 = !{!192, !156, i64 0}
!192 = !{!"bpf_fib_lookup", !156, i64 0, !156, i64 1, !174, i64 2, !174, i64 4, !174, i64 6, !155, i64 8, !156, i64 12, !156, i64 16, !156, i64 32, !174, i64 48, !174, i64 50, !156, i64 52, !156, i64 58}
!193 = !DILocation(line: 64, column: 26, scope: !180)
!194 = !{!187, !156, i64 1}
!195 = !DILocation(line: 64, column: 14, scope: !180)
!196 = !DILocation(line: 64, column: 19, scope: !180)
!197 = !{!156, !156, i64 0}
!198 = !DILocation(line: 65, column: 33, scope: !180)
!199 = !{!187, !156, i64 9}
!200 = !DILocation(line: 65, column: 14, scope: !180)
!201 = !DILocation(line: 65, column: 26, scope: !180)
!202 = !{!192, !156, i64 1}
!203 = !DILocation(line: 66, column: 14, scope: !180)
!204 = !DILocation(line: 66, column: 20, scope: !180)
!205 = !{!192, !174, i64 2}
!206 = !DILocation(line: 67, column: 14, scope: !180)
!207 = !DILocation(line: 67, column: 20, scope: !180)
!208 = !{!192, !174, i64 4}
!209 = !DILocation(line: 68, column: 24, scope: !180)
!210 = !{!187, !174, i64 2}
!211 = !DILocation(line: 68, column: 14, scope: !180)
!212 = !DILocation(line: 68, column: 22, scope: !180)
!213 = !{!192, !174, i64 6}
!214 = !DILocation(line: 69, column: 30, scope: !180)
!215 = !{!187, !155, i64 12}
!216 = !DILocation(line: 69, column: 14, scope: !180)
!217 = !DILocation(line: 69, column: 23, scope: !180)
!218 = !DILocation(line: 70, column: 30, scope: !180)
!219 = !{!187, !155, i64 16}
!220 = !DILocation(line: 70, column: 14, scope: !180)
!221 = !DILocation(line: 70, column: 23, scope: !180)
!222 = !DILocation(line: 75, column: 28, scope: !99)
!223 = !{!154, !155, i64 12}
!224 = !DILocation(line: 75, column: 13, scope: !99)
!225 = !DILocation(line: 75, column: 21, scope: !99)
!226 = !{!192, !155, i64 8}
!227 = !DILocation(line: 77, column: 22, scope: !99)
!228 = !DILocation(line: 77, column: 7, scope: !99)
!229 = !DILocation(line: 78, column: 2, scope: !99)
!230 = !DILocalVariable(name: "iph", arg: 1, scope: !231, file: !3, line: 26, type: !125)
!231 = distinct !DISubprogram(name: "ip_decrease_ttl", scope: !3, file: !3, line: 26, type: !232, scopeLine: 27, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !234)
!232 = !DISubroutineType(types: !233)
!233 = !{!33, !125}
!234 = !{!230}
!235 = !DILocation(line: 0, scope: !231, inlinedAt: !236)
!236 = distinct !DILocation(line: 81, column: 4, scope: !237)
!237 = distinct !DILexicalBlock(scope: !238, file: !3, line: 80, column: 7)
!238 = distinct !DILexicalBlock(scope: !99, file: !3, line: 78, column: 14)
!239 = !DILocation(line: 29, column: 9, scope: !231, inlinedAt: !236)
!240 = !DILocation(line: 83, column: 3, scope: !238)
!241 = !DILocation(line: 84, column: 3, scope: !238)
!242 = !DILocation(line: 85, column: 50, scope: !238)
!243 = !DILocation(line: 85, column: 12, scope: !238)
!244 = !DILocation(line: 86, column: 3, scope: !238)
!245 = !DILocation(line: 91, column: 3, scope: !238)
!246 = !DILocation(line: 101, column: 1, scope: !99)
!247 = !DILocation(line: 102, column: 5, scope: !146)
!248 = !DILocation(line: 102, column: 5, scope: !99)
!249 = !DILocation(line: 104, column: 1, scope: !99)
!250 = !DILocation(line: 103, column: 5, scope: !99)
!251 = distinct !DISubprogram(name: "xdp_pass_func", scope: !3, file: !3, line: 107, type: !100, scopeLine: 108, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !252)
!252 = !{!253}
!253 = !DILocalVariable(name: "ctx", arg: 1, scope: !251, file: !3, line: 107, type: !102)
!254 = !DILocation(line: 0, scope: !251)
!255 = !DILocation(line: 109, column: 2, scope: !251)
