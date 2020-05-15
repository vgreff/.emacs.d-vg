#######################################################################
## Copyright (c) by Daniel Davidson                                    
## All Rights Reserved.                                                
#######################################################################
def dump_trace(header="")
  raise "dump_trace: #{header}"
rescue => detail
  puts detail.to_s
  puts "\t" + detail.backtrace[1..-1].join("\n\t")
end
