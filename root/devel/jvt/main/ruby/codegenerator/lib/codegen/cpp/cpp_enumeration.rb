#######################################################################
## Copyright (c) by Daniel Davidson                                    
## All Rights Reserved.                                                
#######################################################################
require 'codegen'
require 'place'

module Codegen::Cpp

  class Enumeration

    # <b><i>User Supplied:</i></b> Name of the enumeration
    attr_accessor :name

    # True if basic enum starting at 0 with no numeric assignments
    attr_accessor :canonical

    # <b><i>User Supplied:</i></b> If true adds methods to go from string
    # (i.e. picklist representation) back to enum
    attr_accessor :supports_picklist

    # <b><i>User Supplied:</i></b> Brief description of the enumeration
    attr_accessor :brief

    attr_accessor \
    :values, :include_last, :size_enum_name, \
    :pick_list_text_proc, :mask, :numeric_values, :api_decl_text, \
    :inline

    attr_reader \
    :pick_list_text_values, :friend_text, :static_text, :api_decl, :scope_class, \
    :scope_entry_prefix, :scope_name, :dump_name, :scoped_dump_name, :picklist_variable_name

    def initialize(data={})
      @values = data[:values]
      @name = data[:name]
      @size_enum_name = @name.upcase + '_NUMBER_ENTRIES'
      @supports_picklist = data[:supports_picklist]
      @picklist_variable_name = @name + '_pick_list'
      @mask = (data[:mask]? true : false)
      @brief = data[:brief]
      @include_last = data[:include_last]
      @values.push(@name.upcase + "_LAST") if @include_last
      @pick_list_text_proc = data[:pick_list_text_proc]? data[:pick_list_text_proc] : proc { |m| m }
      @inline = data[:inline]
      @numeric_values = []
      if @mask
        @values.each_index { |i| @numeric_values.push 1<<i }
      end
      @pick_list_text_values = @values.map { |v| @pick_list_text_proc.call(v) }
      @api_decl = data[:api_decl]
      self.api_decl = @api_decl
      self.scope_class = data[:scope_class]
      @template = Tenjin::Template::new()

      @engine = Tenjin::Engine.new(:path =>Place['rb_codegen_tmpl'].to_s)
    end

    def scope_to_class txt
      if scope_class and !inline
        "#{scope_class}::#{txt}"
      else
        txt
      end
    end

    def scope_class=(sc) 
      #puts "Scoping #{name} to #{sc}"
      @scope_class = sc
      @scope_name = ((nil!=sc)? "#{sc}::#{@name}" : @name )
      @scope_entry_prefix = ((nil!=sc)? "#{sc}::" : "" )
      @dump_name = "dump_#{@name.downcase}"
      @scoped_dump_name = ((nil!=sc)? "#{sc}::dump_#{@name.downcase}" : dump_name )
      @static_text = ((nil!=sc)? 'static ' : 'extern ')
      @friend_text = ((nil!=sc)? 'friend ' : '')
      #puts "Enum #{@name} -> #{@friend_text}, #{sc}"
    end

    def api_decl=(d)
      #puts "Setting api_decl to #{d} on #{@name}"
      if !inline
        @api_decl = d
        @api_decl_text = ((d)?d+' ':'')
      end
    end

    def enum_header_contents()
      result = ""
      if @mask
        result += @engine.render("cpp_mask_enum_declaration.tmpl", { :me => self })
        result += @engine.render("cpp_mask_enum_bit_functions.tmpl", { :me => self })
      else
        result += @engine.render("cpp_enum_declaration.tmpl", { :me => self })
        if @inline
          result += @engine.render("cpp_enum_stream_impl_support.tmpl", { :me => self })
        else
          result += @engine.render("cpp_enum_stream_header_support.tmpl", { :me => self })
        end
        result += @engine.render("cpp_enum_inline_insertion_operator.tmpl", { :me => self })
      end
      return result
    end

    def enum_stream_ipml()
      if inline
        return ""
      end
      if mask
        @engine.render("cpp_mask_enum_dump_function_definition.tmpl", { :me => self })
      else
        @engine.render("cpp_enum_stream_impl_support.tmpl", { :me => self })
      end
    end
  end
end
