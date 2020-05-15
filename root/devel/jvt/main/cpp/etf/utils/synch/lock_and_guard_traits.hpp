/******************************************************************************
 *
 * Copyright (c) lock_and_guard_traits.hpp by Daniel Davidson
 *
 * All Rights Reserved. 
 *******************************************************************************/
/*! 
 * \file lock_and_guard_traits.hpp
 *
 * \brief 
 * 
 */
#ifndef _ETF_UTILS_SYNCH_LOCK_AND_GUARD_TRAITS_H_
#define _ETF_UTILS_SYNCH_LOCK_AND_GUARD_TRAITS_H_

#include <boost/interprocess/sync/null_mutex.hpp>
#include <boost/thread/mutex.hpp>
#include <boost/thread/locks.hpp>

namespace etf {
namespace utils {
namespace synch {

  
  template < typename LOCK_TYPE > 
  struct Lock_and_guard_traits 
  {
  };
  
  
  template <  > 
  struct Lock_and_guard_traits< boost::interprocess::null_mutex > 
  {
  
    // Class typedefs
    typedef boost::interprocess::null_mutex Lock_t;
    typedef boost::lock_guard< Lock_t > Guard_t;
  };
  
  
  struct Null_lock_and_guard_traits_tag :
    public Lock_and_guard_traits< boost::interprocess::null_mutex > 
  {
  };
  
  
  template <  > 
  struct Lock_and_guard_traits< boost::mutex > 
  {
  
    // Class typedefs
    typedef boost::mutex Lock_t;
    typedef boost::lock_guard< Lock_t > Guard_t;
  };
  
  
  struct Boost_mutex_lock_and_guard_traits_tag :
    public Lock_and_guard_traits< boost::mutex > 
  {
  };

} // namespace synch
} // namespace utils
} // namespace etf
#endif // _ETF_UTILS_SYNCH_LOCK_AND_GUARD_TRAITS_H_
