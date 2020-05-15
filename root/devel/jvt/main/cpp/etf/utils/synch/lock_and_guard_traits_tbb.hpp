/******************************************************************************
 *
 * Copyright (c) lock_and_guard_traits_tbb.hpp by Daniel Davidson
 *
 * All Rights Reserved. 
 *******************************************************************************/
/*! 
 * \file lock_and_guard_traits_tbb.hpp
 *
 * \brief 
 * 
 */
#ifndef _ETF_UTILS_SYNCH_LOCK_AND_GUARD_TRAITS_TBB_H_
#define _ETF_UTILS_SYNCH_LOCK_AND_GUARD_TRAITS_TBB_H_

#include "tbb/spin_mutex.h"

namespace etf {
namespace utils {
namespace synch {

  
  template <  > 
  struct Lock_and_guard_traits< tbb::spin_mutex > 
  {
  
    // Class typedefs
    typedef tbb::spin_mutex Lock_t;
    typedef Lock_t::scoped_lock Guard_t;
  };
  
  
  struct Tbb_spin_mutex_lock_and_guard_traits_tag :
    public Lock_and_guard_traits< tbb::spin_mutex > 
  {
  };

} // namespace synch
} // namespace utils
} // namespace etf
#endif // _ETF_UTILS_SYNCH_LOCK_AND_GUARD_TRAITS_TBB_H_
