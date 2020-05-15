#######################################################################
## Copyright (c) by Daniel Davidson                                    
## All Rights Reserved.                                                
#######################################################################
require 'fileutils'
require 'pathname'
require 'commands'
include Commands

module FcsPkg

  class PkgFileType
    NONE = 0
    ZIP = 1
    SEVEN_ZIP = 2
    TAR_GZIP = 3
    TAR_BZIP2 = 5
  end
  
  def pkg_name_type(file)
    if file.basename.to_s =~ /^(.+)(\.zip|\.7z|\.tar\.gz|\.tgz|\.tar\.bz2)$/
      name, type = $1, $2
      case type
      when '.zip'
        type = PkgFileType::ZIP
      when '.7z'
        type = PkgFileType::SEVEN_ZIP
      when '.tar.gz'
        type = PkgFileType::TAR_GZIP
      when '.tgz'
        type = PkgFileType::TAR_GZIP
      when '.tar.bz2'
        type = PkgFileType::TAR_BZIP2
      else
        raise "Pkg type (#{type}}) not supported!"
      end
      [name, type]
    else
      [file.basename, PkgFileType::NONE]
    end
  end

  @@cleanup = true
  def cleanup_file(file)
    if @@cleanup and File.exists? file
      FileUtils.rm file
    end
  end

  def download_inflate_pkg(url, file, goto = Place['stage'], pkg_name = nil)
    if goto
      FileUtils.makedirs goto if !goto.exist?
      cwd = FileUtils.pwd
      FileUtils.cd goto
    end
    file = Pathname.new file 
    pkg, type = pkg_name_type file
    puts "Package #{file} from #{FileUtils.pwd} with parent #{file.parent} (#{pkg}, #{pkg_name}) and type #{type}"
    
    if File.directory? file.parent + pkg
      puts "#{pkg} in #{file.parent} already exists"
    else
      puts "Getting #{pkg} #{type}..."
      Commands.run_commands ["wget #{url} -O #{file}"]
      cleanup = true
      case type
      when PkgFileType::ZIP
        Commands.run_commands ["unzip -o #{file}"]
        cleanup_file file
      when PkgFileType::SEVEN_ZIP
        Commands.run_commands ["7z -e #{file}"]
        cleanup_file file
      when PkgFileType::TAR_GZIP
        Commands.run_commands ["tar -xvzf #{file}"]
        cleanup_file file
      when PkgFileType::TAR_BZIP2
        tar_file = file.to_s.gsub(/\.bz2$/,'')
        Commands.run_commands ["bunzip2 #{file}", "tar -xvf #{tar_file}"]
        cleanup_file tar_file
      end
      puts "PKG => #{pkg.inspect}"
      puts "PKG_NAME => #{pkg_name.inspect}"
      if pkg_name and (pkg_name != pkg)
        puts "MOVING TO => #{pkg_name.inspect}"
        FileUtils.mv(pkg, pkg_name)
      end
      if goto
        FileUtils.cd cwd
      end
    end
  end
end

