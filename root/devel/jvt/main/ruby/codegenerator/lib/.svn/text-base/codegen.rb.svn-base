#######################################################################
## Copyright (c) by Daniel Davidson                                    
## All Rights Reserved.                                                
#######################################################################
require 'pathname'
require 'set'
require 'fileutils'

module Codegen

  class Access
    RO = 'read_only'
    RW = 'read_write'
    IA = 'inaccessible'
  end

  def Codegen.cpp_copyright(fname, brief)
    """//------------------------------------------------------------------------------
//
// Copyright (c) #{fname}  Jump Trading, LLC
// 
// All Rights Reserved. 
//-------------------------------------------------------------------------------
//! 
// \\file #{fname}
//
// \\brief #{brief}
// 
//"""
  end

  @Codegen_indent_len = 2
  @Codegen_current = ''
  NL = "\n"
  CPP_PROTECT_BLOCK_DELIMITERS = ['// custom','// end']
  BUILD_PROTECT_BLOCK_DELIMITERS = ['# custom','# end']

  def Codegen.single_indent()
    ' '*@Codegen_indent_len
  end

  def Codegen.indent()
    @Codegen_current += ' '*@Codegen_indent_len
    #puts "INDENTED: " + @Codegen_current.length.to_s
    @Codegen_current
  end

  def Codegen.outdent()
    if @Codegen_current.length > 0
      @Codegen_current = @Codegen_current[0, @Codegen_current.length-@Codegen_indent_len]
    end
    #puts "OUTDENT: " + @Codegen_current.length.to_s
    @Codegen_current
  end

  def Codegen.current_indent() 
    @Codegen_current
  end

  def Codegen.join_text txt
    txt = txt.join("") if txt.class == Array
    return txt
  end

  def Codegen.camel_case_to_binary_signal name
    prior = name
    name.gsub!(/ID/, 'Id')
    name.gsub!(/([A-Z])([A-Z]+)([A-Z])/) {"#{$1}#{$2.downcase}#{$3}"}
    name = name.sub(/([A-Z])/) {$1.downcase}.gsub(/([A-Z]+)/) { "_#{$1.downcase}" }
    warn "Caps remainging #{name}" if (name =~/[A-Z]/)
    return name
  end

  def Codegen.indent_text(txt, additional_levels = 0)
    txt = join_text txt
    i = @Codegen_current + ' '*additional_levels*@Codegen_indent_len
    i_nl = "\n" + i
    i + txt.split("\n").join(i_nl)
  end

  def Codegen.indent_absolute_text(txt, levels)
    txt = txt.join("") if txt.class == Array
    i = ' '*levels*@Codegen_indent_len
    i_nl = "\n" + i
    i + txt.split("\n").join(i_nl)
  end

  def Codegen.protect_block(name, protected_pair = CPP_PROTECT_BLOCK_DELIMITERS)
    """#{protected_pair[0]} <#{name}>\n#{protected_pair[1]} <#{name}>"""
  end

  def Codegen.align_preprocessor(text)
    text.gsub(/(\n+)[\t ]*#/, '\1#')
  end

  def Codegen.default_to_true_if_not_set(hash, key)
    if hash.has_key? key
      return hash[key]
    else
      true
    end
  end

  def Codegen.default_to_false_if_not_set(hash, key)
    if hash.has_key? key
      return hash[key]
    else
      false
    end
  end

  def Codegen.clean_templates(text)
    text.gsub(/<(\w)/, '< \1').gsub(/(\w)>/, '\1 >')
  end

  @@merge_statistics =  Hash.new {|h,k| h[k] = Hash.new {|h,k| h[k] = [] } }
  @@files_with_no_custom_code = Set.new

  def Codegen.merge_statistics
    return @@merge_statistics
  end

  def Codegen.files_with_no_custom_code
    return @@files_with_no_custom_code
  end

  def Codegen.merge(generated_text, dest_fname, rest = 
                    { 
                      :protected_pair => CPP_PROTECT_BLOCK_DELIMITERS, 
                    })
    protected_pair = (rest[:protected_pair] or CPP_PROTECT_BLOCK_DELIMITERS)
    dest_path = Pathname.new(dest_fname)
    dest_text = ""
    original_text = ""
    if dest_path.file?
      dest_text = dest_path.read
      original_text = dest_text.clone
    end

    ######################################################################
    # Merge the protected blocks
    ######################################################################
    if protected_pair[0].length > 0
      while dest_text =~ /(\n\s*#{protected_pair[0]}[^\n]+)(.*?)(#{protected_pair[1]}[^\n]+)/m
        dest_text = $'
        front = $1.strip
        guts = $2
        back = $3.strip

        guts.gsub!(/^\s*\n(\s*)/, "\n\\1")
        guts.gsub!(/\n\s*$/, "\n")
        if guts =~ /\S+/
          #puts "non-empty-block: #{dest_path}\n----------------\n#{guts}\n---------------------\n"
          @@merge_statistics[:non_empty_blocks][dest_path.basename] << back
          repl = "\n#{front}\n#{guts}\n#{back}"
        else
          #puts "Empty-block: #{dest_path}\n----------------\n#{guts}\n---------------------\n"
          @@merge_statistics[:empty_blocks][dest_path.basename] << back
          repl = "\n#{front}\n#{back}"
        end
        repl.gsub!(/\\/, '\\\\\\')
        repl = generated_text.gsub!(/#{front}.*?#{back}/m, repl)
        if false
          if repl and repl.length > 0
            print "SUBST: on #{back} NOT EMPTY: #{repl.length}\n"
          else
            print "FRONT: #{front}\n"
            print "GUTS: #{guts}\n"
            print "BACK: #{back}\n"
            print "ORIG: #{generated_text}"
            print "SUBST: on #{protected_pair[0]} IS EMPTY\n"
          end
        end
      end

      if !@@merge_statistics[:empty_blocks][dest_path.basename].empty? and
          @@merge_statistics[:non_empty_blocks][dest_path.basename].empty? 
        #puts "NO CUSTOM: #{dest_path} #{@@merge_statistics[:empty_blocks][dest_path.basename].length} and #{@@merge_statistics[:non_empty_blocks][dest_path.basename].length}"
        @@files_with_no_custom_code << dest_path
      end
    end

    if original_text.empty? or original_text != generated_text
      FileUtils.makedirs(dest_path.parent, :verbose => true) if !File.exists? dest_path.parent
      outfile = File.new(dest_path.to_s, 'w')
      outfile.write(generated_text)
      outfile.close()
      puts "Wrote updates on #{dest_fname}"
    else
      puts "No change on #{dest_fname}"
    end
    return generated_text
  end

  def Codegen.macro(txt)
    return "${#{txt}}"
  end

end
