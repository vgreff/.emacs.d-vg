#######################################################################
## Copyright (c) by Daniel Davidson                                    
## All Rights Reserved.                                                
#######################################################################
require 'yaml'
require 'place'
require 'codegen/cpp/cpp_member'
require 'codegen/cpp/cpp_enumeration'
require 'codegen/cpp/cpp_class'
require 'codegen/cpp/cpp_lib'
require 'codegen/cpp/cpp_app'
require 'codegen/cpp/cpp_option_class'
require 'codegen/cpp/cpp_file'
require 'codegen/cpp/cpp_hdf5_log_group'
require 'codegen'
require 'set'
require 'pp'

module Codegen
  module Cpp

    FUNDAMENTAL_TYPE_RE = Regexp::compile(%q(^(?:
char|
signed\s+char|
unsigned\s+char|
short\s+int|
int|
long\s+int|
unsigned\s+short\s+int|
unsigned\s+int|
unsigned\s+long\s+int|
wchar_t|
bool|
float|
double|
long\s+double
)$), 
                                          Regexp::EXTENDED)
    Codegen::Cpp::SystemHeaders = 
      Set.new([

               'algorithm', 'bitset', 'complex', 'deque', 'exception',
               'fstream', 'functional', 'hash_map', 'hash_set', 'iomanip',
               'ios', 'iosfwd', 'iostream', 'iso646.h', 'istream', 'iterator',
               'limits', 'list', 'locale', 'map', 'memory', 'new', 'numeric',
               'ostream', 'queue', 'set', 'sstream', 'stack', 'stdexcept',
               'streambuf', 'string', 'strstream', 'utility', 'valarray',
               'vector', 'cassert', 'cctype', 'cerrno', 'cfloat', 'ciso646',
               'climits', 'clocale', 'cmath', 'csetjmp', 'csignal', 'cstdarg',
               'cstddef', 'cstdio', 'cstdlib', 'cstring', 'ctime', 'cwchar',
               'cwctype',

              ] +
              
              # C Posix
              [

               'aio.h', 'arpa/inet.h', 'assert.h', 'complex.h', 'cpio.h',
               'ctype.h', 'dirent.h', 'dlfcn.h', 'errno.h', 'fcntl.h',
               'fenv.h', 'float.h', 'fmtmsg.h', 'fnmatch.h', 'ftw.h',
               'glob.h', 'grp.h', 'iconv.h', 'inttypes.h', 'iso646.h',
               'langinfo.h', 'libgen.h', 'limits.h', 'locale.h', 'math.h',
               'monetary.h', 'mqueue.h', 'ndbm.h', 'net/if.h', 'netdb.h',
               'netinet/in.h', 'netinet/tcp.h', 'nl_types.h', 'poll.h',
               'pthread.h', 'pwd.h', 'regex.h', 'sched.h', 'search.h',
               'semaphore.h', 'setjmp.h', 'signal.h', 'spawn.h', 'stdarg.h',
               'stdbool.h', 'stddef.h', 'stdint.h', 'stdio.h', 'stdlib.h',
               'string.h', 'strings.h', 'stropts.h', 'sys/ipc.h',
               'sys/mman.h', 'sys/msg.h', 'sys/resource.h', 'sys/select.h',
               'sys/sem.h', 'sys/shm.h', 'sys/socket.h', 'sys/stat.h',
               'sys/statvfs.h', 'sys/time.h', 'sys/times.h', 'sys/types.h',
               'sys/uio.h', 'sys/un.h', 'sys/utsname.h', 'sys/wait.h',
               'syslog.h', 'tar.h', 'termios.h', 'tgmath.h', 'time.h',
               'trace.h', 'ulimit.h', 'unistd.h', 'utime.h', 'utmpx.h',
               'wchar.h', 'wctype.h', 'wordexp.h',

              ]

              ) 
    def Cpp.clean_accessors(text, is_struct = false)
      data = text.gsub(/((?:public|protected|private):)\s+((?:public|protected|private):)/m) { "#{$2}" }
      data = data.split(/((?:public|private|protected):)/)
      moribund = []
      prev = nil
      data.each_index do |i|
        if data[i] =~ /^((?:public|private|protected):)$/
          current = $1 
          if prev == current
            moribund << i 
          end
          prev = current
        elsif data[i] =~ /^\s+$/
          #moribund << i-1
          #moribund << i
        end
      end
      moribund.reverse.each do |i|
        data[i-1].chomp!
        data.delete_at i
      end
      if is_struct
        if data[1] == 'public:'
          data.delete_at 1 
          data[0].chomp!
        end
      else
        if data[1] == 'private:'
          data.delete_at 1 
          data[0].chomp!
        end
      end
      data.join('')
    end

    def Cpp.clean_typedef(td)
      return td.sub(/<(\S)/, '< \1').sub(/(\S)>/, '\1 >')
    end

    def Cpp.template_types_from_template_decls(template_decls)
      template_decls.map { |td| $1 if td =~ /\s*[\w:]+\s+(\w+)/ }
    end

    def Cpp.header_path(namespace)
      Place.place['cpp']+namespace.join('/')          
    end

    def Cpp.impl_path(namespace)
      # Place.place['libs']+namespace.join('/')+'src'
      Place.place['libs']+namespace.join('/')
    end

    def Cpp.clean_ordered(a)
      result = []
      data = Set.new()
      a.each do |i|
        result.push i if not data.include? i
        data.add i
      end
      return result
    end

    def Cpp.make_c_string_literal txt, indent = ''
      if txt.empty?
        return '""'
      else
        lines = txt.split(/\n/)
        last_index = lines.length - 1
        result = []
        lines.each_index do |i|
          result << "#{indent}\"" + lines[i] + ((i == last_index)? '"' : "\\n\"")
        end
        result.join("\n")
      end
    end

    def Cpp.resolve_include_lambdas(includes)
      includes.collect {|i| (i.class == Proc)? i.call() : i }
    end

    def Cpp.clean_includes(includes)
      includes = resolve_include_lambdas includes
      include_set = Set.new()
      result = []
      boost = []
      pantheios = []
      other_system = []
      latter = []
      current = ""
      includes.each do |i|
        if i.to_s =~ /([<"]?)(.*)[>"]?/
          system_header = $1 == '<'
          guts = $2
          if guts =~ /^\s*$/
            print "SKIPPING EMPTY INCLUDE #{includes.join(%Q{, })}\n"
            next
          end
          if Codegen::Cpp::SystemHeaders.include? guts
            current = "#include <#{guts}>" 
            latter.push current if not include_set.include? current
          elsif guts =~ /boost\//
            current = "#include <#{guts}>" 
            boost.push current if not boost.include? current
          elsif guts =~ /pantheios\//
            current = "#include <#{guts}>" 
            pantheios.push current if not pantheios.include? current
          elsif system_header
            current = "#include #{i}"
            other_system.push current if not other_system.include? current
          # elsif guts =~ /jvt\//
          #   #puts "#{i.inspect}"
          #   current = "#include \"#{i.basename}\"" 
          #   result.push current if not include_set.include? current
         else
            current = "#include \"#{i}\"" 
            result.push current if not include_set.include? current
          end
        else
          print "SKIPPING (#{i}) #{i =~ /([<\"]?)(.*)[>\"]?/}\n"
        end
        
        include_set.add current
      end
      all_includes = (((pantheios.length>0)? pantheios : []) +
                      result + 
                      ((other_system.length>0)? other_system : []) +
                      ((boost.length>0)? boost : []) +
                      ((latter.length>0)? latter : []))
      all_includes.delete_if {|incl| incl =~ /#include <iosfwd>/ } if all_includes.include? '#include <iostream>'
      includes_win_warnings = { 
        'boost/program_options.hpp' => [ 4275, 4251 ],
      }

      includes_win_warnings.each do | include, warnings |
        all_includes.map! do |i|               
          if i =~ /#{include}/
              i = "#if defined(_MSC_VER)
#pragma warning(push)
#pragma warning(disable : #{warnings.join(' ')})
#endif
#{i}
#if defined(_MSC_VER)
#pragma warning(pop)
#endif
" 
          else
            i = i
          end
        end
      end
      all_includes.join("\n")
    end
  end
end

