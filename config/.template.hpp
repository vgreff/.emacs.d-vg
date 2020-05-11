//-----------------------------------------------------------------------------

#ifndef VBG_${ROOT}_hpp__
#define VBG_${ROOT}_hpp__

//-----------------------------------------------------------------------------

#include <iostream>
#include <memory>
#include <vector>

//-----------------------------------------------------------------------------
namespace vbg
{

class $root
{
  public:
    typedef std::shared_ptr<$root> Ptr;
    typedef std::vector<${root}::Ptr> Vector;
  public:
    // Constructor and destructors
    $root();
    ~$root(); 	// make destructors virtual when necessary only

    // Private data access functions
    
    
    // General public Functions
    

    // Public operators

    
    // Public friend functions and classes
    friend std::ostream& operator<<(std::ostream& out, const $root& obj);
  public:
    //$root(const $root& obj) = delete; // or default
    //$root& operator=(const $root& rhs) = delete;
    
    //$root($root&& obj) = delete;
    //$root& operator=($root&& rhs) = delete;

  private:
    //int operator==(const $root& rhs) const;
    //int operator<(const $root& rhs) const;
  private:

};


} // namespace vbg

//-----------------------------------------------------------------------------

#endif // vbg_${ROOT}_H__
