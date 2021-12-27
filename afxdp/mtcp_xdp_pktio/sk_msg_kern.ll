; ModuleID = 'sk_msg_kern.c'
source_filename = "sk_msg_kern.c"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf"

%struct.bpf_map_def = type { i32, i32, i32, i32, i32 }
%struct.sk_msg_md = type { %union.anon, %union.anon.0, i32, i32, i32, [4 x i32], [4 x i32], i32, i32, i32 }
%union.anon = type { i8* }
%union.anon.0 = type { i8* }

@sock_map = dso_local global %struct.bpf_map_def { i32 15, i32 4, i32 4, i32 16, i32 0 }, section "maps", align 4, !dbg !0
@__const.bpf_tcpip_bypass.____fmt = private unnamed_addr constant [35 x i8] c"[sk_msg] get a packet of length %d\00", align 1
@__const.bpf_tcpip_bypass.____fmt.1 = private unnamed_addr constant [49 x i8] c"[sk_msg] redirect to socket at array position %d\00", align 1
@_license = dso_local global [4 x i8] c"GPL\00", section "license", align 1, !dbg !15
@llvm.used = appending global [3 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (i32 (%struct.sk_msg_md*)* @bpf_tcpip_bypass to i8*), i8* bitcast (%struct.bpf_map_def* @sock_map to i8*)], section "llvm.metadata"

; Function Attrs: nounwind
define dso_local i32 @bpf_tcpip_bypass(%struct.sk_msg_md* %0) #0 section "sk_msg" !dbg !71 {
  %2 = alloca [35 x i8], align 1
  %3 = alloca [49 x i8], align 1
  call void @llvm.dbg.value(metadata %struct.sk_msg_md* %0, metadata !75, metadata !DIExpression()), !dbg !90
  %4 = getelementptr inbounds %struct.sk_msg_md, %struct.sk_msg_md* %0, i64 0, i32 0, i32 0, !dbg !91
  %5 = load i8*, i8** %4, align 8, !dbg !91, !tbaa !92
  call void @llvm.dbg.value(metadata i8* %5, metadata !76, metadata !DIExpression()), !dbg !90
  %6 = getelementptr inbounds %struct.sk_msg_md, %struct.sk_msg_md* %0, i64 0, i32 1, i32 0, !dbg !95
  %7 = load i8*, i8** %6, align 8, !dbg !95, !tbaa !92
  call void @llvm.dbg.value(metadata i8* %7, metadata !78, metadata !DIExpression()), !dbg !90
  %8 = getelementptr inbounds [35 x i8], [35 x i8]* %2, i64 0, i64 0, !dbg !96
  call void @llvm.lifetime.start.p0i8(i64 35, i8* nonnull %8) #3, !dbg !96
  call void @llvm.dbg.declare(metadata [35 x i8]* %2, metadata !79, metadata !DIExpression()), !dbg !96
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 dereferenceable(35) %8, i8* nonnull align 1 dereferenceable(35) getelementptr inbounds ([35 x i8], [35 x i8]* @__const.bpf_tcpip_bypass.____fmt, i64 0, i64 0), i64 35, i1 false), !dbg !96
  %9 = getelementptr inbounds %struct.sk_msg_md, %struct.sk_msg_md* %0, i64 0, i32 9, !dbg !96
  %10 = load i32, i32* %9, align 4, !dbg !96, !tbaa !97
  %11 = call i32 (i8*, i32, ...) inttoptr (i64 6 to i32 (i8*, i32, ...)*)(i8* nonnull %8, i32 35, i32 %10) #3, !dbg !96
  call void @llvm.lifetime.end.p0i8(i64 35, i8* nonnull %8) #3, !dbg !100
  %12 = getelementptr inbounds i8, i8* %5, i64 4, !dbg !101
  %13 = icmp ugt i8* %12, %7, !dbg !103
  br i1 %13, label %20, label %14, !dbg !104

14:                                               ; preds = %1
  %15 = bitcast i8* %5 to i32*, !dbg !105
  %16 = load i32, i32* %15, align 4, !dbg !105, !tbaa !106
  call void @llvm.dbg.value(metadata i32 %16, metadata !84, metadata !DIExpression()), !dbg !90
  %17 = getelementptr inbounds [49 x i8], [49 x i8]* %3, i64 0, i64 0, !dbg !107
  call void @llvm.lifetime.start.p0i8(i64 49, i8* nonnull %17) #3, !dbg !107
  call void @llvm.dbg.declare(metadata [49 x i8]* %3, metadata !85, metadata !DIExpression()), !dbg !107
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 dereferenceable(49) %17, i8* nonnull align 1 dereferenceable(49) getelementptr inbounds ([49 x i8], [49 x i8]* @__const.bpf_tcpip_bypass.____fmt.1, i64 0, i64 0), i64 49, i1 false), !dbg !107
  %18 = call i32 (i8*, i32, ...) inttoptr (i64 6 to i32 (i8*, i32, ...)*)(i8* nonnull %17, i32 49, i32 %16) #3, !dbg !107
  call void @llvm.lifetime.end.p0i8(i64 49, i8* nonnull %17) #3, !dbg !108
  %19 = call i32 inttoptr (i64 60 to i32 (%struct.sk_msg_md*, i8*, i32, i64)*)(%struct.sk_msg_md* nonnull %0, i8* bitcast (%struct.bpf_map_def* @sock_map to i8*), i32 %16, i64 1) #3, !dbg !109
  br label %20

20:                                               ; preds = %1, %14
  %21 = phi i32 [ %19, %14 ], [ 0, %1 ], !dbg !90
  ret i32 %21, !dbg !110
}

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #1

attributes #0 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { argmemonly nounwind willreturn }
attributes #3 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!67, !68, !69}
!llvm.ident = !{!70}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "sock_map", scope: !2, file: !3, line: 28, type: !59, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 10.0.0-4ubuntu1 ", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !11, globals: !14, splitDebugInlining: false, nameTableKind: None)
!3 = !DIFile(filename: "sk_msg_kern.c", directory: "/mydata/mtcp/afxdp/mtcp_xdp_pktio")
!4 = !{!5}
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "sk_action", file: !6, line: 2865, baseType: !7, size: 32, elements: !8)
!6 = !DIFile(filename: "../headers/linux/bpf.h", directory: "/mydata/mtcp/afxdp/mtcp_xdp_pktio")
!7 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!8 = !{!9, !10}
!9 = !DIEnumerator(name: "SK_DROP", value: 0, isUnsigned: true)
!10 = !DIEnumerator(name: "SK_PASS", value: 1, isUnsigned: true)
!11 = !{!12}
!12 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !13, size: 64)
!13 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!14 = !{!0, !15, !21, !31}
!15 = !DIGlobalVariableExpression(var: !16, expr: !DIExpression())
!16 = distinct !DIGlobalVariable(name: "_license", scope: !2, file: !3, line: 61, type: !17, isLocal: false, isDefinition: true)
!17 = !DICompositeType(tag: DW_TAG_array_type, baseType: !18, size: 32, elements: !19)
!18 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!19 = !{!20}
!20 = !DISubrange(count: 4)
!21 = !DIGlobalVariableExpression(var: !22, expr: !DIExpression())
!22 = distinct !DIGlobalVariable(name: "bpf_trace_printk", scope: !2, file: !23, line: 152, type: !24, isLocal: true, isDefinition: true)
!23 = !DIFile(filename: "/usr/include/bpf/bpf_helper_defs.h", directory: "")
!24 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !25, size: 64)
!25 = !DISubroutineType(types: !26)
!26 = !{!13, !27, !29, null}
!27 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !28, size: 64)
!28 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !18)
!29 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u32", file: !30, line: 27, baseType: !7)
!30 = !DIFile(filename: "/usr/include/asm-generic/int-ll64.h", directory: "")
!31 = !DIGlobalVariableExpression(var: !32, expr: !DIExpression())
!32 = distinct !DIGlobalVariable(name: "bpf_msg_redirect_map", scope: !2, file: !23, line: 1512, type: !33, isLocal: true, isDefinition: true)
!33 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !34, size: 64)
!34 = !DISubroutineType(types: !35)
!35 = !{!13, !36, !43, !29, !57}
!36 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !37, size: 64)
!37 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sk_msg_md", file: !6, line: 2873, size: 576, elements: !38)
!38 = !{!39, !44, !48, !49, !50, !51, !53, !54, !55, !56}
!39 = !DIDerivedType(tag: DW_TAG_member, scope: !37, file: !6, line: 2874, baseType: !40, size: 64, align: 64)
!40 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !37, file: !6, line: 2874, size: 64, align: 64, elements: !41)
!41 = !{!42}
!42 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !40, file: !6, line: 2874, baseType: !43, size: 64)
!43 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!44 = !DIDerivedType(tag: DW_TAG_member, scope: !37, file: !6, line: 2875, baseType: !45, size: 64, align: 64, offset: 64)
!45 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !37, file: !6, line: 2875, size: 64, align: 64, elements: !46)
!46 = !{!47}
!47 = !DIDerivedType(tag: DW_TAG_member, name: "data_end", scope: !45, file: !6, line: 2875, baseType: !43, size: 64)
!48 = !DIDerivedType(tag: DW_TAG_member, name: "family", scope: !37, file: !6, line: 2877, baseType: !29, size: 32, offset: 128)
!49 = !DIDerivedType(tag: DW_TAG_member, name: "remote_ip4", scope: !37, file: !6, line: 2878, baseType: !29, size: 32, offset: 160)
!50 = !DIDerivedType(tag: DW_TAG_member, name: "local_ip4", scope: !37, file: !6, line: 2879, baseType: !29, size: 32, offset: 192)
!51 = !DIDerivedType(tag: DW_TAG_member, name: "remote_ip6", scope: !37, file: !6, line: 2880, baseType: !52, size: 128, offset: 224)
!52 = !DICompositeType(tag: DW_TAG_array_type, baseType: !29, size: 128, elements: !19)
!53 = !DIDerivedType(tag: DW_TAG_member, name: "local_ip6", scope: !37, file: !6, line: 2881, baseType: !52, size: 128, offset: 352)
!54 = !DIDerivedType(tag: DW_TAG_member, name: "remote_port", scope: !37, file: !6, line: 2882, baseType: !29, size: 32, offset: 480)
!55 = !DIDerivedType(tag: DW_TAG_member, name: "local_port", scope: !37, file: !6, line: 2883, baseType: !29, size: 32, offset: 512)
!56 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !37, file: !6, line: 2884, baseType: !29, size: 32, offset: 544)
!57 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u64", file: !30, line: 31, baseType: !58)
!58 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!59 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "bpf_map_def", file: !60, line: 33, size: 160, elements: !61)
!60 = !DIFile(filename: "/usr/include/bpf/bpf_helpers.h", directory: "")
!61 = !{!62, !63, !64, !65, !66}
!62 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !59, file: !60, line: 34, baseType: !7, size: 32)
!63 = !DIDerivedType(tag: DW_TAG_member, name: "key_size", scope: !59, file: !60, line: 35, baseType: !7, size: 32, offset: 32)
!64 = !DIDerivedType(tag: DW_TAG_member, name: "value_size", scope: !59, file: !60, line: 36, baseType: !7, size: 32, offset: 64)
!65 = !DIDerivedType(tag: DW_TAG_member, name: "max_entries", scope: !59, file: !60, line: 37, baseType: !7, size: 32, offset: 96)
!66 = !DIDerivedType(tag: DW_TAG_member, name: "map_flags", scope: !59, file: !60, line: 38, baseType: !7, size: 32, offset: 128)
!67 = !{i32 7, !"Dwarf Version", i32 4}
!68 = !{i32 2, !"Debug Info Version", i32 3}
!69 = !{i32 1, !"wchar_size", i32 4}
!70 = !{!"clang version 10.0.0-4ubuntu1 "}
!71 = distinct !DISubprogram(name: "bpf_tcpip_bypass", scope: !3, file: !3, line: 38, type: !72, scopeLine: 39, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !74)
!72 = !DISubroutineType(types: !73)
!73 = !{!13, !36}
!74 = !{!75, !76, !78, !79, !84, !85}
!75 = !DILocalVariable(name: "msg", arg: 1, scope: !71, file: !3, line: 38, type: !36)
!76 = !DILocalVariable(name: "data", scope: !71, file: !3, line: 40, type: !77)
!77 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !18, size: 64)
!78 = !DILocalVariable(name: "data_end", scope: !71, file: !3, line: 41, type: !77)
!79 = !DILocalVariable(name: "____fmt", scope: !80, file: !3, line: 42, type: !81)
!80 = distinct !DILexicalBlock(scope: !71, file: !3, line: 42, column: 5)
!81 = !DICompositeType(tag: DW_TAG_array_type, baseType: !18, size: 280, elements: !82)
!82 = !{!83}
!83 = !DISubrange(count: 35)
!84 = !DILocalVariable(name: "key", scope: !71, file: !3, line: 47, type: !13)
!85 = !DILocalVariable(name: "____fmt", scope: !86, file: !3, line: 48, type: !87)
!86 = distinct !DILexicalBlock(scope: !71, file: !3, line: 48, column: 5)
!87 = !DICompositeType(tag: DW_TAG_array_type, baseType: !18, size: 392, elements: !88)
!88 = !{!89}
!89 = !DISubrange(count: 49)
!90 = !DILocation(line: 0, scope: !71)
!91 = !DILocation(line: 40, column: 23, scope: !71)
!92 = !{!93, !93, i64 0}
!93 = !{!"omnipotent char", !94, i64 0}
!94 = !{!"Simple C/C++ TBAA"}
!95 = !DILocation(line: 41, column: 27, scope: !71)
!96 = !DILocation(line: 42, column: 5, scope: !80)
!97 = !{!98, !99, i64 68}
!98 = !{!"sk_msg_md", !93, i64 0, !93, i64 8, !99, i64 16, !99, i64 20, !99, i64 24, !93, i64 28, !93, i64 44, !99, i64 60, !99, i64 64, !99, i64 68}
!99 = !{!"int", !93, i64 0}
!100 = !DILocation(line: 42, column: 5, scope: !71)
!101 = !DILocation(line: 44, column: 13, scope: !102)
!102 = distinct !DILexicalBlock(scope: !71, file: !3, line: 44, column: 8)
!103 = !DILocation(line: 44, column: 17, scope: !102)
!104 = !DILocation(line: 44, column: 8, scope: !71)
!105 = !DILocation(line: 47, column: 15, scope: !71)
!106 = !{!99, !99, i64 0}
!107 = !DILocation(line: 48, column: 5, scope: !86)
!108 = !DILocation(line: 48, column: 5, scope: !71)
!109 = !DILocation(line: 50, column: 12, scope: !71)
!110 = !DILocation(line: 59, column: 1, scope: !71)
