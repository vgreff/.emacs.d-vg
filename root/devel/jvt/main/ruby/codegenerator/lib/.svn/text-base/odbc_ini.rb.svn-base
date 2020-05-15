#######################################################################
## Copyright (c) by Daniel Davidson                                    
## All Rights Reserved.                                                
#######################################################################
require 'singleton'
require 'rubygems'
require 'parseconfig'
require 'sequel'
require 'yaml'

module OdbcIni

  class ParsedEntries
    attr_reader :odbc_ini_config
    include Singleton
    def initialize
      @odbc_ini_config = ParseConfig.new "#{ENV['HOME']}/.odbc.ini"
    end

    def get_dsn_connection dsn_name
      dsn_config = Hash[*odbc_ini_config.params[dsn_name].map{|k,v| [k.downcase, v]}.flatten ]
      result = Sequel.mysql(dsn_name, 
                            :user => dsn_config['user'], 
                            :password => dsn_config['pwd'], 
                            :host => (dsn_config['server'] or 'localhost'))
      return result
    end
  end
  

end

if $0 == __FILE__
  require 'pp'
  require 'yaml'
  p = OdbcIni::ParsedEntries.instance
  p.get_dsn_connection('system')["show tables"].each do |rec|
    puts rec
  end
  puts "Done"
end
