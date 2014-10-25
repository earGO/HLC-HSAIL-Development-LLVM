//===-- HSAILInstPrinter.h - HSAIL MC Inst -> ASM interface -----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
/// \file
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_HSAIL_INSTPRINTER_HSAILINSTPRINTER_H
#define LLVM_LIB_TARGET_HSAIL_INSTPRINTER_HSAILINSTPRINTER_H

#include "llvm/ADT/StringRef.h"
#include "llvm/MC/MCInstPrinter.h"

namespace llvm {

class HSAILInstPrinter : public MCInstPrinter {
public:
  HSAILInstPrinter(const MCAsmInfo &MAI, const MCInstrInfo &MII,
                   const MCRegisterInfo &MRI)
      : MCInstPrinter(MAI, MII, MRI) {}

  // Autogenerated by tblgen
  void printInstruction(const MCInst *MI, raw_ostream &O);
  static const char *getRegisterName(unsigned RegNo);

  void printInst(const MCInst *MI, raw_ostream &O, StringRef Annot) override;

private:
  void printImmediate(uint32_t Imm, raw_ostream &O);
  void printAddrMode3Op(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  void printOperand(const MCInst *MI, unsigned OpNo, raw_ostream &O);

  void printBrigAlignment(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  void printBrigAllocation(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  void printBrigAluModifierMask(const MCInst *MI, unsigned OpNo,
                                raw_ostream &O);
  void printBrigAtomicOperation(const MCInst *MI, unsigned OpNo,
                                raw_ostream &O);
  void printBrigCompareOperation(const MCInst *MI, unsigned OpNo,
                                 raw_ostream &O);
  void printBrigControlDirective(const MCInst *MI, unsigned OpNo,
                                 raw_ostream &O);

  void printBrigExecutableModifierMask(const MCInst *MI, unsigned OpNo,
                                       raw_ostream &O);
  void printBrigImageChannelOrder(const MCInst *MI, unsigned OpNo,
                                  raw_ostream &O);
  void printBrigImageChannelType(const MCInst *MI, unsigned OpNo,
                                 raw_ostream &O);
  void printBrigImageGeometry(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  void printBrigImageQuery(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  void printBrigLinkage(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  void printBrigMachineModel(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  void printBrigMemoryModifierMask(const MCInst *MI, unsigned OpNo,
                                   raw_ostream &O);
  void printBrigMemoryOrder(const MCInst *MI, unsigned OpNo, raw_ostream &O);

  void printBrigMemoryScope(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  void printBrigOpcode(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  void printBrigPack(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  void printBrigProfile(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  void printBrigRound(const MCInst *MI, unsigned OpNo, raw_ostream &O);

  void printBrigSamplerAddressing(const MCInst *MI, unsigned OpNo,
                                  raw_ostream &O);
  void printBrigSamplerCoordNormalization(const MCInst *MI, unsigned OpNo,
                                          raw_ostream &O);

  void printBrigSamplerFilter(const MCInst *MI, unsigned OpNo, raw_ostream &O);

  void printBrigSamplerQuery(const MCInst *MI, unsigned OpNo, raw_ostream &O);

  void printBrigSegCvtModifierMask(const MCInst *MI, unsigned OpNo,
                                   raw_ostream &O);

  void printBrigSegment(const MCInst *MI, unsigned OpNo, raw_ostream &O);

  void printBrigTypeX(const MCInst *MI, unsigned OpNo, raw_ostream &O);

  void printBrigVariableModifierMask(const MCInst *MI, unsigned OpNo,
                                     raw_ostream &O);

  void printBrigWidth(const MCInst *MI, unsigned OpNo, raw_ostream &O);
};

} // End namespace llvm

#endif
