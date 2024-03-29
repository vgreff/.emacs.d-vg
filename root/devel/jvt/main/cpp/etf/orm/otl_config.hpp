/******************************************************************************
 *
 * Copyright (c) otl_config.hpp by Daniel Davidson
 *
 * All Rights Reserved. 
 *******************************************************************************/
/*! 
 * \file otl_config.hpp
 *
 * \brief Defines to be pulled in before otl
 * 
 */
#ifndef _ETF_ORM_OTL_CONFIG_H_
#define _ETF_ORM_OTL_CONFIG_H_

#include "etf/orm/orm.hpp"

namespace etf {
namespace orm {

  
  //! Template class to setup static data for setting global log level
  template < int OTL_LOG_LEVEL = 0 > 
  class Otl_log_level 
  {
  public:
  
// custom <Otl_log_level public header section>

    static int get_otl_log_level() {
      return level_;
    }

    static void set_otl_log_level(int level) {
      level_ = level;
    }

// end <Otl_log_level public header section>
  
  private:
    //! Determines what gets logged on sql statements <I>inaccessible</I>
    static int level_;
  };


// custom <Otl_config namespace end section>

  template< int OTL_LOG_LEVEL > 
  int Otl_log_level< OTL_LOG_LEVEL >::level_ = OTL_LOG_LEVEL;

  inline
  void set_otl_log_level(int level) {
    Otl_log_level<>::set_otl_log_level(level);
  }

// end <Otl_config namespace end section>
} // namespace orm
} // namespace etf

// custom <Otl_config post namespace section>

#if defined (_MSC_VER)
#define OTL_ODBC
#endif

typedef long long otl_bigint;
#define OTL_BIGINT otl_bigint
#define OTL_STREAM_NO_PRIVATE_BOOL_OPERATORS
#define OTL_TRACE_LEVEL etf::orm::Otl_log_level< 0 >::get_otl_log_level() 
#define OTL_TRACE_STREAM std::cerr 
#define OTL_TRACE_LINE_PREFIX "OTL => " 

#include "iostream"
#include "otlv4.h"

// end <Otl_config post namespace section>
#endif // _ETF_ORM_OTL_CONFIG_H_
