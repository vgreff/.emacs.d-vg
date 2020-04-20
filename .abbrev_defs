;;-*-coding: emacs-mule;-*-

(define-abbrev-table 'c++-mode-abbrev-table '(
    ("bk" "{

  }
" nil 3)
    ("catch" "catch" c-electric-continued-statement 0)
    ("ch" "char" nil 3)
    ("cl" "class" nil 3)
    ("co" "const" nil 3)
    ("cr" "std::cerr <<" nil 3)
    ("cs" "<< \" \" <<" nil 3)
    ("ct" "std::cout <<" nil 3)
    ("dct" "*   = dynamic_cast<*>();" nil 3)
    ("cct" "*   = const_cast<*>();" nil 3)
    ("rct" "*   = reinterpret_cast<*>();" nil 3)
    ("des" "if (size())
	clear();
" nil 3)
    ("dou" "double" nil 3)
    ("else" "else" c-electric-continued-statement 0)
    ("en" "<< std::endl;" nil 3)
    ("em" "enum class MyClass : uint16_t { MsgType = 6 };" nil 3)
    ("ums" "auto ptr = std::make_shared<>();" nil 3)
    ("fi" "    out.setf(ios::fixed);
" nil 3)
    ("fl" "float" nil 3)
    ("foeo" "foreach(Coll::reference refIt, coll_)
   {
      refIt.second->;
   }" nil 3)
   
   ("era" "for (auto it = coll.begin(); it != coll.end(); )
  {
    if (*it % 2 == 0)
    {
      it = coll.erase(it);
    }
    else
    {
      ++it;
    }
  }" nil 3)
   ("foe" "for(auto& elmt : coll)
   {
      
   }" nil 3)
   ("lam" "auto fct = [](std::string a, int b)
    {
      return std::move(a) + '-' + std::to_string(b);
    };" nil 3)
    ("foi" "    for(uint64_t i=0, end(coll.size());i < end;++i)
    {

    }
" nil 3)
    ("foj" "    for(uint64_t j=0, end(coll.size());j < end;++j)
    {

    }
" nil 3)
    ("fok" "    for(uint64_t k=0, end(coll.size());k < end;++k)
    {

    }
" nil 3)
    ("fosc" "   for(MyType::iterator it(symbols_.begin()), end(symbols_.end());
     end != it;
     ++it)
{
}
" nil 3)
    ("fos" "   for(MyType::iterator it(symbols_.begin());
     symbols_.end() != it;
     ++it)
{
}
" nil 3)
    ("fr" "friend" nil 3)
    ("i16" "int16_t" nil 3)
    ("i32" "int32_t" nil 3)
    ("i64" "int64_t" nil 3)
    ("i8" "int8_t" nil 3)
    ("ias" "#include <ace/SString.h>" nil 3)
    ("ife" "    if ( == )
    {

    }
    else
    {

    }
" nil 3)
    ("iff" "    if ( == )
    {

    }
" nil 3)
    ("ifoeb" "#include <boost/foreach.hpp>
#define foreach BOOST_FOREACH
" nil 3)
    ("ifoe" "#include <jvt/BaseLib/foreach.H>" nil 3)
    ("ig" "#include </.hpp>" nil 3)
    ("igs" "#include <.h>" nil 3)
    ("iio" "#include <iostream>
" nil 3)
    ("iiof" "#include <fstream>" nil 3)
    ("iiom" "#include <iomanip>" nil 3)
    ("iios" "#include <strstream>" nil 3)
    ("il" "#include \".hpp\"" nil 3)
    ("inl" "inline" nil 3)
    ("isa" "#include <algorithm>" nil 3)
    ("ishm" "#include <hash_map>" nil 3)
    ("ism" "#include <map>" nil 3)
    ("ishs" "#include <hash_set>" nil 3)
    ("iss" "#include <string>" nil 3)
    ("isl" "#include <list>" nil 3)
    ("uiss" "std::istrstream strIn;" nil 3)
    ("isv" "#include <vector>" nil 3)
    ("ibsp" "#include <memory>" nil 3)
    ("lo" "long" nil 3)
    ("nas" "namespace" nil 3)
    ("unas" "using namespace vbg;" nil 3)
    ("oeq" "inline int
Record::operator==(const Record& rhs) const
{
    return ( == rhs.);
}
" nil 3)
    ("uoss" "std::ostrstream strOut;
" nil 3)
    ("sct" "*   = static_cast<*>();" nil 3)
    ("sp" "<< setprecision(2)" nil 3)
    ("st" "size_t" nil 3)
    ("sw" "    switch()
    {
	case  :
	    break;
	case  :
	    break;
	case  :
	    break;
	case  :
	    break;
	case  :
	    break;
	default:
	    break;
    }
" nil 3)
    ("fpe" "fprintf(stderr, \"\\n\",);" nil 3)
    ("u16" "uint16_t" nil 3)
    ("u32" "uint32_t" nil 3)
    ("u64" "uint64_t" nil 3)
    ("u8" "uint8_t" nil 3)
    ("uas" "ACE_CString" nil 3)
    ("ucr" "std::cerr" nil 3)
    ("uct" "std::cout" nil 3)
    ("utd" "typedef" nil 3)
    ("ubsp" "boost::shared_ptr<> Ptr;" nil 3)
    ("ubd" "Boost::Date" nil 3)
    ("ubt" "Boost::Time" nil 3)
    ("ubtd" "Boost::TimeDuration" nil 3)
    ("uma" "int main(int argc, char *argv[])
{
   return 0;
}" nil 3)
    ("usf" "   Coll::const_iterator foundIt = services_.find(msg);
   if (foundIt == services_.end()) // not found
   {

   }
" nil 3)
    ("usfi" "   std::pair<CollType::iterator, bool> p =
      coll_.insert( CollType::value_type(key, value) );
   if (p.second == true) // if new
   {

   }
   return p.first->second;
" nil 3)
    ("ushm" "std::hash_map<>" nil 3)
    ("ushs" "std::hash_set<>" nil 3)
    ("usl" "std::list<>" nil 3)
    ("usm" "std::map<>" nil 3)
    ("uss" "std::string" nil 3)
    ("usv" "std::vector<>" nil 3)
    ("vo" "void" nil 3)
    ("sz" "sizeof()" nil 3)
    ("wh" "    while()
    {

    }
" nil 3)
    ("while" "while" c-electric-continued-statement 0)
    ))

(define-abbrev-table 'c-mode-abbrev-table '(
    ("else" "else" c-electric-continued-statement 0)
    ("while" "while" c-electric-continued-statement 0)
    ))

