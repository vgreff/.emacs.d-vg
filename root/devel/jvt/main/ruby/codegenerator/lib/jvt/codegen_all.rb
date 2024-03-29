#!/usr/bin/ruby
#$VERBOSE=true
#######################################################################
## Copyright (c) by Daniel Davidson                                    
## All Rights Reserved.                                                
#######################################################################

def print_merge_statistics
  require 'terminal-table/import'
  require 'yaml'

  merge_statistics = Codegen.merge_statistics
  # puts merge_statistics.to_yaml

  if false
    ascii_table = table do |t|
      merge_statistics[:non_empty_blocks].each_pair do |file, block_data|
        next if block_data.empty?
        t.add_row [ file, block_data[0].gsub(/.*?end\s*/, '') ]
        block_data[1..-1].each do |block|
          t.add_row [ nil, block.gsub(/.*?end\s*/, '') ]
        end
        t.add_separator
      end
      t.headings = [ 'File', 'Blocks that have code']
    end
    puts ascii_table if ascii_table.rows.length > 0
  end

  ascii_table = table do |t|
    merge_statistics[:empty_blocks].each_pair do | file, block_data |
      next if block_data.empty?
      t.add_row [ file, block_data[0].gsub(/.*?end\s*/, '') ]
      block_data[1..-1].each do |block|
        t.add_row [ nil, block.gsub(/.*?end\s*/, '') ]
      end
      t.add_separator
    end
    t.headings = [ 'File', 'Blocks that have no code' ]
  end
  puts ascii_table if ascii_table.rows.length > 0

  files_with_no_custom_code = Codegen.files_with_no_custom_code
  ascii_table = table do |t|
    fields = []
    files_with_no_custom_code.each do |p|
      basename = p.basename
      # Program options have no custom code, so skip
      skip = basename.to_s =~ /program_options/
      next if skip
      type = case basename
             when /^test/
               'Test'
             when /\.hpp/
               'Header'
             else
               'Impl'
             end
      fields << [ type, p.parent, basename ]
    end
    prev_type, prev_folder = nil, nil      
    fields.sort.each do |type, folder, file|
      t.add_separator if (type != prev_type or folder != prev_folder) and prev_type
      t.add_row [ ((type == prev_type)? nil : type), 
                  ((folder == prev_folder)? nil : folder), file ]
      prev_type, prev_folder = type, folder
    end
    t.headings = [ 'File', 'Folder', 'Files without custom code',]
  end
  puts ascii_table if ascii_table.rows.length > 0

end


if $0 == __FILE__
  require 'optparse'
  require 'ftools'
  require 'place'
  require 'ostruct'
  require 'commands'
  include Commands
#  require 'codegen/database/database'

  options = OpenStruct.new
  options.doxygen = false
  options.ctags = false
  options.libs = false
  options.apps = false
  options.db = false
  optparse = OptionParser.new do |opts|
    opts.banner = "Usage: lib_all.rb [options]"
    opts.separator ""
    opts.separator "Specific options:"
    opts.on('-h', '--help', 'Display this screen' ) do
      raise "Help Follows"
    end
    opts.on('-d', '--doxygen', "Generate doxygen" ) do |m|
      options.doxygen = true
    end
    opts.on('-c', '--ctags', "Generate ctags" ) do |m|
      options.ctags = true
    end
    opts.on('-e', '--emacs', "Generate emacs goodies" ) do |m|
      options.emacs = true
    end
    opts.on('-l', '--libs', "Generate libs" ) do |m|
      options.libs = true
    end
    opts.on('-a', '--apps', "Generate apps" ) do |m|
      options.apps = true
    end
    opts.on('-t', '--tests', "Generate tests" ) do |m|
      options.tests = true
    end
    opts.on('-m', '--merge_stats', "Reports what merges have taken place (or not)" ) do |m|
      options.merge_stats = m
    end
    opts.on('', '--db', "Generate db code" ) do |m|
      options.db = true
    end
  end

  $generate_all
  begin 
    optparse.parse!
    if not (options.apps or options.libs or options.tests or options.db)
      # $generate_all = options.apps = options.libs = options.tests = options.db = true
      $generate_all = options.apps = options.libs = true
    end
  rescue Exception => e
    puts e.message
    puts optparse
    exit(0)
  end

  $top = Place.top
  #puts "VG=#{$top}"
  puts "Requiring #{$top}/all_libs"
  if options.libs
    puts "\t#{'*' * 20} GENERATING LIBS #{'*' * 20}"
    require "#{$top}/all_libs" 
  end
  puts "Requiring #{$top}/all_tests"
  if options.tests
    puts "\t#{'*' * 20} GENERATING TESTS #{'*' * 20}"
    require "#{$top}/all_tests" 
  end

  if options.apps
    puts "\t#{'*' * 20} GENERATING APPS #{'*' * 20}"
    require "#{$top}/all_apps" if options.apps
  end

  if options.db
    puts "\t#{'*' * 20} GENERATING DB #{'*' * 20}"
    require "#{$top}/all_schemas" if options.db
  end

  top_path = Place[$top]
  cpp_path = Place['cpp']
  tmpl_path = Place['rb_codegen_tmpl']
  ruby_lib_path = Place['ruby_lib']
  config_path = top_path + 'config'

  if $generate_all
    puts "\t#{'*' * 20} GENERATING BUILD SCRIPTS #{'*' * 20}"
    # All code has been generated, now generate the build scripts
    engine = Tenjin::Engine.new()
    context = { 
      :all_libs => Codegen::Cpp::Library.all_libs, 
      :all_apps => Codegen::Cpp::Application.all_apps 
    }
    #Codegen.merge(engine.render("#{tmpl_path}/jamfile.tmpl", context), cpp_path + 'Jamfile')
    # if options.emacs
    #   Codegen.merge(engine.render("#{tmpl_path}/jam_master.tmpl", context), Place['elisp'] + 'jam_master.el')
    # end
    Codegen.merge(engine.render("#{tmpl_path}/Makefile.tmpl", context), Place['GEN'] + 'Makefile')

    # cpp_place = engine.render("#{tmpl_path}/cpp_place.tmpl", context)
    # Codegen.merge(cpp_place, ruby_lib_path + 'cpp_place.rb')
    # eval cpp_place

    # if Place.is_linux? 
    #   Codegen.merge(engine.render("#{tmpl_path}/linux-site-config.tmpl", context), 
    #                 top_path.parent + 'install' + 'boost-build' + 'site-config.jam')
    # else
    #   Codegen.merge(engine.render("#{tmpl_path}/windows-site-config.tmpl", context), config_path + 'site-config.jam')
    #   #Codegen.merge(output, "#{Place[top]}/config/windows-paths.jam")
    # end

    print_merge_statistics if options.merge_stats

  end

  def relevant_libs
    result = [ ]
    all_libs = Codegen::Cpp::Library.all_libs
    all_libs.each do |lib|
      #next if ['etf_sample'].include? lib.name
      puts "Adding #{lib.header_path} named #{lib.name}"
      result << lib.header_path
      result << lib.cpp_path
    end
    return result
  end

  if options.doxygen
    context = OpenStruct.new
    input = relevant_libs
    context.project_name = $top
    context.input = input.join(' ')
    context.qhp_namespace = $top
    context.output_directory = Place['doxygen'] + 'output' + $top
    output = engine.render("#{Place['rb_codegen_tmpl']}/doxygen.tmpl", context)
    doxy_file = Place['doxygen'] + 'stage' + "#{$top}.doxy"
    Codegen.merge(output, doxy_file)
    #pushd context.output_directory
    run_commands ["doxygen #{doxy_file}"]
  end

  if options.ctags
    input = relevant_libs
    require 'tempfile'
    file_list_file = Tempfile.new('ctags_input')
    puts file_list_file.path
    puts "writing data"
    file_list_file.puts `ruby #{Place['ruby_scripts']}/xgrep.rb -tcpp -p#{Place['cpp']}`
    file_list_file.close
    puts `ctags -L #{file_list_file.path} -o#{ENV['HOME']}/TAGS`
    puts `etags -L #{file_list_file.path} -o#{ENV['HOME']}/ETAGS`
  end
end

