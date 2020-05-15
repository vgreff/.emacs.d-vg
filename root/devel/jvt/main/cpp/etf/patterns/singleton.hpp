/******************************************************************************
 *
 * Copyright (c) singleton.hpp by Daniel Davidson
 *
 * All Rights Reserved. 
 *******************************************************************************/
/*! 
 * \file singleton.hpp
 *
 * \brief Support for singleton pattern
 * 
 */
#ifndef _ETF_PATTERNS_SINGLETON_HPP_
#define _ETF_PATTERNS_SINGLETON_HPP_

#include "etf/utils/debug_support.hpp"
#include "etf/utils/synch/lock_and_guard_traits.hpp"
#include <boost/thread/mutex.hpp>
#include <boost/thread/locks.hpp>
#include <boost/noncopyable.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/concept_check.hpp>
#include <map>
#include <list>
#include <utility>
#include <iostream>

namespace etf {
namespace patterns {

  /** \brief Ensures one instance per process.
   * Works in conjuntion with Singleton
   *
   * \note Uses double checked locking - which on multicores can be
   * problematic: (google Meyers/Alexandrescue/Singleton/pdf)
   *
   * \see Singleton for how to use
   */
  template <typename T, 
            typename POINTER_TYPE = boost::shared_ptr< T >,
            typename LOCK_AND_GUARD_TRAITS = etf::utils::synch::Boost_mutex_lock_and_guard_traits_tag >
  class Singleton_impl : boost::noncopyable {

  public:

    /// \brief Managed pointer class for ref counting
    typedef POINTER_TYPE Pointer_t;
    /// \brief Lock type for double checked locking
    typedef typename LOCK_AND_GUARD_TRAITS::Lock_t Lock_t;
    /// \brief Guard type for double checked locking
    typedef typename LOCK_AND_GUARD_TRAITS::Guard_t Guard_t;

    /** \brief Data for single instance
     * Includes support for double check locking
     */
    class Static_data {
    public:
      Static_data() {
      }

      ~Static_data() {
      }

      Lock_t lock_;
      Pointer_t instance_;
    };


    /// Get or lazy-init create the instance
    static Pointer_t get_instance();

  private:
    Singleton_impl();
    ~Singleton_impl();
    Singleton_impl(Singleton_impl const&);
    Singleton_impl &operator=(Singleton_impl const&);
  };

  template < typename T1, typename T2, typename T3 >
  T2 Singleton_impl< T1, T2, T3 >::get_instance() {
    static Static_data static_data_;
    if(0 == static_data_.instance_) {
      Guard_t guard(static_data_.lock_);
      if(0 == static_data_.instance_) {
        Pointer_t new_instance(new T1());
        if(0 != new_instance) {
          std::swap(static_data_.instance_, new_instance);
        }
      }
    }
    return static_data_.instance_;
  }


  /** \brief Used to ensure a Singleton is initialized at static object
   * creation time - before potential use by other statics. 
   * \see Matthew Wilson book "Imperfect C++"
   */
  template <typename T>
  class Singleton_initializer {

  public:
    Singleton_initializer() {
      ETF_LOG_CTOR();
      T::Singleton_t::get_instance();
    }

    ~Singleton_initializer() {
      ETF_LOG_DTOR();
    }
  };


  /** \brief Base class for singleton pattern
   *
   * Steps to use Singleton:
   * - Derive from this class: class Foo : public etf::patterns::Singleton< Foo >
   * - Add friend declaration: friend class Singleton_t
   * - Define the static data:
   *      Foo::Singleton_t::Static_data Foo::Singleton_t::static_data_;
   *  Place the definition in the header. By time flow gets to main it
   *  will be initialized. If you have multiple static data (singleton classes)
   *  that depend on each other, add an initializer definition
   *      Foo::Initializer_t init;
   *  in the anonymous namespace in the order required to make it work
   *  (i.e. no cycles allowed)
   */
  template <typename T>
  class Singleton {

  public:
    typedef typename etf::patterns::Singleton_impl< T > Singleton_t;
    typedef typename etf::patterns::Singleton_impl< T >::Static_data Static_data_t;
    typedef typename etf::patterns::Singleton_impl< T >::Pointer_t Pointer_t;
    typedef typename etf::patterns::Singleton_initializer< T > Initializer_t;
    inline static Pointer_t get_instance() {
      return Singleton_t::get_instance();
    }

    Singleton() {
      ETF_LOG_CTOR();
    };

    ~Singleton() {
      ETF_LOG_DTOR();
    };

  };

}
}

#endif
