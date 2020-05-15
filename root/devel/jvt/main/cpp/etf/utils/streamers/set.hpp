/******************************************************************************
 *
 * Copyright (c) set.hpp by Daniel Davidson
 *
 * All Rights Reserved. 
 *******************************************************************************/
#ifndef _ETF_UTILS_STREAMERS_SET_HPP_
#define _ETF_UTILS_STREAMERS_SET_HPP_

#include "etf/utils/streamers/streamers.hpp"
#include <iosfwd>
#include <set>


namespace etf {
namespace utils {
namespace streamers {

  //! Support for streaming std::list
  template < typename T, typename PR, typename ALLOC > 
  inline std::ostream& operator<<(std::ostream& out, std::set< T, PR, ALLOC > const& l) {
    return print_scalar_collection(out, l);
  }

}
}
}
#endif
