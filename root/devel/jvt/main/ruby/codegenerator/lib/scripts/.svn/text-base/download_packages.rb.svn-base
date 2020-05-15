#######################################################################
## Copyright (c) by Daniel Davidson                                    
## All Rights Reserved.                                                
#######################################################################
$:.unshift "#{ENV['HOME']}/ruby/lib"
require 'find'
require 'place'
require 'etfpkg'
include FcsPkg
require 'fileutils'
require 'commands'
require 'tenjin'
include Commands

def banner(txt)
  s = '*'*80
  puts s
  puts "*  " + txt.split('\n').join("\n*  ")
  puts s
end

$vimscripts = [ 
               [ 'http://www.vim.org/scripts/download_script.php?src_id=11834', 'NERD_tree.zip' ],
               [ 'http://www.vim.org/scripts/download_script.php?src_id=7701', 'taglist_45.zip' ],
#               [ 'http://www.vim.org/scripts/download_script.php?src_id=3640', 'minibufexpl.vim' ],
#               [ 'http://www.vim.org/scripts/download_script.php?src_id=5768', 'vimoutliner-122.zip' ],
               [ 'http://www.vim.org/scripts/download_script.php?src_id=12743', 'vcscommand-1.99.40.zip' ],
               [ 'http://www.vim.org/scripts/download_script.php?src_id=12904', 'bufexplorer.zip' ],
               [ 'http://www.vim.org/scripts/download_script.php?src_id=7722', 'omnicppcomplete-0.41.zip' ],
               [ 'http://www.vim.org/scripts/download_script.php?src_id=11853', 'supertab.vba' ],
               [ 'http://www.vim.org/scripts/download_script.php?src_id=3666', 'crefvim.zip' ],
               [ 'http://www.vim.org/scripts/download_script.php?src_id=10778', 'code_complete.vim', ],
               [ 'http://www.vim.org/scripts/download_script.php?src_id=9596', 'tselectbuffer.vim', ],
               [ 'http://www.vim.org/scripts/download_script.php?src_id=12751', 'tlib.vba', ],
              ]

def vimscript_install
  install_path = "#{ENV['HOME']}/.vim"
  plugin_path = "#{ENV['HOME']}/.vim/plugin"
  doc_path = "#{ENV['HOME']}/.vim/doc"
  FileUtils.makedirs(install_path)
  FileUtils.cd(install_path)
  $vimscripts.each do |vs|
    url, file = vs
    banner "Installing vim script #{file}"
    Commands.run_commands(["wget -O #{file} #{url}"])
    if file =~ /\.zip$/
      Commands.run_commands(["unzip -fo #{file}"])
      FileUtils.rm file
    else
      FileUtils.mv(file, plugin_path)
    end
  end
  FileUtils.chown_R('ddavidson', 'ddavidson', install_path)
end

def thirdparty_pkg_install
  stage_path = Place.place['stage']
  FileUtils.makedirs stage_path if !stage_path.exist?
  Place.packages_by_name.each do | name, package |
    #next if not ((name == 'hdf5') or (name == 'boost'))
    #next if not (name == 'linux-kernel')
    #next if not (name == 'hdf5_debug')
    banner "Installing thirdparty pkg #{package.version_name} as #{package.base_name}"
    download_inflate_pkg(package.url, package.version_name, stage_path, package.base_name)
  end
  #FileUtils.chown_R('ddavidson', 'ddavidson', stage_path, :verbose => true)  
end

def boost_sandbox_additions
  boost = Place.packages_by_name['boost']
  sandbox = Place['stage'] + 'boost_vault'
  FileUtils.makedirs sandbox if !sandbox.exist?
  Commands.pushd sandbox
  sandbox_additions = [
                       [ Pathname.new('memory'), 'http://svn.boost.org/svn/boost/sandbox/memory' ], 
# move causes problems with python
#                       [ Pathname.new('move'), 'http://svn.boost.org/svn/boost/sandbox/move' ], 
                       [ Pathname.new('numpy'), 'http://svn.boost.org/svn/boost/sandbox/numpy' ], 
                       [ Pathname.new('process'), 'http://svn.boost.org/svn/boost/sandbox/process' ], 
                       [ Pathname.new('python_extensions'), 'http://svn.boost.org/svn/boost/sandbox/python_extensions' ], 
                       [ Pathname.new('statistics'), 'http://svn.boost.org/svn/boost/sandbox/statistics' ], 
                       [ Pathname.new('units'), 'http://svn.boost.org/svn/boost/sandbox/units' ], 
                       [ Pathname.new('visualization'), 'http://svn.boost.org/svn/boost/sandbox/SOC/2007/visualization']
                      ]
  sandbox_additions.each do | dir, addition |
    run_commands(["svn co #{addition}"])
    run_commands(["find #{dir} -type d -name .svn | xargs rm -rf"])
    banner "Installing boost sandbox project: #{dir} from #{addition}"
    Find.find(dir) do |d|
      if File.directory? d and d =~ /(boost|libs)$/
        dest = boost.stage_path + $1
        Dir["#{d}/*"].each do | inner |
          if File.directory? inner
            FileUtils.cp_r File.expand_path(inner), dest, { :verbose => true }
            Find.prune
          else
            FileUtils.cp File.expand_path(inner), dest, { :verbose => true }
          end
        end
      end
    end
  end
  Commands.popd
end

def create_bash
  engine = Tenjin::Engine.new()
  output = engine.render("#{Place['rb_codegen_tmpl']}/bash.tmpl", { })
  puts output
end

def get_kml
  kml_place = Place['stage'] + 'kml'
  FileUtils.makedirs kml_place if !kml_place.exist?
  Commands.pushd kml_place
  run_commands(["svn checkout http://www.terborg.net/svn/trunk/kml"])
  Commands.popd
end

#vimscript_install
thirdparty_pkg_install
#boost_sandbox_additions
#create_bash
#get_kml
