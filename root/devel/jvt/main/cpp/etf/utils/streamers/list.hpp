/******************************************************************************
 *
 * Copyright (c) list.hpp by Daniel Davidson
 *
 * All Rights Reserved. 
 *******************************************************************************/
#ifndef _ETF_UTILS_STREAMERS_LIST_HPP_
#define _ETF_UTILS_STREAMERS_LIST_HPP_

#include "etf/utils/streamers/streamers.hpp"
#include <iosfwd>
#include <list>


namespace etf {
namespace utils {
namespace streamers {

  //! Support for streaming std::list
  template < typename T, typename ALLOC > 
  inline std::ostream& operator<<(std::ostream& out, std::list< T, ALLOC > const& l) {
    return print_scalar_collection(out, l);
  }

}
}
}
#endif
