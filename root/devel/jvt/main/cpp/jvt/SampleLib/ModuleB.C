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

static const char vcsId_ModuleB_C[] = "%W%	%E% %U%";

//-----------------------------------------------------------------------------

#include "ModuleB.H"

#include <iomanip>

namespace jvt
{

//-----------------------------------------------------------------------------
//
// Default constructor
//

  ModuleB::ModuleB()
  {
    
  }

//-----------------------------------------------------------------------------
//
// Destructor
//

  ModuleB::~ModuleB()
  {
    
  }

//-----------------------------------------------------------------------------
//
// Output operator
//

  std::ostream&
  operator<<(std::ostream& out, const ModuleB& obj)
  {
    return out;
  }

//-----------------------------------------------------------------------------

} // namespace jvt
