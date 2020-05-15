#######################################################################
## Copyright (c) by Daniel Davidson                                    
## All Rights Reserved.                                                
#######################################################################
require 'pathname'
require 'pp'
require 'ostruct'

class Place

  @@is_linux = RUBY_PLATFORM.downcase.include?("linux")
  @@place = { }

  def Place.is_linux?
    return @@is_linux
  end

  def Place.place
    return @@place
  end

  def Place.[] (index)
    return @@place[index]
  end

  @@place['ruby_lib'] = Pathname.new(File.expand_path(__FILE__)).parent
  root_path = Place['ruby_lib'].parent #.parent
  # TOP = root_path.basename.to_s
  TOP = 'jvt'

  def Place.top
    return TOP
  end

  @@place[TOP] = root_path
  @@place['BRC'] = Pathname.new(ENV['JVTBRC'])
  @@place['CPP'] = Place['BRC'] + 'cpp'
  @@place['GEN'] = Place['CPP'] + TOP + 'data'

  @@place['usr_lib'] = Pathname.new('/usr/lib')
  @@place['usr_include'] = Pathname.new('/usr/include')
  @@place['cpp_standard_lib'] = Pathname.new('/usr/include/c++/4.4')
  top = @@place[TOP].parent
  @@place['ruby_scripts'] = Place['ruby_lib'] + 'scripts'
  @@place['elisp'] = Place[TOP] + 'myemacs' + 'elisp'
  @@place['doxygen'] = top + 'doxygen'
  @@place['install'] =  Pathname.new(ENV['HOME']) + 'install'
  @@place['websites'] =  Pathname.new(ENV['HOME']) + 'websites'
  @@place["#{TOP}_install"] =  top + "#{TOP}_install"
  @@place['stage'] = top + 'stage'
  @@place['bin'] = top + 'bin'
  @@place['install_include'] = top + 'include'
  @@place['rb_codegen'] = Place['ruby_lib'] + 'codegen'
  @@place['rb_codegen_tmpl'] = Place['rb_codegen'] + 'cpp' + 'tmpl'
  @@place['db_tmpl'] = Place['rb_codegen'] + 'db' + 'tmpl'
  @@place['database_tmpl'] = Place['rb_codegen'] + 'database' + 'tmpl'
  @@place['cpp'] = Place['CPP']
  # @@place['cpp'] = Place[TOP] + 'cpp'
  @@place['data'] = Place[TOP].parent + 'data'
  # @@place['libs'] = Place['cpp'] + 'libs'
  @@place['libs'] = Place['cpp']
  @@place['apps'] = Place['cpp'] + 'apps'
  @@place['python'] = root_path + 'py'
  # For generated proto files
  @@place['tracker_proto_include'] = Place['cpp'] + TOP + 'tracker' + 'proto'
  @@place['tracker_proto_impl'] = Place['libs'] + TOP + 'tracker' + 'proto' + 'src'
  @@place['tracker_proto_py'] = Place['python'] + 'tracker' + 'proto'

  class Package
    attr_reader :name, :base_name, :version_name, :url, :pkg_suffix, \
    :stage_path, :install_path, :macro_include, :macro_libpath
    def initialize(name, version_name, url, base_name = nil)
      @url = url
      @name = name
      @base_name = @version_name = version_name
      @base_name, @pkg_suffix = $1, $2 if version_name =~ /^(.+)(\.zip|\.7z|\.tar\.gz|\.tar\.bz2|\.tgz|\.bin)$/
      @base_name = base_name if base_name
      name_paths
    end

    def name_paths
      @stage_path = Place['stage'] + @base_name
      @install_path = Place['install'] + @base_name
      @macro_include = @base_name.upcase + '_INCLUDE'
      @macro_libpath = @base_name.upcase + '_LIBPATH'
    end

  end

  class CppPackage < Package
    attr_accessor :include_path, :lib_path
    def initialize(name, version_name, url, base_name = nil)
      super(name, version_name, url, base_name)
      @include_path =  install_path + 'include'
      @lib_path = install_path + 'lib'
    end
  end

  @@cpp_packages = 
    [
#     CppPackage.new('boost', 'boost_1_43_0.tar.bz2', 
#                    'http://sourceforge.net/projects/boost/files/boost/1.43.0/boost_1_43_0.tar.bz2/download'),     
#     CppPackage.new('boost', 'boost_1_44_0.tar.bz2', 
#                    'http://sourceforge.net/projects/boost/files/boost/1.44.0/boost_1_44_0.tar.bz2/download'),     
     CppPackage.new('boost', 'boost_1_45_0.7z', 
                    'http://sourceforge.net/projects/boost/files/boost/1.45.0/boost_1_45_0.7z/download'),     
     CppPackage.new('szip', 'szip-2.1.tar.gz', 
                    'http://www.hdfgroup.org/ftp/lib-external/szip/2.1/src/szip-2.1.tar.gz'),     
     CppPackage.new('zlib', 'zlib-1.2.5.tar.gz', 
                    'http://zlib.net/zlib-1.2.5.tar.gz'),     
#     CppPackage.new('hdf5', 'hdf5-1.8.4-patch1.tar.bz2', 
#                    'http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.4-patch1.tar.bz2'),     

     CppPackage.new('hdf5', 'hdf5-1.8.6.tar.bz2', 
                    'http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.6.tar.bz2'),     

     CppPackage.new('hdf5_debug', 'hdf5-1.8.6.tar.bz2', 
                    'http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.6.tar.bz2', 'hdf5_debug'),     

     CppPackage.new('stlsoft', 'stlsoft-1.9.97.zip', 
                    'http://downloads.sourceforge.net/project/stlsoft/STLSoft%201.9/1.9.97/stlsoft-1.9.97-hdrs.zip?use_mirror=iweb'),
     CppPackage.new('pantheios', 'pantheios-1.0.1-beta196.zip', 
                    'http://sourceforge.net/projects/pantheios/files/Pantheios%20%28C%20and%20Cxx%29/1.0.1%20%28beta%20196%29/pantheios-1.0.1-beta196.zip/download'),     
     CppPackage.new('bzip2', 'bzip2-1.0.5.tar.gz', 'http://www.bzip.org/1.0.5/bzip2-1.0.5.tar.gz'),
     CppPackage.new('otl', 'otlv4_h.zip', 'http://otl.sourceforge.net/otlv4_h.zip', base_name = 'otlv4'),     
     CppPackage.new('tbb', 'tbb30_018oss_lin.tgz', 'http://www.threadingbuildingblocks.org/uploads/78/154/3.0/tbb30_018oss_lin.tgz',
                    base_name = 'tbb30_018oss'),
     # UNTESTED
     CppPackage.new('qt', 'qt-sdk-linux-x86-opensource-2010.02.bin', 
                    'http://get.qt.nokia.com/qtsdk/qt-sdk-linux-x86-opensource-2010.02.bin',
                    base_name = 'qtsdk-2010.02'),

     CppPackage.new('protobuf', 'protobuf-2.3.0.tar.bz2', 'http://protobuf.googlecode.com/files/protobuf-2.3.0.tar.bz2'),
     CppPackage.new('ace', 'ace_tao_5_8_1.tar.gz', 'http://download.dre.vanderbilt.edu/previous_versions/ACE+TAO+CIAO-5.8.1.tar.gz'),
     CppPackage.new('quickfix', 'quickfix-1.13.3.tar.gz', 'http://prdownloads.sourceforge.net/quickfix/quickfix-1.13.3.tar.gz'),
     CppPackage.new('quickfast', 'quickfast_lnx_src_1_2.tar.gz', 'http://quickfast.googlecode.com/files/quickfast_lnx_src_1_2.tar.gz'),
     CppPackage.new('speedcrunch', 'speedcrunch-0.10.1.tar.gz', 'http://speedcrunch.googlecode.com/files/speedcrunch-0.10.1.tar.gz'),
     CppPackage.new('rcpp', 'rcpp_0.8.6.tar', 'http://cran.r-project.org/src/contrib/Rcpp_0.8.6.tar.gz'),     
     CppPackage.new('rcpp_armadillo', 'rcppArmadillo_0.2.7.tar.gz', 'http://cran.r-project.org/src/contrib/RcppArmadillo_0.2.7.tar.gz'),     
     CppPackage.new('inline', 'inline_0.3.6.tar.gz', 'http://cran.r-project.org/src/contrib/inline_0.3.6.tar.gz'),
     CppPackage.new('armadillo', 'armadillo-0.9.80.tar.gz', 'http://downloads.sourceforge.net/arma/armadillo-0.9.80.tar.gz'),
     CppPackage.new('linux-kernel', 'linux-2.6.36.tar.bz2', 'http://www.kernel.org/pub/linux/kernel/v2.6/linux-2.6.36.tar.bz2'),
    ]

  def Place.cpp_packages
    @@cpp_packages
  end

  @@general_packages = [
     Package.new('boost-build', 'boost-build.tar.bz2', 
                 'http://prdownloads.sourceforge.net/boost/boost-build-2.0-m12.tar.bz2'),
     Package.new('boost-jam', 'boost-jam-3.1.17.tgz', 
                 'http://sourceforge.net/projects/boost/files/boost-jam/3.1.17/boost-jam-3.1.17.tgz/download'),     
     Package.new('gem', 'rubygems-1.3.6.tgz', 'http://rubyforge.org/frs/download.php/69365/rubygems-1.3.6.tgz'),
     Package.new('tenjin', 'rbtenjin-0.6.2.tar.gz', 
                 'http://sourceforge.net/projects/tenjin/files/rbtenjin/0.6.2/rbtenjin-0.6.2.tar.gz/download'),
     Package.new('quantlib', 'QuantLib-1.0.1.tar.gz',
                 'http://sourceforge.net/projects/quantlib/files/QuantLib/1.0.1/QuantLib-1.0.1.tar.gz/download')
    ] 

  # @@packages = @@cpp_packages + @@general_packages
  @@packages = @@general_packages
  def Place.packages
    @@packages
  end
  @@packages_by_name = { }
  @@packages.each { |p| @@packages_by_name[p.name] = p }
  def Place.packages_by_name
    @@packages_by_name
  end

  @@jam_place = { }
  @@system_include_paths = { }
  @@system_lib_paths = { }

  # QT has non-standard include path, so override
  # qt_package = @@packages_by_name['qt']
  # qt_package.include_path = qt_package.install_path + 'qt' + 'include'
  # @@place['qt_bin'] = qt_package.install_path + 'qt' + 'bin'
  # @@place['qt_src'] = qt_package.install_path + 'qt' + 'src'
  # qt_packages = 
  #   [ 
  #    OpenStruct.new({
  #                     :name => "qt_core", 
  #                     :include_path => qt_package.include_path + 'QtCore', 
  #                     :lib_path => qt_package.lib_path }),
  #    OpenStruct.new({
  #                     :name => "qt_gui", 
  #                     :include_path => qt_package.include_path + 'QtGui', 
  #                     :lib_path => qt_package.lib_path }),
  #   ]

  # ace_package = [
  #                OpenStruct.new({
  #                                 :name => "ace", 
  #                                 :include_path => '/usr/share/ace', 
  #                                 :lib_path => '/usr/share/ace/lib' }),
  #               ]

  r_packages = 
    [
     OpenStruct.new({
                      :name => "rcpp", 
                      :include_path => '/usr/local/lib/R/site-library/Rcpp/include', 
                      :lib_path => '/usr/local/lib/R/site-library/Rcpp/lib' }),

     OpenStruct.new({
                      :name => "rcpp_armadillo", 
                      :include_path => '/usr/local/lib/R/site-library/RcppArmadillo/include', 
                      :lib_path => '/usr/local/lib/R/site-library/RcppArmadillo/libs' }),

     OpenStruct.new({
                      :name => "r", 
                      :include_path => '/usr/share/R/include', 
                      :lib_path => '/usr/lib/R/lib' }),
    ]

  # (@@cpp_packages + qt_packages + r_packages).each do | cpp_package |
  #   @@jam_place[cpp_package.name.upcase + '_INCLUDE_PATH'] =  cpp_package.include_path
  #   @@jam_place[cpp_package.name.upcase + '_LIB_PATH'] =  cpp_package.lib_path
  #   @@place[cpp_package.name + '_include'] = cpp_package.include_path
  #   @@system_include_paths[cpp_package.name] = cpp_package.include_path
  #   @@place[cpp_package.name + '_lib'] = cpp_package.lib_path
  #   @@system_lib_paths[cpp_package.name] = cpp_package.lib_path
  #   @@place[cpp_package.name + '_stage'] = cpp_package.stage_path
  # end
  @@general_packages.each do | package |
    @@place[package.name + '_install'] = package.install_path
  end

  def Place.system_include_paths
    @@system_include_paths
  end

  def Place.system_include_macros
    @@system_include_macros
  end

  @@system_include_macros = { }
  @@system_include_paths.each do |include, path|
    @@place["#{include}_include"] = path
    @@system_include_macros[include] = "#{include.upcase}_INCLUDE"
  end

  def Place.jam_place
    @@jam_place
  end

end

if $0 == __FILE__
  require 'optparse'
  require 'yaml'
  options = {:path => [] }
  optparse = OptionParser.new do |opts|
    opts.banner = %Q{Usage: #{Pathname.new(__FILE__).basename}
    ### Shows results of a linear model run including coefficients, z_value,
    ### std_err
    }
    opts.separator ""
    opts.separator "Specific options:"
    opts.on('-h', '--help', 'Display this screen' ) do
      raise "Help Follows"
    end
    opts.on('-p', '--path PATH_NAME', "Name of path to show fully qualified path of") do |path|
      options[:path] <<  path
    end
    opts.on('-a', '--all', "Shows all paths") do |all|
      options[:all] = all
    end
  end

  begin 
    optparse.parse!
    options[:path].each do |p|
      puts Place[p]
    end
    if options[:all]
      puts Place.place.to_yaml
    end
  rescue RuntimeError => msg
    puts msg
    puts optparse
  end
end
