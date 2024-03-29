/******************************************************************************
 *
 * Copyright (c) block_indenter.hpp by Daniel Davidson
 *
 * All Rights Reserved. 
 *******************************************************************************/
/*! 
 * \file block_indenter.hpp
 *
 * \brief 
 * 
 */
#ifndef _ETF_UTILS_BLOCK_INDENTER_H_
#define _ETF_UTILS_BLOCK_INDENTER_H_

#include "etf/patterns/singleton.hpp"
#include <boost/thread/tss.hpp>

namespace etf {
namespace utils {

  
  class Block_current_indent :
    public etf::patterns::Singleton< Block_current_indent > 
  {
  protected:
    Block_current_indent() :
      indentation_length_() 
    {
    }
  public:
  
// custom <Block_current_indent public header section>

    inline void initialize_tss() {
      if(!indentation_length_.get()) {
        indentation_length_.reset(new int(0));
      }
    }
    inline void increment_indent() {
      initialize_tss();
      ++(*indentation_length_);
    }

    inline void decrement_indent() {
      initialize_tss();
      --(*indentation_length_);
    }

    inline char const* current_indentation_text() {
        char const* result("");
        switch(*indentation_length_) {
         case 0: result = ""; break;
         case 1: result = "  "; break;
         case 2: result = "    "; break;
         case 3: result = "      "; break;
         case 4: result = "        "; break;
         case 5: result = "          "; break;
         case 6: result = "            "; break;
         case 7: result = "              "; break;
         case 8: result = "                "; break;
         case 9: result = "                  "; break;
         default: result = "                    "; break;
        }
        return result;
    }

// end <Block_current_indent public header section>
  
  private:
    boost::thread_specific_ptr< int > indentation_length_;
    friend class etf::patterns::Singleton_impl< Block_current_indent >;
  };
  
  class Block_indenter 
  {
  public:
  
// custom <Block_indenter public header section>

    Block_indenter() {
      Block_current_indent::get_instance()->increment_indent();
    }

    ~Block_indenter() {
      Block_current_indent::get_instance()->decrement_indent();
    }

    inline char const* current_indentation_text() {
      return Block_current_indent::get_instance()->current_indentation_text();
    }

// end <Block_indenter public header section>
  
  };

} // namespace utils
} // namespace etf
#endif // _ETF_UTILS_BLOCK_INDENTER_H_
