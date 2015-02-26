////////////////////////////////////////////////////////////////////////////////
// stof, ftos -- not matched, inserted in MachineInstr lowering
// 32 bit

def STOF : HSAILInstSegCvt_1Op<"stof", BrigOpcode.STOF>;
def FTOS : HSAILInstSegCvt_1Op<"ftos", BrigOpcode.FTOS>;

class STOFPat<ValueType destvt> : Pat<
  (STOFComplexPat BrigSegment:$segment,
                  i1:$nonull,
                  untyped:$src0,
                  BrigTypeX:$destType,
                  BrigTypeX:$srcType),
  (destvt (STOF $segment, $nonull, $src0, $destType, $srcType))
>;

class FTOSPat<ValueType destvt> : Pat<
  (FTOSComplexPat BrigSegment:$segment,
                  i1:$nonull,
                  untyped:$src0,
                  BrigTypeX:$destType,
                  BrigTypeX:$srcType),
  (destvt (FTOS $segment, $nonull, $src0, $destType, $srcType))
>;

// TODO: Should probably just select these in HSAILISelDAGToDAG. We
// aren't really saving effort with this.
def : STOFPat<i32>;
def : STOFPat<i64>;

def : FTOSPat<i32>;
def : FTOSPat<i64>;



def SEGMENTP : HSAILInstSegCvt_1Op<"segmentp", BrigOpcode.SEGMENTP>;

class SegmentPPat<ValueType srcvt, int srcbt> : Pat<
  (HSAILsegmentp (i32 timm:$segment),
                 (i1 timm:$nonull),
                 (srcvt (GPROrImm srcvt:$src0))),
  (SEGMENTP $segment, $nonull, $src0, BrigTypeX.B1, srcbt)
>;


let Predicates = [In64BitMode] in {
  def : SegmentPPat<i64, BrigTypeX.U64>;
}

let Predicates = [In32BitMode] in {
  def : SegmentPPat<i32, BrigTypeX.U32>;
}

let isNotDuplicable = 1, hasCtrlDep = 1, hasSideEffects = 1 in {
  def ARG_DECL : HSAILInst<(outs), (ins PtrRC:$symbol, BrigTypeX:$TypeLength, i32imm:$size,
                                    i32imm:$alignment),
                                    "align $alignment arg_$TypeLength\t$symbol[$size]", []>;
}

class LdStVectorMap<string op, int size> {
  string opcode   = op;
  int    vec_size = size;
}

def getLdStVectorOpcode : InstrMapping {
  let FilterClass = "LdStVectorMap";
  let RowFields   = ["opcode"];
  let ColFields   = ["vec_size"];
  let KeyCol      = ["1"];
  let ValueCols   = [["1"], ["2"], ["3"], ["4"]];
}

// FIXME: If the MEMOP isn't explicitly typed in output, counts as
// wrong number of operands.
class LDPat<Instruction inst, ValueType vt> : Pat <
  (vt (unindexedload (LoadAddr MEMOP:$address,
                               BrigSegment:$segment,
                               BrigAlignment:$align,
                               BrigTypeX:$TypeLength,
                               BrigWidth:$width,
                               BrigMemoryModifierMask:$mask))),
  (inst MEMOP:$address, $TypeLength, $segment, $align, $width, $mask)
>;


// XXX - Dummy argument since something is required for a multiclass.
multiclass HSAIL_LD<int Dummy> {
  // TODO: We should define a single ld opcode with all 4 output
  // registers. We will then just set the ones that are actually used.

  // We define the output registers to be unknown. The used register
  // class will be selected based on the used type.
  def _V1 : LD<"ld", BrigOpcode.LD, (outs unknown:$dest)>, LdStVectorMap<NAME, 1>;
  def _V2 : LD<"ld_v2", BrigOpcode.LD, (outs Vec2Op:$dest)>, LdStVectorMap<NAME, 2>;
  def _V3 : LD<"ld_v3", BrigOpcode.LD, (outs Vec3Op:$dest)>, LdStVectorMap<NAME, 3>;
  def _V4 : LD<"ld_v4", BrigOpcode.LD, (outs Vec4Op:$dest)>, LdStVectorMap<NAME, 4>;
}

defm LD : HSAIL_LD<0>;

// TODO: Promote float loads to integers.
def : LDPat<LD_V1, i32>;
def : LDPat<LD_V1, f32>;
def : LDPat<LD_V1, i64>;
def : LDPat<LD_V1, f64>;



let hasSideEffects = 1, hasCtrlDep = 1 in {
  // It is not safe to move ld_arg as it can be in an argscope
  defm RARG_LD : HSAIL_LD<0>;
}

class STPat<Instruction inst, ValueType vt> : Pat <
  (st (vt (GPROrImm vt:$src)),
      (StoreAddr MEMOP:$address,
                 BrigSegment:$segment,
                 BrigAlignment:$alignment,
                 BrigTypeX:$TypeLength)),
  (inst $src, MEMOP:$address, $TypeLength, $segment, $alignment)
>;

multiclass HSAIL_ST<int dummy> {
  def _V1 : ST<"st", BrigOpcode.ST,
    (ins unknown:$src, MEMOP:$address, BrigTypeX:$TypeLength,
         BrigSegment:$segment, BrigAlignment:$align)>,
    LdStVectorMap<NAME, 1>;
  def _V2 : ST<"st_v2", BrigOpcode.ST,
    (ins Vec2Op:$src, MEMOP:$address, BrigTypeX:$TypeLength,
         BrigSegment:$segment, BrigAlignment:$align)>,
    LdStVectorMap<NAME, 2>;
  def _V3 : ST<"st_v3", BrigOpcode.ST,
    (ins Vec3Op:$src, MEMOP:$address, BrigTypeX:$TypeLength,
         BrigSegment:$segment, BrigAlignment:$align)>,
    LdStVectorMap<NAME, 3>;
  def _V4 : ST<"st_v4", BrigOpcode.ST,
    (ins Vec4Op:$src, MEMOP:$address, BrigTypeX:$TypeLength,
      BrigSegment:$segment, BrigAlignment:$align)>,
    LdStVectorMap<NAME, 4>;
}

defm ST : HSAIL_ST<0>;

// TODO: Promote float stores to integers.
def : STPat<ST_V1, i32>;
def : STPat<ST_V1, f32>;
def : STPat<ST_V1, i64>;
def : STPat<ST_V1, f64>;


// We need pseudos to implement condition register spilling due to a
// limitation storeRegToStackSlot currently has where it assumes only
// 1 instruction is created for spilling.
let isPseudo = 1 in {
  def SPILL_B1 : ST<"spill_b1", BrigOpcode.NOP,
    (ins CR:$src, MEMOP:$address,
         BrigTypeX:$TypeLength, BrigSegment:$segment,
         BrigAlignment:$align)
  >;

  def RESTORE_B1 : LD<"restore_b1", BrigOpcode.NOP,
    (outs CR:$dest)
  >;
}

////////////////////////////////////////////////////////////////////////////////
// load memory address

def LDA : HSAILInstAddr_1Op<"lda", BrigOpcode.LDA>;