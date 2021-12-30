; ModuleID = 'sk_msg_kern.c'
source_filename = "sk_msg_kern.c"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf"

%struct.bpf_map_def = type { i32, i32, i32, i32, i32 }
%struct.sk_msg_md = type { %union.anon, %union.anon.0, i32, i32, i32, [4 x i32], [4 x i32], i32, i32, i32 }
%union.anon = type { i8* }
%union.anon.0 = type { i8* }

@sock_map = dso_local global %struct.bpf_map_def { i32 15, i32 4, i32 4, i32 16, i32 0 }, section "maps", align 4, !dbg !0
@_license = dso_local global [4 x i8] c"GPL\00", section "license", align 1, !dbg !15
@llvm.used = appending global [3 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (i32 (%struct.sk_msg_md*)* @bpf_tcpip_bypass to i8*), i8* bitcast (%struct.bpf_map_def* @sock_map to i8*)], section "llvm.metadata"

; Function Attrs: nounwind
define dso_local i32 @bpf_tcpip_bypass(%struct.sk_msg_md* %0) #0 section "sk_msg" !dbg !64 {
  call void @llvm.dbg.value(metadata %struct.sk_msg_md* %0, metadata !68, metadata !DIExpression()), !dbg !73
  %2 = getelementptr inbounds %struct.sk_msg_md, %struct.sk_msg_md* %0, i64 0, i32 0, i32 0, !dbg !74
  %3 = load i8*, i8** %2, align 8, !dbg !74, !tbaa !75
  call void @llvm.dbg.value(metadata i8* %3, metadata !69, metadata !DIExpression()), !dbg !73
  %4 = getelementptr inbounds %struct.sk_msg_md, %struct.sk_msg_md* %0, i64 0, i32 1, i32 0, !dbg !78
  %5 = load i8*, i8** %4, align 8, !dbg !78, !tbaa !75
  call void @llvm.dbg.value(metadata i8* %5, metadata !71, metadata !DIExpression()), !dbg !73
  %6 = getelementptr inbounds i8, i8* %3, i64 4, !dbg !79
  %7 = icmp ugt i8* %6, %5, !dbg !81
  br i1 %7, label %12, label %8, !dbg !82

8:                                                ; preds = %1
  %9 = bitcast i8* %3 to i32*, !dbg !83
  %10 = load i32, i32* %9, align 4, !dbg !83, !tbaa !84
  call void @llvm.dbg.value(metadata i32 %10, metadata !72, metadata !DIExpression()), !dbg !73
  %11 = tail call i32 inttoptr (i64 60 to i32 (%struct.sk_msg_md*, i8*, i32, i64)*)(%struct.sk_msg_md* nonnull %0, i8* bitcast (%struct.bpf_map_def* @sock_map to i8*), i32 %10, i64 1) #2, !dbg !86
  br label %12

12:                                               ; preds = %1, %8
  %13 = phi i32 [ %11, %8 ], [ 0, %1 ], !dbg !73
  ret i32 %13, !dbg !87
}

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #1

attributes #0 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!60, !61, !62}
!llvm.ident = !{!63}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "sock_map", scope: !2, file: !3, line: 28, type: !52, isLocal: false, isDefinition: true)
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
!14 = !{!0, !15, !21}
!15 = !DIGlobalVariableExpression(var: !16, expr: !DIExpression())
!16 = distinct !DIGlobalVariable(name: "_license", scope: !2, file: !3, line: 61, type: !17, isLocal: false, isDefinition: true)
!17 = !DICompositeType(tag: DW_TAG_array_type, baseType: !18, size: 32, elements: !19)
!18 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!19 = !{!20}
!20 = !DISubrange(count: 4)
!21 = !DIGlobalVariableExpression(var: !22, expr: !DIExpression())
!22 = distinct !DIGlobalVariable(name: "bpf_msg_redirect_map", scope: !2, file: !23, line: 1512, type: !24, isLocal: true, isDefinition: true)
!23 = !DIFile(filename: "/usr/include/bpf/bpf_helper_defs.h", directory: "")
!24 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !25, size: 64)
!25 = !DISubroutineType(types: !26)
!26 = !{!13, !27, !34, !40, !50}
!27 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !28, size: 64)
!28 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sk_msg_md", file: !6, line: 2873, size: 576, elements: !29)
!29 = !{!30, !35, !39, !42, !43, !44, !46, !47, !48, !49}
!30 = !DIDerivedType(tag: DW_TAG_member, scope: !28, file: !6, line: 2874, baseType: !31, size: 64, align: 64)
!31 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !28, file: !6, line: 2874, size: 64, align: 64, elements: !32)
!32 = !{!33}
!33 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !31, file: !6, line: 2874, baseType: !34, size: 64)
!34 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!35 = !DIDerivedType(tag: DW_TAG_member, scope: !28, file: !6, line: 2875, baseType: !36, size: 64, align: 64, offset: 64)
!36 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !28, file: !6, line: 2875, size: 64, align: 64, elements: !37)
!37 = !{!38}
!38 = !DIDerivedType(tag: DW_TAG_member, name: "data_end", scope: !36, file: !6, line: 2875, baseType: !34, size: 64)
!39 = !DIDerivedType(tag: DW_TAG_member, name: "family", scope: !28, file: !6, line: 2877, baseType: !40, size: 32, offset: 128)
!40 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u32", file: !41, line: 27, baseType: !7)
!41 = !DIFile(filename: "/usr/include/asm-generic/int-ll64.h", directory: "")
!42 = !DIDerivedType(tag: DW_TAG_member, name: "remote_ip4", scope: !28, file: !6, line: 2878, baseType: !40, size: 32, offset: 160)
!43 = !DIDerivedType(tag: DW_TAG_member, name: "local_ip4", scope: !28, file: !6, line: 2879, baseType: !40, size: 32, offset: 192)
!44 = !DIDerivedType(tag: DW_TAG_member, name: "remote_ip6", scope: !28, file: !6, line: 2880, baseType: !45, size: 128, offset: 224)
!45 = !DICompositeType(tag: DW_TAG_array_type, baseType: !40, size: 128, elements: !19)
!46 = !DIDerivedType(tag: DW_TAG_member, name: "local_ip6", scope: !28, file: !6, line: 2881, baseType: !45, size: 128, offset: 352)
!47 = !DIDerivedType(tag: DW_TAG_member, name: "remote_port", scope: !28, file: !6, line: 2882, baseType: !40, size: 32, offset: 480)
!48 = !DIDerivedType(tag: DW_TAG_member, name: "local_port", scope: !28, file: !6, line: 2883, baseType: !40, size: 32, offset: 512)
!49 = !DIDerivedType(tag: DW_TAG_member, name: "size", scope: !28, file: !6, line: 2884, baseType: !40, size: 32, offset: 544)
!50 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u64", file: !41, line: 31, baseType: !51)
!51 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!52 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "bpf_map_def", file: !53, line: 33, size: 160, elements: !54)
!53 = !DIFile(filename: "/usr/include/bpf/bpf_helpers.h", directory: "")
!54 = !{!55, !56, !57, !58, !59}
!55 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !52, file: !53, line: 34, baseType: !7, size: 32)
!56 = !DIDerivedType(tag: DW_TAG_member, name: "key_size", scope: !52, file: !53, line: 35, baseType: !7, size: 32, offset: 32)
!57 = !DIDerivedType(tag: DW_TAG_member, name: "value_size", scope: !52, file: !53, line: 36, baseType: !7, size: 32, offset: 64)
!58 = !DIDerivedType(tag: DW_TAG_member, name: "max_entries", scope: !52, file: !53, line: 37, baseType: !7, size: 32, offset: 96)
!59 = !DIDerivedType(tag: DW_TAG_member, name: "map_flags", scope: !52, file: !53, line: 38, baseType: !7, size: 32, offset: 128)
!60 = !{i32 7, !"Dwarf Version", i32 4}
!61 = !{i32 2, !"Debug Info Version", i32 3}
!62 = !{i32 1, !"wchar_size", i32 4}
!63 = !{!"clang version 10.0.0-4ubuntu1 "}
!64 = distinct !DISubprogram(name: "bpf_tcpip_bypass", scope: !3, file: !3, line: 38, type: !65, scopeLine: 39, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !67)
!65 = !DISubroutineType(types: !66)
!66 = !{!13, !27}
!67 = !{!68, !69, !71, !72}
!68 = !DILocalVariable(name: "msg", arg: 1, scope: !64, file: !3, line: 38, type: !27)
!69 = !DILocalVariable(name: "data", scope: !64, file: !3, line: 40, type: !70)
!70 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !18, size: 64)
!71 = !DILocalVariable(name: "data_end", scope: !64, file: !3, line: 41, type: !70)
!72 = !DILocalVariable(name: "key", scope: !64, file: !3, line: 47, type: !13)
!73 = !DILocation(line: 0, scope: !64)
!74 = !DILocation(line: 40, column: 23, scope: !64)
!75 = !{!76, !76, i64 0}
!76 = !{!"omnipotent char", !77, i64 0}
!77 = !{!"Simple C/C++ TBAA"}
!78 = !DILocation(line: 41, column: 27, scope: !64)
!79 = !DILocation(line: 44, column: 13, scope: !80)
!80 = distinct !DILexicalBlock(scope: !64, file: !3, line: 44, column: 8)
!81 = !DILocation(line: 44, column: 17, scope: !80)
!82 = !DILocation(line: 44, column: 8, scope: !64)
!83 = !DILocation(line: 47, column: 15, scope: !64)
!84 = !{!85, !85, i64 0}
!85 = !{!"int", !76, i64 0}
!86 = !DILocation(line: 50, column: 12, scope: !64)
!87 = !DILocation(line: 59, column: 1, scope: !64)
