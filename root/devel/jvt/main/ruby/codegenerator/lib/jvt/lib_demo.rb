require 'codegen/cpp'
require 'codegen'
require 'place'
include Codegen::Cpp

# def get_version_commit
#   begin
#     require 'rubygems'
#     require 'grit'
#     include Grit
#     repo = Repo.new(Place[Place.top] + '.git')
#     %Q{#{repo.commits[0]}}
#   rescue
#     warn "Could not deal with git versioning"
#     %Q{NO_GIT_REPOSITORY}
#   end
# end

#version_commit = get_version_commit

classes = [

           CppClass.new({ 
                          :name => 'Value1',
                          :streamable => true,
                          :serializable => true,
                          :enums => [  
                                     {
                                       :name => 'Store_open_type', 
                                       :brief => 'Create, open for read or open for read and write',
                                       :inline => true,
                                       :values => [
                                                   'OPEN_CREATE', 
                                                   'OPEN_READ',
                                                  ],
                                     }, 
                                    ],
                          :additions_public_header => 'enum {MsgType = 45, };',
                          :ctor_member => false,
                          #:template_decls => [ 'typename T' ],
                          :public_header_section => true,
                          :struct => false,
                          # :header_includes => [ 'boost/call_traits.hpp', ],
                          :ctor_default => true,
                          :public_static_consts => [ ],
                          :public_typedefs => [ 
                                                # 'typedef etf::utils::Fixed_size_char_array<15> VgArray_type',
                                               ],
                          :members => [
                                       { 
                                         :cpp_type => 'int16_t',
                                         :name => 'minValue',
                                         # :public => true,
                                         :init => '0UL',
                                         :member_ctor => true,
                                         :access => Codegen::Access::RW,
                                       },
                                       { 
                                         :cpp_type => 'uint32_t',
                                         :name => 'maxValue',
                                         # :public => true,
                                         :init => '0UL',
                                         :member_ctor => true,
                                         :access => Codegen::Access::RW,
                                       },
                                       { 
                                         # :cpp_type => 'etf::utils::Fixed_size_char_array<15>',
                                         :cpp_type => 'std::string',
                                         :name => 'name',
                                         # :protected => true,
                                         :init => '""',
                                         # :member_ctor => true,
                                         :member_ctor_defaulted => true, 
                                         :access => Codegen::Access::RW,
                                         :pass_by_ref => true,
                                         :streamable => false,
                                         :serializable => false,
                                       },
                                      ],
                          # :include_unit_test => true,
                        }),

           CppClass.new({ 
                          :name => 'ListValue',
                          :streamable => true,
                          :serializable => true,
                          :enums => [  
                                     {
                                       :name => 'Store_open_type', 
                                       :brief => 'Create, open for read or open for read and write',
                                       :inline => true,
                                       :values => [
                                                   'OPEN_CREATE', 
                                                   'OPEN_READ',
                                                  ],
                                     }, 
                                    ],
                          :additions_public_header => 'enum {MsgType = 45, };',
                          :ctor_member => true,
                          #:template_decls => [ 'typename T' ],
                          :public_header_section => true,
                          :struct => false,
                          # :header_includes => [ 'boost/call_traits.hpp', ],
                          :ctor_default => true,
                          :public_static_consts => [ ],
                          :public_typedefs => [ 
                                                #'typedef typename boost::call_traits< T >::param_type Param_type',
                                               ],
                          :members => [
                                        { 
                                         :cpp_type => 'std::list<Value1>',
                                         :name => 'col',
                                         # :public => true,
                                         :init => '',
                                         :member_ctor => true,
                                         :access => Codegen::Access::RW,
                                         :pass_by_ref => true,
                                         },
                                        { 
                                         :cpp_type => 'Value1',
                                         :name => 'ref',
                                         # :public => true,
                                         :init => '',
                                         :member_ctor => true,
                                         :access => Codegen::Access::RW,
                                        },
                                        ],
                           :header_includes => [ 
                                                'Value1.H',
                                               ],
                         # :include_unit_test => true,
                        }),

          ]

lib = Library.new({ 
                    :classes => classes,
                    :header_only => false,
                    :static_only => true,
                    :name => 'DemoLib',
                    :namespace => ['jvt', 'data'],
                    :no_api_decl => true,
                    #:build_cpp_includes => [ '$(TBB_INCLUDE_PATH)' ],
                  })


