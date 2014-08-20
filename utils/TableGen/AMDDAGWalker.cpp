#include "AMDDAGWalker.h"

bool IsSubclassOf( std::string sSuperclassName, DefInit * def ) {
  std::vector<Record*> superClasses = def->getDef()->getSuperClasses();
  for ( std::vector<Record*>::const_iterator i = superClasses.begin(); i != superClasses.end(); i++ ) {
    Record * r = *i;
    if ( r->getName() == sSuperclassName ) {
      return true;
    }
  }
  return false;
}

std::string getOpcode( DefInit * def ) {
  std::string sOpcode = "EOL";
  if ( def ) {
    if ( IsSubclassOf("SDNode", def ) ) {
      sOpcode = def->getDef()->getValueAsString("Opcode");
    } else	if ( IsSubclassOf("PatFrag", def ) ) {
      if ( DagInit * frag = def->getDef()->getValueAsDag("Fragment") ) {
        Init * val = frag->getOperator();
        if ( DefInit * def = dyn_cast<DefInit>(val) ) {
          if ( IsSubclassOf("ValueType", def) ) {
            sOpcode = getOpcode(dyn_cast<DefInit>(frag->getArg(0)));
          } else {
            sOpcode = getOpcode(def);
          }
        }
      }
    } else if  ( IsSubclassOf("RegisterClass", def ) ) {
      sOpcode = "REGISTER";
    } else if  ( IsSubclassOf("ValueType", def) ) {
      sOpcode = "ValueType";
    } else if  ( IsSubclassOf("Intrinsic", def) ) {
      sOpcode = "Intrinsic";
    }
  }
  return sOpcode;
}

void DAGWalker::ProcessIntrinsic( DefInit * def ) {
  std::string sIntrnName = def->getDef()->getName();
  std::string sHSAILIntrnPrefix("int_HSAIL_");
  assert( 0 == sIntrnName.compare(0, sHSAILIntrnPrefix.length(), sHSAILIntrnPrefix) );
  if ( ( sIntrnName.find("img") != sIntrnName.npos ) || ( sIntrnName.find("image") != sIntrnName.npos ) ) 
  {  
    /* image load, store or read */
    printer << "    BrigEmitImageInst( MI, inst );\n";
  } else if (sIntrnName.find("query") != sIntrnName.npos) {
    /* query width, height, order etc */
    printer << "    BrigEmitOperandImage( MI, 1 );\n";
  }
  m_state = PS_END;
}

void DAGWalker::EmitVectorOrScalarOperand() {
  if (m_vec_size == 1)
    printer << "    BrigEmitOperand( MI, " << m_opNum++ << ", inst);\n";
  else { 
    printer << "    BrigEmitVecOperand( MI, " << m_opNum << ", " << m_vec_size << " );\n";
    m_opNum += m_vec_size;
  }
}

void DAGWalker::ProcessDef( DefInit * def ) {

  switch( m_state ) {
  case PS_START:
    {
      switch(Node[getOpcode(def)]) {
      case Register:
      case Constant:
      case ConstantFP:
        //	Don't change state - just emit what we have 
        EmitVectorOrScalarOperand();
        break;
      case INTRINSIC:
        {
          ProcessIntrinsic(def);
        }
        break;
      }
    }
    break;
  case PS_END:
  switch(Node[getOpcode(def)]) {
      case DELETED_NODE:    // we're done. only EOL accepted to let recursion rollout
        {
          m_state = PS_END;
        }
        break;
      default:
        exit(1);
  }
  break;

  default:
    {
      exit(1);
    }
  }
}

void DAGWalker::WalkDAG( DagInit * dag, int& nNumOperands ) {
  if ( ( 0 > nNumOperands ) || ( PS_END == m_state ) ) return;
  Init * val = dag->getOperator();
  if ( DefInit * def = dyn_cast<DefInit>(val) ) {
    ProcessDef(def);
  }
  for ( DagInit::const_arg_iterator ai = dag->arg_begin(), ae = dag->arg_end(); ai != ae; ai++ ) {
    if ( DefInit * def = dyn_cast<DefInit>(*ai) ) { 
      if ( ( 0 > --nNumOperands ) || ( PS_END == m_state )) return;    
      ProcessDef(def);
    } else if ( DagInit * d = dyn_cast<DagInit>(*ai) ) {
      WalkDAG( d, nNumOperands);
    }
  }
  if ( nNumOperands == 0 )  { // we're done - generate EOL
    ProcessDef(NULL);
  }
}

