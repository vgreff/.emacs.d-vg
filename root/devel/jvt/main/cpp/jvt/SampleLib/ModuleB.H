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

#ifndef _MODULEB_H__
#define _MODULEB_H__

//-----------------------------------------------------------------------------

static const char vcsId_ModuleB_H[] = "%W%	%E% %U%";

//-----------------------------------------------------------------------------

#include <iostream>
#include <boost/shared_ptr.hpp>

//-----------------------------------------------------------------------------
namespace jvt
{

  class ModuleB
  {
    public:
      typedef boost::shared_ptr<ModuleB> Ptr;
    public:
      // Constructor and destructors
      ModuleB();
      virtual ~ModuleB();	// Always make destructors virtual

      // Private data access functions
    
    
      // General public Functions
    

      // Public operators

    
      // Public friend functions and classes
      friend std::ostream& operator<<(std::ostream& out, const ModuleB& obj);
    private:
      // The copy constructor and assignment operator are declared private to
      // keep the compiler from generating them.
      ModuleB(const ModuleB& obj);
      ModuleB& operator=(const ModuleB& rhs);

      int operator==(const ModuleB& rhs) const;
      int operator<(const ModuleB& rhs) const;
    private:

  };


} // namespace jvt

//-----------------------------------------------------------------------------

#endif //_MODULEB_H__
