#!/usr/bin/ruby
#######################################################################
## Copyright (c) by Daniel Davidson                                    
## All Rights Reserved.                                                
#######################################################################

require 'commands'
require 'place'
include Commands

#disable_commands
run_commands([ "xgrep -tunwanted --place etf --include_ignored | xargs rm" ])
