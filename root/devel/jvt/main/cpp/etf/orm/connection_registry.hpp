/******************************************************************************
 *
 * Copyright (c) connection_registry.hpp by Daniel Davidson
 *
 * All Rights Reserved. 
 *******************************************************************************/
/*! 
 * \file connection_registry.hpp
 *
 * \brief Place to get database connections
 * 
 */
#ifndef _ETF_ORM_CONNECTION_REGISTRY_H_
#define _ETF_ORM_CONNECTION_REGISTRY_H_

#include <pantheios/pantheios.hpp>
#include "etf/orm/orm.hpp"
#include "etf/orm/otl_config.hpp"
#include "etf/patterns/singleton.hpp"
#include <boost/thread/tss.hpp>
#include <map>
#include <string>

namespace etf {
namespace orm {

  
  //! Parameters required for making a database connection
  class Connection_info 
  {
  public:
    /////////////////////////////////////////////////////////////////
    // member accessors
    /////////////////////////////////////////////////////////////////
    std::string const& user_id() const {
      return user_id_;
    }
  
    void user_id(std::string const& val) {
      user_id_ = val;
    }
  
    std::string & user_id() {
      return user_id_;
    }
  
    std::string const& password() const {
      return password_;
    }
  
    void password(std::string const& val) {
      password_ = val;
    }
  
    std::string & password() {
      return password_;
    }
  
    std::string const& dsn() const {
      return dsn_;
    }
  
    void dsn(std::string const& val) {
      dsn_ = val;
    }
  
    std::string & dsn() {
      return dsn_;
    }
  
  
// custom <Connection_info public header section>

    std::string connection_string() {
      std::string result;
      if(!user_id_.empty()) {
        result = "UID=";
        result += user_id_;
      }
      if(!password_.empty()) {
        result += "PWD=";
        result += password_;
      }
      if(!dsn_.empty()) {
        result += "DSN=";
        result += dsn_;
      }
      return result;
    }

// end <Connection_info public header section>
  
  private:
    std::string user_id_;
    std::string password_;
    std::string dsn_;
  };
  
  //! Place to get database connections
  template < typename LOCK_TYPE = boost::mutex,
             typename GUARD_TYPE = boost::lock_guard< LOCK_TYPE > > 
  class Connection_registry :
    public etf::patterns::Singleton< Connection_registry< LOCK_TYPE, GUARD_TYPE > > 
  {
  public:
  
    // Class typedefs
    typedef std::map< std::string, Connection_info > Connection_info_map_t;
    typedef boost::thread_specific_ptr< otl_connect > Thread_connection_ptr;
    typedef std::map< std::string, Thread_connection_ptr > Thread_connection_map_t;
  protected:
    Connection_registry() :
      connection_info_map_(),
      lock_(),
      thread_connection_map_() 
    {
      ctor_default_init();
    }
  public:
    /////////////////////////////////////////////////////////////////
    // member accessors
    /////////////////////////////////////////////////////////////////
    Connection_info_map_t const& connection_info_map() const {
      return connection_info_map_;
    }
  
  
// custom <Connection_registry public header section>

    void register_connection_info(std::string const& connection_name,
                                  Connection_info const& connection_info) {
      GUARD_TYPE guard(lock_);
      typedef std::pair< Connection_info_map_t::iterator, bool > Insert_result_t;
      Insert_result_t insert_result
        (connection_info_map_.insert
         (Connection_info_map_t::value_type(connection_name, connection_info)));

      pantheios::log(PANTHEIOS_SEV_DEBUG, "Registered connection_info: ", 
                     connection_name.c_str(), " with ",
                     connection_info.connection_string().c_str());

    }

    Connection_info retrieve_connection_info(std::string const& connection_name) {
      GUARD_TYPE guard(lock_);
      typedef std::pair< Connection_info_map_t::iterator, bool > Insert_result_t;
      Connection_info empty;
      Insert_result_t insert_result(
        connection_info_map_.insert
        (Connection_info_map_t::value_type(connection_name, empty)));
      if(insert_result.second) {
        insert_result.first->second.dsn(connection_name);
      }

      pantheios::log(PANTHEIOS_SEV_DEBUG, "Retrieved connection_info: ", 
                     connection_name.c_str(), " with ",
                     insert_result.first->second.connection_string().c_str());

      return insert_result.first->second;
    }

// end <Connection_registry public header section>
  
  private:
    //! Initialize the instance
    inline void ctor_default_init() {
      
// custom <Connection_registry::ctor_default_init>

      otl_connect::otl_initialize();

// end <Connection_registry::ctor_default_init>
    }
    //! Maps name of connection to its connection info <I>read only</I>
    Connection_info_map_t connection_info_map_;
    //! For protecting the registry map <I>inaccessible</I>
    LOCK_TYPE lock_;
    //! Map of connections in tss (i.e. one per thread) <I>inaccessible</I>
    Thread_connection_map_t thread_connection_map_;
    friend class etf::patterns::Singleton_impl< Connection_registry >;
  };

} // namespace orm
} // namespace etf
#endif // _ETF_ORM_CONNECTION_REGISTRY_H_
