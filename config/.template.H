//-----------------------------------------------------------------------------

#ifndef JVT_${ROOT}_H__
#define JVT_${ROOT}_H__

//-----------------------------------------------------------------------------

static const char vcsId_${root}_H[] = "${vcMagic}";

//-----------------------------------------------------------------------------

#include <iostream>
#include <jvt/BaseLib/IntrusivePtr.H>
#include <vector>

//-----------------------------------------------------------------------------
namespace jvt
{

class $root : virtual public IntrusivePtr<$root> 
{
  public:
    typedef boost::intrusive_ptr<$root> Ptr;
    typedef std::vector<${root}::Ptr> Vector;
  public:
    // Constructor and destructors
    $root();
    virtual ~$root();	// Always make destructors virtual

    // Private data access functions
    
    
    // General public Functions
    

    // Public operators

    
    // Public friend functions and classes
    friend std::ostream& operator<<(std::ostream& out, const $root& obj);
  private:
    // The copy constructor and assignment operator are declared private to
    // keep the compiler from generating them.
    $root(const $root& obj);
    $root& operator=(const $root& rhs);

    int operator==(const $root& rhs) const;
    int operator<(const $root& rhs) const;
  private:

};


} // namespace jvt

//-----------------------------------------------------------------------------

#endif // JVT_${ROOT}_H__
