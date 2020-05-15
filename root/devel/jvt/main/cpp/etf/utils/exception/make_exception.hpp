/******************************************************************************
 *
 * Copyright (c) make_exception.hpp by Daniel Davidson
 *
 * All Rights Reserved. 
 *******************************************************************************/
/*! 
 * \file make_exception.hpp
 *
 * \brief 
 * 
 */
#ifndef _ETF_UTILS_EXCEPTION_MAKE_EXCEPTION_H_
#define _ETF_UTILS_EXCEPTION_MAKE_EXCEPTION_H_

#include <boost/exception/all.hpp>
#include <exception>

namespace etf {
namespace utils {
namespace exception {

// custom <make_exception pre class section>

  template< typename EXCEPTION >
  inline EXCEPTION make_exception(int line_number, char const* file) {
      return EXCEPTION() 
        << boost::errinfo_at_line(line_number)
        << boost::errinfo_file_name(file);
  }

  template< typename EXCEPTION >
  inline EXCEPTION make_exception(char const* function_name, int line_number, char const* file) {
      return EXCEPTION() 
        << boost::errinfo_api_function(function_name)
        << boost::errinfo_at_line(line_number)
        << boost::errinfo_file_name(file);
  }

// end <make_exception pre class section>

  

} // namespace exception
} // namespace utils
} // namespace etf
#endif // _ETF_UTILS_EXCEPTION_MAKE_EXCEPTION_H_
