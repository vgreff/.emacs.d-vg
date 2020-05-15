require 'codegen/cpp'
require 'codegen'
include Codegen::Cpp

connection_info = CppClass.new({ 
                                 :name => 'Connection_info',
                                 :members => [
                                               { :cpp_type =>'std::string', 
                                                 :name =>'user_id', 
                                                 :pass_by_ref =>true,
                                                 :access => Codegen::Access::RW}, 
                                               { :cpp_type =>'std::string', 
                                                 :name =>'password', 
                                                 :pass_by_ref =>true,
                                                 :access => Codegen::Access::RW}, 
                                               { :cpp_type =>'std::string', 
                                                 :name =>'dsn', 
                                                 :pass_by_ref =>true,
                                                 :access => Codegen::Access::RW}, 
                                              ],
                                 :brief => 'Parameters required for making a database connection',
                                 :public_header_section => true,
                               })

classes = [

           Codegen::Cpp::CppClass.new({ 
                                        :name => 'orm',
                                        :is_api_header => true,
                                        :brief => 'Api object relational mapping',
                                        :public_typedefs => 
                                        [ 
                                         'typedef std::vector< int > Id_list_t',
                                         'typedef std::vector< std::string > String_list_t',
                                         'typedef std::vector< String_list_t > String_table_t',
                                         'typedef boost::gregorian::date Date_t',
                                         'typedef std::set< Date_t > Date_set_t',
                                         'typedef std::set< std::string > String_set_t',
                                        ],
                                        :forward_class_decls => [],
                                        :header_includes => 
                                        [
                                         'boost/date_time/gregorian/gregorian.hpp',
                                         'vector',
                                         'set',
                                        ],
                                        :enums => [ 
                                                   ],
                                      }),


           CppClass.new({ 
                          :name => 'Otl_config',
                          :no_class => true,
                          :header_post_namespace_section => true,
                          :members => [ ],
                          :brief => 'Defines to be pulled in before otl',
                          :header_only => true,
                          :header_namespace_end_section => true,
                          :additional_classes => 
                          [
                           CppClass.new({ 
                                          :name => 'Otl_log_level',
                                          :brief => 'Template class to setup static data for setting global log level',
                                          :public_header_section => true,
                                          :template_decls =>
                                          [
                                           'int OTL_LOG_LEVEL = 0'
                                          ],
                                          :members => 
                                          [
                                           { 
                                             :name => 'level',
                                             :brief => 'Determines what gets logged on sql statements',
                                             :cpp_type => 'int',
                                             :static => true,
                                           },
                                          ],
                                          :global_header_section => true,
                                        })
                          ]
                        }),

           CppClass.new({ 
                          :name => 'Otl_utils',
                          :no_class => true,
                          :pre_class_section => true,
                          :global_header_section => true,
                          :members => [ ],
                          :brief => 'Some utility functions',
                          :header_only => true,
                          :header_includes => 
                          [ 
                           'etf/utils/fixed_size_char_array.hpp', 
                           'boost/date_time/gregorian/formatters.hpp',
                           'boost/date_time/gregorian/gregorian_types.hpp',
                           'boost/date_time/posix_time/posix_time.hpp',
                           'boost/algorithm/string/replace.hpp',
                           'string'
                          ],
                        }),

           CppClass.new({ 
                          :name => 'Orm_to_string_table',
                          :no_class => true,
                          :pre_class_section => true,
                          :global_header_section => true,
                          :members => [ ],
                          :brief => 'Functions to turn recordset lists into string lists',
                          :header_only => true,
                          :header_includes => 
                          [ 
                           'string',
                           'etf/utils/streamers/table/table.hpp',
                          ],
                        }),

           CppClass.new({ 
                          :name => 'Connection_registry',
                          :ctor_default_init_inline_method => true,
                          :members => [
                                        { :cpp_type =>'Connection_info_map_t', 
                                          :brief => 'Maps name of connection to its connection info',
                                          :name =>'connection_info_map', 
                                          :pass_by_ref =>true,
                                          :access => Codegen::Access::RO}, 
                                        { 
                                          :cpp_type => 'LOCK_TYPE',
                                          :name => 'lock',
                                          :brief => 'For protecting the registry map',
                                        },
                                        { 
                                          :cpp_type => 'Thread_connection_map_t',
                                          :name => 'thread_connection_map',
                                          :pass_by_ref => true,
                                          :brief => 'Map of connections in tss (i.e. one per thread)'
                                        },
                                       ],
                          :template_decls => [ 
                                               'typename LOCK_TYPE = boost::mutex',
                                               'typename GUARD_TYPE = boost::lock_guard< LOCK_TYPE >'
                                              ],
                          :singleton_base_template => 'Connection_registry< LOCK_TYPE, GUARD_TYPE >',
                          :public_header_section => true,
                          :singleton => true,
                          :additional_classes => [connection_info],
                          :additional_classes_come_first => true,
                          :public_typedefs => [ 
                                                'typedef std::map< std::string, Connection_info > Connection_info_map_t',
                                                'typedef boost::thread_specific_ptr< otl_connect > Thread_connection_ptr',
                                                'typedef std::map< std::string, Thread_connection_ptr > Thread_connection_map_t'
                                               ],
                          :brief => 'Place to get database connections',
                          :header_includes => [ 
                                                'etf/orm/otl_config.hpp',
                                                'boost/thread/tss.hpp',
                                                'pantheios/pantheios.hpp',
                                               ],
                        }),
          ]

lib = Codegen::Cpp::Library.new({ 
                                  :classes => classes,
                                  :descr => "Api supporting basic object relational mapping.",
                                  :header_only => true,
                                  :jam_requirements => [ ],
                                  :namespace => ['etf', 'orm', ]
                                })


lib = Codegen::Cpp::Library.new({ 
                                  :classes =>  
                                  [
                                   CppClass.new({ 
                                                  :name => 'Test_table_operations',
                                                  :ctor_member_init_inline_method => true,
                                                  :public_typedefs =>
                                                  [
                                                   'typedef typename TABLE_CLASS::Pointer_t Pointer_t',
                                                   'typedef typename TABLE_CLASS::Row_list_t Row_list_t',
                                                   'typedef typename TABLE_CLASS::Pkey_list_t Pkey_list_t',
                                                   'typedef typename TABLE_CLASS::Value_list_t Value_list_t',
                                                   'typedef typename TABLE_CLASS::Row_t Row_t',
                                                  ],
                                                  :template_decls => 
                                                  [ 
                                                   'typename TABLE_CLASS',
                                                  ],
                                                  :members => 
                                                  [ 
                                                   { 
                                                     :cpp_type =>'Pointer_t',
                                                     :brief => 'Class front-ending the database table',
                                                     :name =>'table_class', 
                                                     :pass_by_ref => true,
                                                     :member_ctor => true,
                                                     :access => Codegen::Access::RO}, 
                                                   { 
                                                     :cpp_type =>'Row_list_t',
                                                     :brief => 'Results of initial select',
                                                     :name =>'initial_select_all_results', 
                                                     :pass_by_ref => true,
                                                     :access => Codegen::Access::RO}, 
                                                  ],
                                                  :brief => 'Test basic methods on database table class',
                                                  :private_header_section => true,
                                                  :header_only => true,
                                                  :header_includes => [
                                                                        'etf/utils/streamers/containers.hpp', 
                                                                        'algorithm',
                                                                        'set',
                                                                        'iterator',
                                                                       ],
                                                }),
                                  ],
                                  :header_only => true,
                                  :jam_requirements => [ ],
                                  :descr => "Api providing support for generically testing CRUD operations from orm",
                                  :namespace => ['etf', 'orm', 'test' ]
                                })


