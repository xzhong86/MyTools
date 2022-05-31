#!/usr/bin/env ruby

# Usage:
#   jekyll-publish.rb _drafts/xxx-xxx.md , or document in anywhere.
# it will append a jekyll header in document.

require 'ostruct'
require 'optparse'

def find_title(origin_doc)
  title_lines = origin_doc.split(/\s*\n\s*/).grep(/^#\s/)
  fail "find title failed." if title_lines.empty?
  title_lines.first.sub(/#\s+(.+?)\s*$/, '\1')
end

def gen_header(out, opts)
  date_str = IO.popen('date  "+%F %T %z"').read.chomp
  tags_str = opts.tags ? opts.tags.join(' ') : nil
  out.puts '---'
  out.puts "title:  \"#{opts.title}\""
  out.puts "layout:  #{opts.layout}"
  out.puts "date:    #{date_str}"
  out.puts "categories: jekyll update"
  out.puts "tags:    #{tags_str}" if tags_str
  out.puts '---'
  out.puts ''
end

def publish(doc_path, opts)
  date_prefix = IO.popen('date  "+%F-"').read.chomp
  base_name = File.basename(doc_path)
  post_file = File.join('_posts', date_prefix + base_name)
  fail "_post not exist!" if not Dir.exist? '_posts'
  fail "post #{post_file} exist!" if !opts.force and File.exist? post_file
  fail "doc #{doc_path} not exist!" if not File.exist? doc_path
  origin_doc = IO.read(doc_path)
  opts.title = find_title(origin_doc) if not opts.title
  out = File.open(post_file, "w")
  fail "write #{post_file} failed." if not out
  gen_header(out, opts)
  out.write(origin_doc)
  out.close
end

# main
opts = OpenStruct.new
OptionParser.new do |op|
  op.banner = "jekyll-publish.rb [options] doc-path"
  op.on('-t', '--title TITLE', "set title, default is first H1 in doc")
  op.on('-l', '--layout LAYOUT', "set layout, default is 'post'")
  op.on('-c', '--categories C,C,...', "set categories, default is jekyll,update")
  op.on('--tags TAG,TAG,...', "set tags, default is empty")
  op.on('-f', '--force', "force update post if it exists.")
end.parse!(into: opts)

opts.tags = opts.tags.split(',') if opts.tags
opts.categories = opts.categories.split(',') if opts.categories
opts.layout ||= 'post'

fail "need doc to publish" if ARGV.empty?

ARGV.each do |doc|
  publish(doc, opts)
end

