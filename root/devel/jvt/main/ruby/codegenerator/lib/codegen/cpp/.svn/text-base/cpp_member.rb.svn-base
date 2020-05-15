#######################################################################
## Copyright (c) by Daniel Davidson                                    
## All Rights Reserved.                                                
#######################################################################
require 'codegen'
require 'codegen/cpp'

module Codegen::Cpp

  # Used to store data required to generate members in CppClass
  #
  # =Generated Access
  #
  # The following attributes determine the access level of the attribute in the code.
  # [c++ access] public protected private
  #
  # Whereas the following attributes determine the method accessors in the code.
  # [Codegen::Access] RO, RW, IA
  #
  class Member

    # <b><i>User Supplied:</i></b> The c++ data type of the member
    attr_reader :cpp_type

    # <b><i>User Supplied:</i></b> The c++ name of the member
    attr_reader :name

    # <b><i>User Supplied:</i></b> The detailed description of the member
    attr_reader :descr

    # <b><i>User Supplied:</i></b> The brief description of the member
    attr_reader :brief

    # <b><i>User Supplied:</i></b> Text required to initiliaze the member in
    # the ctor_member_init and/or ctor_default
    attr_reader :init

    # <b><i>User Supplied:</i></b> If true makes the variable static
    attr_reader :static

    # <b><i>User Supplied:</i></b> If true makes the variable mutable
    attr_reader :mutable

    # <b><i>User Supplied:</i></b> Set to one of
    # <tt>Codegen::Access</tt>. Default is <tt>Codegen::Access::IA</tt> if not
    # set
    attr_reader :access

    # <b><i>User Supplied:</i></b> If true adds support for streaming
    # <tt>std::ostream &operator<<(...)</tt>
    attr_reader :streamable

    # <b><i>User Supplied:</i></b> If true provides a codeblock to custom
    # stream the value in <tt>std::ostream &operator<<(...)</tt>
    attr_reader :streamable_custom

    # <b><i>User Supplied:</i></b> If true adds support for serialization
    attr_reader :serializable

    # <b><i>User Supplied:</i></b> If true adds  for serialization
    attr_reader :serializable_custom

    # <b><i>User Supplied:</i></b> If true provides a codeblock to custom
    # serialize the member
    attr_reader :streamable_custom

    # <b><i>User Supplied:</i></b> If true makes the variable public
    attr_reader :public

    # <b><i>User Supplied:</i></b> If true makes the variable protected
    attr_reader :protected

    # <b><i>User Supplied:</i></b> If true makes the variable private
    attr_reader :private

    # <b><i>User Supplied:</i></b> If true accessors pass the member by
    # reference
    attr_reader :pass_by_ref

    # <b><i>User Supplied:</i></b> If true the member is itself a reference
    attr_reader :store_by_ref

    # <b><i>User Supplied:</i></b> If true the member is itself a const
    # reference
    attr_reader :store_by_cref

    # <b><i>User Supplied:</i></b> If true the member is passed into the
    # <i>ctor_member_init</i>
    attr_reader :member_ctor

    # <b><i>User Supplied:</i></b> If true the member is passed into the
    # <i>ctor_member_init</i> with a default value
    attr_reader :member_ctor_defaulted

    # <b><i>Calculated:</i></b> Name of the c++ variable
    attr_reader :variable_name

    # <b><i>User Supplied:</i></b> If true member is included in comparable
    # method
    attr_reader :comparable

    # <b><i>Calculated:</i></b> Type for passing the variable as const -
    # either by value or by pass_by_ref depending on @pass_by_ref. Convenience attribute for
    # codegen
    attr_reader :pass_type_const

    # <b><i>Calculated:</i></b> Type for passing the variable as non-const -
    # either by value or by pass_by_ref depending on @pass_by_ref. Convenience attribute for
    # codegen
    attr_reader :pass_type_non_const
    
    # <b><i>User Supplied:</i></b> An override for how to pass variables in
    # the access method definitions.  Should almost never be needed
    attr_accessor :accessor_type

    # <b><i>User Supplied:</i></b> If set, member and accessors are conditional
    attr_accessor :ifdef_identifier

    # <b><i>Calculated:</i></b> True if type is fixed_size_char_array_size
    attr_accessor :is_fixed_size_char_array

    # <b><i>Calculated:</i></b> Special member for fixed size strings - keeps size
    attr_accessor :fixed_size_char_array_size

    # <b><i>User Special:</i></b> What to insert into the stream
    attr_accessor :stream_insert_override
    
    def initialize(data={})
      # Nil default if not set attributes
      [ 

       :cpp_type, :name, :descr, :brief, :init, :static, :mutable, :pass_by_ref,
       :store_by_ref, :store_by_cref, :accessor_type, :member_ctor,
       :member_ctor_defaulted, :public, :protected, 
       :fixed_size_char_array_size, :ifdef_identifier

       
      ].each do | attr |
        self.instance_variable_set("@#{attr.to_s}", data[attr])
      end

      puts data.to_yaml if !data[:name]
      @variable_name = data[:name] + '_'
      @cpp_type = 'std::string' if cpp_type == 'string'

      if cpp_type =~ /Fixed_size_char_array\s*<\s*(\d+)\s*>/
        @is_fixed_size_char_array = true
        @fixed_size_char_array_size = $1
      end

      @pass_by_ref = true if(cpp_type == 'std::string')
      if((not @init) and (@cpp_type =~ Codegen::Cpp::FUNDAMENTAL_TYPE_RE))
        warn("WARNING Uninitialized Fundamental Type Member: type=>" + @cpp_type + " member=>" + @name) 
      end
      @pass_type_const = (@pass_by_ref)? "#{@cpp_type} const&" : "#{@cpp_type}"
      @pass_type_non_const = (@pass_by_ref)? "#{@cpp_type} &" : "#{@cpp_type}"
      @streamable = Codegen.default_to_true_if_not_set(data, :streamable)
      @streamable_custom = data[:streamable_custom]
      @streamable = true if streamable_custom
      @stream_insert_override = data[:stream_insert_override]
      @serializable = Codegen.default_to_true_if_not_set(data, :serializable)
      @serializable_custom = data[:serializable_custom]
      @serializable = true if serializable_custom
      @comparable = Codegen.default_to_true_if_not_set(data, :comparable)
      @private = (data[:private] or (not @public and not @protected))
      @access = data[:access]? data[:access] : Codegen::Access::IA
      @access = Codegen::Access::IA if @public
    end

    def ifdef text
      if ifdef_identifier
"#if defined(#{ifdef_identifier})
#{text}
#endif"     
      else
        text
      end
    end

    # Describes accessibility in codegen comments
    def access_text()
      result = case access
               when Codegen::Access::RW then "read/write"
               when Codegen::Access::RO then "read only"
               when Codegen::Access::IA then "inaccessible"
               end
      result = "open" if public
      result
    end

  end
end
