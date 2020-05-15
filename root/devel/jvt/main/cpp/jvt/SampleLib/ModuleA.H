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

#ifndef _ModuleA_H__
#define _ModuleA_H__

//-----------------------------------------------------------------------------

static const char vcsId_ModuleA_H[] = "%W%	%E% %U%";

//-----------------------------------------------------------------------------

#include <iostream>

//-----------------------------------------------------------------------------
namespace jvt
{

  class ModuleA
  {
    private:
    
    public:
      // Constructor and destructors
      ModuleA();
      virtual ~ModuleA();	// Always make destructors virtual

      // Private data access functions
    
    
      // General public Functions
    

      // Public operators

    
      // Public friend functions and classes
      friend std::ostream& operator<<(std::ostream& out, const ModuleA& obj);
    private:
      // The copy constructor and assignment operator are declared private to
      // keep the compiler from generating them.
      ModuleA(const ModuleA& obj);
      ModuleA& operator=(const ModuleA& rhs);

      int operator==(const ModuleA& rhs) const;
      int operator<(const ModuleA& rhs) const;
    private:
      int data_;
  };

} // namespace jvt

//-----------------------------------------------------------------------------

#endif //_ModuleA_H__
