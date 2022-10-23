#!/usr/bin/env ruby

require 'stringio'
require 'erb'

class DocNodeInfo
  attr_reader :title, :path, :children
  def initialize(path)
    @path = path
    @children = []
    if Dir.exist? path
      read_doc_dir(path)
    elsif path.end_with? '.md'
      read_doc(path)
    end
  end
  def has_child()
    not @children.empty?
  end
  def read_doc_title(path)
    headers = IO.readlines(path).grep(/^#\s+\S+/)
    if not headers.empty? and headers.first =~ /^#\s+(.+?)\s*$/
      $1
    else
      File.basename(path, '.md')
    end
  end
  def read_doc(path)
    @title = read_doc_title(path)
  end
  def read_doc_dir(path)
    Dir.each_child(path) do |file|
      sub_path = File.join(path, file)
      if file == 'README.md'
        @path  = sub_path
        @title = read_doc_title(sub_path)
      elsif file =~ /(_book|.git|scripts|SUMMARY.md)$/
      elsif Dir.exist?(sub_path)
        @children << DocNodeInfo.new(sub_path)
      elsif file.end_with?('.md')
        @children << DocNodeInfo.new(sub_path)
      end
    end
  end

  def print_summary(level, _pfx, out)
    pfx = _pfx * (level + 1)
    out.puts (_pfx * level) + " * [#{title}](#{path})"
    children.each do |doc|
      if doc.has_child
        doc.print_summary(level + 1, _pfx, out)
      else
        out.puts pfx + " * [#{doc.title}](#{doc.path})"
      end
    end
  end
end

def gen_sum(pfx, dir)
  docs = DocNodeInfo.new(dir)
  out = StringIO.new
  docs.print_summary(0, '  ', out)
  out.string
end

def proc_erb(erb_file)
  ERB.new(IO.read(erb_file)).run
end

proc_erb(ARGV[0])

