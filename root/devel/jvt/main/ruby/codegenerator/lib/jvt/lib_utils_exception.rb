require 'codegen/cpp'
require 'codegen'
include Codegen::Cpp

lib = Library.new({ 
                    :classes => [
                                  CppClass.new({ 
                                                 :header_includes => [ 'exception', 'boost/exception/all.hpp',],
                                                 :name => 'make_exception',
                                                 :pre_class_section => true,
                                                 :no_class => true,
                                               }),

                                 ],
                    :header_only => true,
                    :static_only => true,
                    :namespace => ['etf', 'utils', 'exception'],
                    :no_api_decl => true,
                  })

