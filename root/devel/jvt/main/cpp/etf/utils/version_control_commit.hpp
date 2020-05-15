/******************************************************************************
 *
 * Copyright (c) version_control_commit.hpp by Daniel Davidson
 *
 * All Rights Reserved. 
 *******************************************************************************/
/*! 
 * \file version_control_commit.hpp
 *
 * \brief 
 * 
 */
#ifndef _ETF_UTILS_VERSION_CONTROL_COMMIT_H_
#define _ETF_UTILS_VERSION_CONTROL_COMMIT_H_

#include "etf/patterns/singleton.hpp"

namespace etf {
namespace utils {

  class Version_control_commit :
    public etf::patterns::Singleton< Version_control_commit > 
  {
  protected:
    Version_control_commit() :
      git_commit_("33a97313300fa6f489235b3b939be526784379f3"),
      search_string_("git commit => 33a97313300fa6f489235b3b939be526784379f3") 
    {
    }
  public:
    /////////////////////////////////////////////////////////////////
    // member accessors
    /////////////////////////////////////////////////////////////////
    char const * git_commit() const {
      return git_commit_;
    }
  
    char const * search_string() const {
      return search_string_;
    }
  
  private:
    char const * git_commit_;
    char const * search_string_;
    friend class etf::patterns::Singleton_impl< Version_control_commit >;
  };

} // namespace utils
} // namespace etf
#endif // _ETF_UTILS_VERSION_CONTROL_COMMIT_H_
