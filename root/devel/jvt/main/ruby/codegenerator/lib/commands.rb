#######################################################################
## Copyright (c) by Daniel Davidson                                    
## All Rights Reserved.                                                
#######################################################################
require 'fileutils'

module Commands

  @@disable_commands = false
  
  def disable_commands
    @@disable_commands = true
  end

  def enable_commands
    @@disable_commands = false
  end

  @@dir_stack = []
  def pushd(d)
    @@dir_stack.unshift FileUtils.pwd
    FileUtils.cd d
  end

  def popd
    FileUtils.cd @@dir_stack.shift
  end

  def run_commands(commands, get_output = false)
    commands.each do |cmd|
      if !@@disable_commands
        puts "Running => #{cmd} from #{FileUtils.pwd}"
        if get_output
          output = `#{cmd}` 
        else
          puts `#{cmd}` 
        end
        puts "Done running #{cmd} => #{$?}"
      else
        puts "Skipping disabled command => #{cmd} from #{FileUtils.pwd}"
      end
      if get_output
        return output
      end
    end
  end

end
