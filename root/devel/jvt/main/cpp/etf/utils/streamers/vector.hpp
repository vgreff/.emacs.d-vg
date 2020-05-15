/******************************************************************************
 *
 * Copyright (c) vector.hpp by Daniel Davidson
 *
 * All Rights Reserved. 
 *******************************************************************************/
#ifndef _ETF_UTILS_STREAMERS_VECTOR_HPP_
#define _ETF_UTILS_STREAMERS_VECTOR_HPP_

#include "etf/utils/streamers/streamers.hpp"
#include <iosfwd>
#include <vector>


namespace etf {
namespace utils {
namespace streamers {

  //! Support for streaming std::vector
  template < typename T, typename ALLOC >
  inline std::ostream& operator<<(std::ostream& out, std::vector< T, ALLOC > const& v) {
    return print_scalar_collection(out, v);
  }

}
}
}
#endif
