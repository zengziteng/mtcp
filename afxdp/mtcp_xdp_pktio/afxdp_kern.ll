; ModuleID = 'afxdp_kern.c'
source_filename = "afxdp_kern.c"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf"

%struct.bpf_map_def = type { i32, i32, i32, i32, i32 }
%struct.xdp_md = type { i32, i32, i32, i32, i32 }

@xsks_map = dso_local global %struct.bpf_map_def { i32 17, i32 4, i32 4, i32 64, i32 0 }, section "maps", align 4, !dbg !0
@_license = dso_local global [4 x i8] c"GPL\00", section "license", align 1, !dbg !15
@llvm.used = appending global [3 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (i32 (%struct.xdp_md*)* @xdp_sock_prog to i8*), i8* bitcast (%struct.bpf_map_def* @xsks_map to i8*)], section "llvm.metadata"

; Function Attrs: nounwind
define dso_local i32 @xdp_sock_prog(%struct.xdp_md* nocapture readonly) #0 section "xdp_sock" !dbg !52 {
  %2 = alloca i32, align 4
  call void @llvm.dbg.value(metadata %struct.xdp_md* %0, metadata !64, metadata !DIExpression()), !dbg !66
  %3 = bitcast i32* %2 to i8*, !dbg !67
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %3) #3, !dbg !67
  %4 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 4, !dbg !68
  %5 = load i32, i32* %4, align 4, !dbg !68, !tbaa !69
  call void @llvm.dbg.value(metadata i32 %5, metadata !65, metadata !DIExpression()), !dbg !74
  store i32 %5, i32* %2, align 4, !dbg !74, !tbaa !75
  %6 = call i8* inttoptr (i64 1 to i8* (i8*, i8*)*)(i8* bitcast (%struct.bpf_map_def* @xsks_map to i8*), i8* nonnull %3) #3, !dbg !76
  %7 = icmp eq i8* %6, null, !dbg !76
  br i1 %7, label %11, label %8, !dbg !78

; <label>:8:                                      ; preds = %1
  %9 = load i32, i32* %2, align 4, !dbg !79, !tbaa !75
  call void @llvm.dbg.value(metadata i32 %9, metadata !65, metadata !DIExpression()), !dbg !74
  %10 = call i32 inttoptr (i64 51 to i32 (i8*, i32, i64)*)(i8* bitcast (%struct.bpf_map_def* @xsks_map to i8*), i32 %9, i64 0) #3, !dbg !80
  br label %11, !dbg !81

; <label>:11:                                     ; preds = %1, %8
  %12 = phi i32 [ %10, %8 ], [ 2, %1 ], !dbg !82
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %3) #3, !dbg !83
  ret i32 %12, !dbg !83
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.value(metadata, metadata, metadata) #2

attributes #0 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { nounwind readnone speculatable }
attributes #3 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!48, !49, !50}
!llvm.ident = !{!51}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "xsks_map", scope: !2, file: !3, line: 11, type: !40, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 8.0.0-3 (tags/RELEASE_800/final)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, globals: !14, nameTableKind: None)
!3 = !DIFile(filename: "afxdp_kern.c", directory: "/home/vagrant/mtcp/afxdp/mtcp_xdp_pktio")
!4 = !{!5}
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "xdp_action", file: !6, line: 2845, baseType: !7, size: 32, elements: !8)
!6 = !DIFile(filename: "../headers/linux/bpf.h", directory: "/home/vagrant/mtcp/afxdp/mtcp_xdp_pktio")
!7 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!8 = !{!9, !10, !11, !12, !13}
!9 = !DIEnumerator(name: "XDP_ABORTED", value: 0, isUnsigned: true)
!10 = !DIEnumerator(name: "XDP_DROP", value: 1, isUnsigned: true)
!11 = !DIEnumerator(name: "XDP_PASS", value: 2, isUnsigned: true)
!12 = !DIEnumerator(name: "XDP_TX", value: 3, isUnsigned: true)
!13 = !DIEnumerator(name: "XDP_REDIRECT", value: 4, isUnsigned: true)
!14 = !{!0, !15, !21, !30}
!15 = !DIGlobalVariableExpression(var: !16, expr: !DIExpression())
!16 = distinct !DIGlobalVariable(name: "_license", scope: !2, file: !3, line: 32, type: !17, isLocal: false, isDefinition: true)
!17 = !DICompositeType(tag: DW_TAG_array_type, baseType: !18, size: 32, elements: !19)
!18 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!19 = !{!20}
!20 = !DISubrange(count: 4)
!21 = !DIGlobalVariableExpression(var: !22, expr: !DIExpression())
!22 = distinct !DIGlobalVariable(name: "bpf_map_lookup_elem", scope: !2, file: !23, line: 33, type: !24, isLocal: true, isDefinition: true)
!23 = !DIFile(filename: "/usr/include/bpf/bpf_helper_defs.h", directory: "")
!24 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !25, size: 64)
!25 = !DISubroutineType(types: !26)
!26 = !{!27, !27, !28}
!27 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!28 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !29, size: 64)
!29 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!30 = !DIGlobalVariableExpression(var: !31, expr: !DIExpression())
!31 = distinct !DIGlobalVariable(name: "bpf_redirect_map", scope: !2, file: !23, line: 1254, type: !32, isLocal: true, isDefinition: true)
!32 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !33, size: 64)
!33 = !DISubroutineType(types: !34)
!34 = !{!35, !27, !36, !38}
!35 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!36 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u32", file: !37, line: 27, baseType: !7)
!37 = !DIFile(filename: "/usr/include/asm-generic/int-ll64.h", directory: "")
!38 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u64", file: !37, line: 31, baseType: !39)
!39 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!40 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "bpf_map_def", file: !41, line: 33, size: 160, elements: !42)
!41 = !DIFile(filename: "/usr/include/bpf/bpf_helpers.h", directory: "")
!42 = !{!43, !44, !45, !46, !47}
!43 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !40, file: !41, line: 34, baseType: !7, size: 32)
!44 = !DIDerivedType(tag: DW_TAG_member, name: "key_size", scope: !40, file: !41, line: 35, baseType: !7, size: 32, offset: 32)
!45 = !DIDerivedType(tag: DW_TAG_member, name: "value_size", scope: !40, file: !41, line: 36, baseType: !7, size: 32, offset: 64)
!46 = !DIDerivedType(tag: DW_TAG_member, name: "max_entries", scope: !40, file: !41, line: 37, baseType: !7, size: 32, offset: 96)
!47 = !DIDerivedType(tag: DW_TAG_member, name: "map_flags", scope: !40, file: !41, line: 38, baseType: !7, size: 32, offset: 128)
!48 = !{i32 2, !"Dwarf Version", i32 4}
!49 = !{i32 2, !"Debug Info Version", i32 3}
!50 = !{i32 1, !"wchar_size", i32 4}
!51 = !{!"clang version 8.0.0-3 (tags/RELEASE_800/final)"}
!52 = distinct !DISubprogram(name: "xdp_sock_prog", scope: !3, file: !3, line: 20, type: !53, scopeLine: 21, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !63)
!53 = !DISubroutineType(types: !54)
!54 = !{!35, !55}
!55 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !56, size: 64)
!56 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "xdp_md", file: !6, line: 2856, size: 160, elements: !57)
!57 = !{!58, !59, !60, !61, !62}
!58 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !56, file: !6, line: 2857, baseType: !36, size: 32)
!59 = !DIDerivedType(tag: DW_TAG_member, name: "data_end", scope: !56, file: !6, line: 2858, baseType: !36, size: 32, offset: 32)
!60 = !DIDerivedType(tag: DW_TAG_member, name: "data_meta", scope: !56, file: !6, line: 2859, baseType: !36, size: 32, offset: 64)
!61 = !DIDerivedType(tag: DW_TAG_member, name: "ingress_ifindex", scope: !56, file: !6, line: 2861, baseType: !36, size: 32, offset: 96)
!62 = !DIDerivedType(tag: DW_TAG_member, name: "rx_queue_index", scope: !56, file: !6, line: 2862, baseType: !36, size: 32, offset: 128)
!63 = !{!64, !65}
!64 = !DILocalVariable(name: "ctx", arg: 1, scope: !52, file: !3, line: 20, type: !55)
!65 = !DILocalVariable(name: "index", scope: !52, file: !3, line: 23, type: !35)
!66 = !DILocation(line: 20, column: 34, scope: !52)
!67 = !DILocation(line: 23, column: 5, scope: !52)
!68 = !DILocation(line: 23, column: 22, scope: !52)
!69 = !{!70, !71, i64 16}
!70 = !{!"xdp_md", !71, i64 0, !71, i64 4, !71, i64 8, !71, i64 12, !71, i64 16}
!71 = !{!"int", !72, i64 0}
!72 = !{!"omnipotent char", !73, i64 0}
!73 = !{!"Simple C/C++ TBAA"}
!74 = !DILocation(line: 23, column: 9, scope: !52)
!75 = !{!71, !71, i64 0}
!76 = !DILocation(line: 26, column: 9, scope: !77)
!77 = distinct !DILexicalBlock(scope: !52, file: !3, line: 26, column: 9)
!78 = !DILocation(line: 26, column: 9, scope: !52)
!79 = !DILocation(line: 27, column: 44, scope: !77)
!80 = !DILocation(line: 27, column: 16, scope: !77)
!81 = !DILocation(line: 27, column: 9, scope: !77)
!82 = !DILocation(line: 0, scope: !77)
!83 = !DILocation(line: 30, column: 1, scope: !52)
