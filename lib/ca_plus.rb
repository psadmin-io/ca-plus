#!/usr/bin/env ruby

require 'rbconfig'
require 'etc'
require 'open3'

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
    p "Command: #{cmd}"
    out = `powershell -NoProfile -Command "#{cmd}"`
    p out
end

def do_platform
    if PLATFORM == 'ORACLE' then
        $sql_bin = "bin/sqlplus.exe"
    end
end

def do_launch
    do_platform

    cmd = "cd '#{CA_HOME}'; ./changeassistant.bat"
    
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

    cmd = "cd '#{CA_HOME}'; ./changeassistant.bat -MODE UM -ACTION OPTIONS -OUT #{CA_BASE}/output/ca.log -REPLACE Y -EXONERR Y -SWP False -MCP 5 -PSH #{PS_HOME}/ -STG #{CA_BASE}/staging/ -OD #{CA_BASE}/output/ -DL #{CA_BASE}/download/ -SQH #{SQL_HOME}/#{$sql_bin} -EMYN N"
    
    do_cmd(cmd)
end