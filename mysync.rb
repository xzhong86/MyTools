#!/usr/bin/env ruby

# Usage:
#  mysync.rb init [remote] [local]
#  mysync.rb up   [local]
#  mysync.rb down [local]
# Example:
#  alias mysync path/to/mysync.rb
#  mysync init remote:~/sync/data  # init local with remote
#  cd data/
#  mysync down  # download sync
#  mysync up    # upload sync

require 'ostruct'
require 'optparse'
require 'json'

INFO_FILE = '.mysync.json'

def read_sync_info(opts)
  path = File.join(opts.local, INFO_FILE)
  info = JSON.load(IO.read(path))
  opts.remote = OpenStruct.new(info).remote
end
def write_sync_info(opts)
  path = File.join(opts.local, INFO_FILE)
  IO.write(path, JSON.dump({ remote: $opts.remote }))
end

def do_sync(opts)
  local, remote = opts.local, opts.remote.chomp('/')
  local = File.expand_path(local)
  Dir.mkdir(local) if not Dir.exist?(local)
  if opts.up
    cmd = "rsync -avi --exclude #{INFO_FILE} #{local}/ #{remote}"
  else # down or init
    cmd = "rsync -av #{remote}/ #{local}"
  end
  puts "Command: #{cmd}"
  res = system(cmd)
  fail "command failed." if not res
end

# main
$opts = OpenStruct.new
OptionParser.new do |op|
  op.banner = "mysync.rb [options/command] [path]"
  op.on('-u', '--up', "upload sync")
  op.on('-d', '--down', 'download sync')
  op.on('--init', "init a sync folder")
end.parse!(into: $opts)

if not ($opts.up or $opts.down or $opts.init)
  cmd = ARGV.shift
  fail "Bad command #{cmd}" if cmd !~ /init|up|down/
  $opts[cmd] = true
end
if not ARGV.empty?
  if $opts.init
    $opts.remote = ARGV.shift
    if ARGV.empty?
      $opts.local = File.join(Dir.pwd, File.basename($opts.remote))
    else
      $opts.local = ARGV.shift
    end
  else
    $opts.local = ARGV.shift
  end
end

fail "remote path is necessary." if not $opts.remote and $opts.init

$opts.local ||= Dir.pwd

if $opts.init
  puts "create sync form #{$opts.remote} to #{$opts.local}"
end

read_sync_info($opts) if !$opts.init

do_sync($opts)

write_sync_info($opts) if $opts.init

