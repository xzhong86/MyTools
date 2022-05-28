#!/usr/bin/env ruby

# path-manager.rb [options] PATH
# usage in bash:
#  function path-add { str=`path/to/path-manager.rb -a $*`; eval "$str"; }
#  function path-remove { str=`path/to/path-manager.rb -r $*`; eval "$str"; }
# or simply:
#  eval "$(path-manager.rb -E)"
# tips:
#  delete function: unset -f path-add
#  delete alias: unalisa path-add

require 'ostruct'
require 'optparse'

class EnvChange
  def initialize(opts)
    @new_env = {}
    @opts = opts
    @shell = File.basename(ENV['SHELL'])
  end

  def env_var_add(vname, val, sep: ':')
    arr = ENV[vname] ? ENV[vname].split(sep) : []
    if not arr.include? val
      if not @opts.last
        arr.prepend val
      else
        arr.append val
      end
      ENV[vname] = arr.join(sep)
      @new_env[vname] = arr.join(sep)
    end
  end

  def add_path(path)
    if Dir.exists?(path + '/bin')
      env_var_add('PATH', path + '/bin')
    else
      env_var_add('PATH', path)
    end
    if Dir.glob(path + '/lib/*.so').size > 0
      env_var_add('LD_LIBRARY_PATH', path + '/lib')
    end
  end

  def env_var_rm(vname, val, sep: ':')
    arr = ENV[vname] ? ENV[vname].split(sep) : []
    if arr.delete(val)
      ENV[vname] = arr.join(sep)
      @new_env[vname] = arr.join(sep)
    end
  end

  def remove_path(path)
    env_var_rm('PATH', path)
    env_var_rm('PATH', path + '/bin')
    env_var_rm('LD_LIBRARY_PATH', path + '/lib')
  end

  def shell_str
    if @shell =~ /^(sh|bash|zsh)$/
      @new_env.each.map{ |k,v| "#{k}=#{v}" }.join(';')
    else
      ""
    end
  end

  def eval_code
    out = []
    if @shell == 'bash'
      temp = "function %s { str=`#{__FILE__} %s $*`; eval \"$str\"; }"
      out << temp % [ "path-add", "-a" ]
      out << temp % [ "path-add-last", "-a --last" ]
      out << temp % [ "path-remove", "-r" ]
    end
    out.join("\n")
  end

end

# main
opts = OpenStruct.new
OptionParser.new do |op|
  op.banner = 'path-manager.rb [options] PATH ...'
  op.on('-a', '--add', 'add path or module path')
  op.on('--last', 'add path at last')
  op.on('-r', '--remove', 'remove path or module path')
  op.on('-E', '--eval', 'generate eval code for shell')
end.parse!(into: opts)

fail "need path" if ARGV.empty? and !opts.eval

env = EnvChange.new(opts)

if opts.eval
  puts env.eval_code
  exit 0
end

ARGV.each do |_path|
  path = File.realpath _path
  if opts.add
    env.add_path path
  elsif opts.remove
    env.remove_path path
  end
end

puts env.shell_str

