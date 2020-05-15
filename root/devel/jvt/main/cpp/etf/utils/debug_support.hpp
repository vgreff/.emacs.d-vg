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
#ifndef _ETF_DEBUG_SUPPORT_HPP_
#define _ETF_DEBUG_SUPPORT_HPP_


#if defined(DEBUG_ETF_STARTUP)
#include <pantheios/pantheios.hpp>
#include <pantheios/inserters.hpp>
#include <pantheios/trace.h>

#    define ETF_LOG_CTOR() \
    pantheios::log(PANTHEIOS_SEV_DEBUG, \
                   __FILE__ " (" PANTHEIOS_STRINGIZE(__LINE__), ") ", \
                   typeid(this).name(), " ctor (",                    \
                   pantheios::hex_ptr(reinterpret_cast<void*>(this)), \
                   pantheios::character(')'))

#    define ETF_LOG_DTOR(type) \
    pantheios::log(PANTHEIOS_SEV_DEBUG, \
                   __FILE__ " (" PANTHEIOS_STRINGIZE(__LINE__), ") ", \
                   typeid(this).name(), " dtor (",                    \
                   pantheios::hex_ptr(reinterpret_cast<void*>(this)), \
                   pantheios::character(')'))

#else
#    define ETF_LOG_CTOR(type)
#    define ETF_LOG_DTOR(type)
#endif

namespace etf {
namespace utils {

}
}

#endif
