#!/usr/bin/env ruby

require 'rbconfig'
require 'etc'
require 'open3'
require 'logger'

$log = Logger.new(STDOUT)
$log.level = Logger::DEBUG

$error_log = Logger.new(STDERR)

def do_help
  puts "Usage: cap [command]"
  puts " "
  puts "Commands:"
  puts "        "
  puts "    help           display this help message"
  puts "    configure      configure change assistant general options"
  puts " "
end

def do_cmd(cmd)
  $log.debug "Executing: #{cmd}"

  stdout, stderr, status = ''

  ##{CA_EXE} assumes we are in the CA_HOME folder - relative paths are used in the script
  Dir.chdir(CA_HOME){
    stdout, stderr, status = Open3.capture3(cmd)
    unless status.success?
      $error_log.error stderr
      exit
    end
    $log.debug stdout
  }
    
  return stdout, stderr, status
end


def do_platform
  if PLATFORM == 'ORACLE' then
    $sql_bin = "bin/sqlplus.exe"
  end
end

def do_launch
  do_platform

  cmd = "#{CA_EXE}"
  
  do_cmd(cmd)

end

def do_ca_folders

  if ! File.exist?("#{CA_BASE}/output") 
    cmd = "mkdir -p #{CA_BASE}/output"
    do_cmd(cmd)
  end
  
  if ! File.exist?("#{CA_BASE}/staging")
    cmd = "mkdir -p #{CA_BASE}/staging"
    do_cmd(cmd)
  end

  if ! File.exist?("#{CA_BASE}/download")
    cmd = "mkdir -p #{CA_BASE}/download"
    do_cmd(cmd)
  end

end

def do_configure
  do_platform 
  do_ca_folders

  cmd = "#{CA_EXE} -MODE UM -ACTION OPTIONS -OUT #{CA_BASE}/output/ca.log -REPLACE Y -EXONERR Y -SWP False -MCP 5 -PSH #{PS_HOME}/ -STG #{CA_BASE}/staging/ -OD #{CA_BASE}/output/ -DL #{CA_BASE}/download/ -SQH #{SQL_HOME}/#{$sql_bin} -EMYN N"
  do_cmd(cmd)
end

def do_create_environment
  p "Not Implemented"
end

def do_import_config
  cmd = "#{CA_EXE} -MODE UM -ACTION IMPCFG -FILEPATH c:\\temp -FILE casettings.zip -SETTINGS Y -DBDEFN ALLDATABASE -REPLACEDB Y"
  stdout, stderr, status = do_cmd(cmd)

  p "stdout: #{stdout}"
  p "stderr: #{stderr}"
  p "status: #{status}"
end

def do_export_config
  cmd = "#{CA_EXE} -MODE UM -ACTION EXPCFG -FILEPATH c:\\temp -FILE casettings.zip -SETTINGS Y -DBDEFN ALLDATABASE -REPLACEDB Y"
  do_cmd(cmd)
end

def do_ptpatch

  cmd = "#{CA_EXE} -MODE UM -ACTION OPTIONS -DL #{PS_HOME}/PTP/"
  do_cmd(cmd)
    
end
