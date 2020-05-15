#!/usr/bin/ruby
#######################################################################
## Copyright (c) by Daniel Davidson                                    
## All Rights Reserved.                                                
#######################################################################

require 'commands'
require 'place'
$top = Place.top
require 'scripts/clean_unwanted'

include Commands

run_commands([ 
              "rm -rf #{Place['etf_install']}",
              "rm -rf #{ENV['HOME']}/build-dir",
              "rm -rf #{ENV['HOME']}/etf/cpp/install_shared_debug",              
              "rm -rf #{ENV['HOME']}/etf/cpp/install_shared_release",          
              "rm -rf #{ENV['HOME']}/etf/cpp/install_static_debug",          
              "rm -rf #{ENV['HOME']}/etf/cpp/install_static_release",          
             ])

