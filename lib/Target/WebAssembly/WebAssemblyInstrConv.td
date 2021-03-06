//===-- WebAssemblyInstrConv.td-WebAssembly Conversion support -*- tablegen -*-=
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
///
/// \file
/// \brief WebAssembly datatype conversions, truncations, reinterpretations,
/// promotions, and demotions operand code-gen constructs.
///
//===----------------------------------------------------------------------===//

def I32_WRAP_I64 : I<(outs I32:$dst), (ins I64:$src),
                     [(set I32:$dst, (trunc I64:$src))]>;

def I64_EXTEND_S_I32 : I<(outs I64:$dst), (ins I32:$src),
                         [(set I64:$dst, (sext I32:$src))]>;
def I64_EXTEND_U_I32 : I<(outs I64:$dst), (ins I32:$src),
                         [(set I64:$dst, (zext I32:$src))]>;

def I32_TRUNC_S_F32 : I<(outs I32:$dst), (ins F32:$src),
                        [(set I32:$dst, (fp_to_sint F32:$src))]>;
def I32_TRUNC_U_F32 : I<(outs I32:$dst), (ins F32:$src),
                        [(set I32:$dst, (fp_to_uint F32:$src))]>;
def I64_TRUNC_S_F32 : I<(outs I64:$dst), (ins F32:$src),
                        [(set I64:$dst, (fp_to_sint F32:$src))]>;
def I64_TRUNC_U_F32 : I<(outs I64:$dst), (ins F32:$src),
                        [(set I64:$dst, (fp_to_uint F32:$src))]>;
def I32_TRUNC_S_F64 : I<(outs I32:$dst), (ins F64:$src),
                        [(set I32:$dst, (fp_to_sint F64:$src))]>;
def I32_TRUNC_U_F64 : I<(outs I32:$dst), (ins F64:$src),
                        [(set I32:$dst, (fp_to_uint F64:$src))]>;
def I64_TRUNC_S_F64 : I<(outs I64:$dst), (ins F64:$src),
                        [(set I64:$dst, (fp_to_sint F64:$src))]>;
def I64_TRUNC_U_F64 : I<(outs I64:$dst), (ins F64:$src),
                        [(set I64:$dst, (fp_to_uint F64:$src))]>;

def F32_CONVERT_S_I32 : I<(outs F32:$dst), (ins I32:$src),
                          [(set F32:$dst, (sint_to_fp I32:$src))]>;
def F32_CONVERT_U_I32 : I<(outs F32:$dst), (ins I32:$src),
                          [(set F32:$dst, (uint_to_fp I32:$src))]>;
def F64_CONVERT_S_I32 : I<(outs F64:$dst), (ins I32:$src),
                          [(set F64:$dst, (sint_to_fp I32:$src))]>;
def F64_CONVERT_U_I32 : I<(outs F64:$dst), (ins I32:$src),
                          [(set F64:$dst, (uint_to_fp I32:$src))]>;
def F32_CONVERT_S_I64 : I<(outs F32:$dst), (ins I64:$src),
                          [(set F32:$dst, (sint_to_fp I64:$src))]>;
def F32_CONVERT_U_I64 : I<(outs F32:$dst), (ins I64:$src),
                          [(set F32:$dst, (uint_to_fp I64:$src))]>;
def F64_CONVERT_S_I64 : I<(outs F64:$dst), (ins I64:$src),
                          [(set F64:$dst, (sint_to_fp I64:$src))]>;
def F64_CONVERT_U_I64 : I<(outs F64:$dst), (ins I64:$src),
                          [(set F64:$dst, (uint_to_fp I64:$src))]>;

def F64_PROMOTE_F32 : I<(outs F64:$dst), (ins F32:$src),
                        [(set F64:$dst, (fextend F32:$src))]>;
def F32_DEMOTE_F64 : I<(outs F32:$dst), (ins F64:$src),
                       [(set F32:$dst, (fround F64:$src))]>;

def I32_REINTERPRET_F32 : I<(outs I32:$dst), (ins F32:$src),
                            [(set I32:$dst, (bitconvert F32:$src))]>;
def F32_REINTERPRET_I32 : I<(outs F32:$dst), (ins I32:$src),
                            [(set F32:$dst, (bitconvert I32:$src))]>;
def I64_REINTERPRET_F64 : I<(outs I64:$dst), (ins F64:$src),
                            [(set I64:$dst, (bitconvert F64:$src))]>;
def F64_REINTERPRET_I64 : I<(outs F64:$dst), (ins I64:$src),
                            [(set F64:$dst, (bitconvert I64:$src))]>;
