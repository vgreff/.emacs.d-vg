#######################################################################
## Copyright (c) by Daniel Davidson                                    
## All Rights Reserved.                                                
#######################################################################
require 'fileutils'
require 'place'
require 'pathname'
require 'commands'
include Commands

$stage_path = Place['stage']
$install_path = Place['install']
$test_packages = false
FileUtils.makedirs $stage_path
FileUtils.makedirs $install_path

def build_package(pkg, commands)
  puts "Stage #{Place['stage']} + #{pkg}"
  build_dir = Place['stage'] + pkg
  puts "Changing to #{build_dir}"
  FileUtils.cd build_dir
  Commands.run_commands(commands)
end

def build_bjam
  bjam_directory = Place.packages_by_name['boost-jam'].stage_path
  build_package(bjam_directory, ["./build.sh", ])
  puts "cp #{bjam_directory + 'bin.linuxx86/bjam'}"
  FileUtils.cp(bjam_directory + 'bin.linuxx86/bjam', Place['bin'])
end

######################################################################
# Thes are simply copy-installs
######################################################################
def simple_copy_installs
  [
   'boost-build', 'stlsoft', 'tbb'
  ].each do |pkg_name|
    pkg = Place.packages_by_name[pkg_name]
    FileUtils.cp_r pkg.stage_path, pkg.install_path  
  end
end

def zlib
  pkg = Place.packages_by_name['zlib']
  commands = [ "./configure --prefix=#{pkg.install_path}" ]
  commands << "make test" if $test_packages
  commands << "make install"
  build_package(pkg.stage_path, commands)
end

def szip
  pkg = Place.packages_by_name['szip']
  commands = [ "./configure --prefix=#{pkg.install_path}" ]
  commands << "make test" if $test_packages
  commands << "make install"  
  build_package(pkg.stage_path, commands)
end

def bzip2
  pkg = Place.packages_by_name['bzip2']
  build_package(pkg.stage_path, [ "make install PREFIX=#{pkg.install_path}" ])
end

def pantheios
  stlsoft = Place.packages_by_name['stlsoft']
  pantheios = Place.packages_by_name['pantheios']
  ENV['FASTFORMAT_ROOT'] = pantheios.stage_path
  ENV['STLSOFT'] = stlsoft.install_path
  Commands.pushd(pantheios.stage_path + 'build' + 'gcc44.unix')
  commands = ['make build']
  commands << 'make test' if $test_packages
  Commands.run_commands(commands)
  Commands.popd
  # install 
  FileUtils.makedirs pantheios.install_path
  FileUtils.cp_r pantheios.stage_path + 'include', pantheios.install_path  
  FileUtils.cp_r pantheios.stage_path + 'lib', pantheios.install_path  
end

def hdf5
  pkg = Place.packages_by_name['hdf5']
  zlib_pkg = Place.packages_by_name['zlib']
  szip_pkg = Place.packages_by_name['szip']
  commands = ["./configure --prefix=#{pkg.install_path} --with-zlib=#{zlib_pkg.install_path} --with-szlib=#{szip_pkg.install_path} --enable-hl --enable-cxx --enable-production"]
  commands << 'make check' if $test_packages
  commands << 'make install'
  build_package(pkg.stage_path, commands)
end

def hdf5_debug
  pkg = Place.packages_by_name['hdf5_debug']
  zlib_pkg = Place.packages_by_name['zlib']
  szip_pkg = Place.packages_by_name['szip']
  commands = ["./configure --prefix=#{pkg.install_path} --with-zlib=#{zlib_pkg.install_path} --with-szlib=#{szip_pkg.install_path} --enable-hl --enable-cxx --enable-debug --disable-production"]
  commands << 'make check' if $test_packages
  commands << 'make install'
  build_package(pkg.stage_path, commands)
end


def boost
  pkg = Place.packages_by_name['boost']
  bzip2_pkg = Place.packages_by_name['bzip2']
  zlib_pkg = Place.packages_by_name['zlib']
  #Commands.disable_commands
  build_package(pkg.stage_path, 
                [
                 "./bootstrap.sh --prefix=#{pkg.install_path}",
                 "bjam toolset=gcc link=shared variant=debug --layout=tagged --build-dir=#{ENV['HOME']}/stage/boost_1_45_0/ --without-mpi --prefix=#{pkg.install_path} -sBZIP2_INCLUDE=#{bzip2_pkg.include_path} -sBZIP2_LIBPATH=#{bzip2_pkg.lib_path} -sZLIB_INCLUDE=#{zlib_pkg.include_path} -sZLIB_LIBPATH=#{zlib_pkg.lib_path} install",
                 "bjam toolset=gcc link=shared variant=release --layout=tagged --build-dir=#{ENV['HOME']}/stage/boost_1_45_0/ --without-mpi --prefix=#{pkg.install_path} -sBZIP2_INCLUDE=#{bzip2_pkg.include_path} -sBZIP2_LIBPATH=#{bzip2_pkg.lib_path} -sZLIB_INCLUDE=#{zlib_pkg.include_path} -sZLIB_LIBPATH=#{zlib_pkg.lib_path} install",
                ])
end

def protobuf
  pkg = Place.packages_by_name['protobuf']
  commands = ["./configure --prefix=#{pkg.install_path}"]
  commands << 'make'
  commands << 'make check' if $test_packages
  commands << 'make install'
  build_package(pkg.stage_path, commands)
end

def quickfix
  pkg = Place.packages_by_name['quickfix']
  # Quickfix does not include the versioning info in the tar
  `mv #{pkg.stage_path.parent + 'quickfix'} #{pkg.stage_path}` if !pkg.stage_path.exist?
  commands =  []
  commands << "./configure --prefix=#{pkg.install_path}"
  commands << 'make'
  commands << 'make check' if $test_packages
  commands << 'make install'
  build_package(pkg.stage_path, commands)
end

def quickfast
  pkg = Place.packages_by_name['quickfast']
  commands =  []
  commands << "./configure --prefix=#{pkg.install_path}"
  commands << 'make'
  commands << 'make check' if $test_packages
  commands << 'make install'
  build_package(pkg.stage_path, commands)
end

def speedcrunch
  pkg = Place.packages_by_name['speedcrunch']
  commands =  []
  commands << "./configure --prefix=#{pkg.install_path}"
  commands << 'make'
  commands << 'make check' if $test_packages
  commands << 'make install'
  build_package(pkg.stage_path, commands)
end

def ace
  pkg = Place.packages_by_name['ace']
  FileUtils.cd pkg.stage_path
  build_dir = pkg.stage_path + 'build'
  FileUtils.makedirs build_dir
  FileUtils.cd(build_dir)
  commands = ["../configure --prefix=#{pkg.install_path}"]
  commands += ['make']
  commands += ['make install']
  Commands.run_commands(commands)
end


################################################################################
# Build packages
################################################################################
# build_bjam
# simple_copy_installs
# zlib
# szip
# bzip2
# pantheios
# hdf5
# hdf5_debug
boost
# protobuf
# ace
# quickfix
# quickfast
# speedcrunch

