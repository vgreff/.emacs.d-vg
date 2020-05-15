/******************************************************************************
 *
 * Copyright (c) deque.hpp by Daniel Davidson
 *
 * All Rights Reserved. 
 *******************************************************************************/
#ifndef _ETF_UTILS_STREAMERS_DEQUE_HPP_
#define _ETF_UTILS_STREAMERS_DEQUE_HPP_

#include "etf/utils/streamers/streamers.hpp"
#include <iosfwd>
#include <deque>


namespace etf {
namespace utils {
namespace streamers {

  //! Support for streaming std::deque
  template < typename T, typename ALLOC >
  inline std::ostream& operator<<(std::ostream& out, std::deque< T, ALLOC > const& d) {
    return print_scalar_collection(out, d);
  }

}
}
}
#endif
