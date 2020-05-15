//
// HISTORY FILE: %P%
//
// VERSION: %I%
//    
// CREATED: April 7, 2011 by Vincent B. Greff
//
// LAST CHANGED: %G% %U% 
//
// AUTHOR: Vincent B. Greff
//
//
//-----------------------------------------------------------------------------

static const char vcsId_ModuleA_C[] = "%W%	%E% %U%";

//-----------------------------------------------------------------------------

#include "ModuleA.H"

#include <iomanip>

using namespace jvt;
namespace jvt
{
//-----------------------------------------------------------------------------
//
// Default constructor
//

  ModuleA::ModuleA()
    : data_(1)
  {
    
  }

//-----------------------------------------------------------------------------
//
// Destructor
//

  ModuleA::~ModuleA()
  {
    
  }

//-----------------------------------------------------------------------------
//
// Output operator
//

  std::ostream&
  operator<<(std::ostream& out, const ModuleA& obj)
  {
    out << obj.data_ << std::endl;
    return out;
  }

//-----------------------------------------------------------------------------
}
