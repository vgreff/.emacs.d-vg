/******************************************************************************
 *
 * Copyright (c) value_min_max.hpp by Daniel Davidson
 *
 * All Rights Reserved. 
 *******************************************************************************/
/*! 
 * \file value_min_max.hpp
 *
 * \brief 
 * 
 */
#ifndef _ETF_UTILS_VALUE_MIN_MAX_H_
#define _ETF_UTILS_VALUE_MIN_MAX_H_

#include <boost/call_traits.hpp>
#include <limits>

namespace etf {
namespace utils {

  template < typename T > 
  struct Value_min_max 
  {
  
    // Class typedefs
    typedef typename boost::call_traits< T >::param_type Param_type;
    Value_min_max() :
      min_value_(std::numeric_limits< T >::max()),
      max_value_(std::numeric_limits< T >::min()) 
    {
    }
  
// custom <Value_min_max public header section>

    void operator()(Param_type update) {
      if(update < min_value_) {
        min_value_ = update;
      } else if(update > max_value_) {
        max_value_ = update;
      }
    }

// end <Value_min_max public header section>
  
    T min_value_;
    T max_value_;
  };

} // namespace utils
} // namespace etf
#endif // _ETF_UTILS_VALUE_MIN_MAX_H_
