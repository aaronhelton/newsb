#!/bin/env ruby
#
######
# Web to Jekyll Bookmark script, callable from, e.g., Newsbeuter, or usable standalone.
######

require 'optparse'
require 'metainspector'

# configure these
github_pages_location = '/Users/aaronhelton/dev/aaronhelton.github.io/'
bookmarks_path = '_bookmarks/'

file_date = Time.now.strftime('%Y-%m-%d')

options = {}

# 
options[:url] = ARGV[0]
if !options[:url] then abort "You must include a URL as the first argument." end

# get some metadata from the bookmarked site

page = MetaInspector.new(options[:url])

out_location =  github_pages_location + bookmarks_path + file_date.to_str + '-' + Time.now.to_i.to_s + page.best_title[0..10].gsub(/\W/,'-') + '.md'


def write_file(out_location,url,page,comment,blocks)
  File.open(out_location, 'a+') do |file|
    file.puts "---"
    file.puts "title: \"#{page.best_title}\""
    file.puts "link: #{url}"
    file.puts "date: #{Time.now}"
    file.puts "---"
    if comment
      file.puts comment
    end
    if blocks
      file.puts "<blockquote>"
      file.puts blocks.join("<br><br>[...]<br><br>")
      file.puts "</blockquote>"
    end
  end
end

blocks = []
comment = ''

help_text = "(n)ew excerpt; (u)ndo last addition; (c)omment; (d)elete comment; (p)review markdown; (q)uit; (h)elp."
puts "Commands:"
puts help_text

have_saved = false

loop do
  input = STDIN.gets.chomp
  command, *params = input.split /\s/

  case command
  when /\An\z/i
    puts "Excerpt mode. ;; on a line by itself exits." 
    print ">> "
    block = ''
    current_text = ''
    while current_text != ';;'
      current_text = STDIN.gets.chomp
      block = block + current_text.gsub(/;;/, '')
    end
    blocks << block
    have_saved = false
  when /\Au\z/i
    blocks.pop
    have_saved = false
  when /\Ac\z/i
    puts "Comment mode replaces previous comment. ;; on a line by itself exits."
    print ">> "
    current_text = ''
    comment = '<p>'
    while current_text != ';;'
      current_text = STDIN.gets.chomp
      comment = comment + current_text.gsub(/;;/, '')
    end
    comment = comment + '</p>'
    have_saved = false
  when /\Ad\z/i
    puts "Really delete the comment?"
    yes_no = STDIN.gets.chomp
    case yes_no
    when /\Ay\z/i
      comment = ''
    else
      # ??
    end
    have_saved = false
  when /\Ap\z/i
    if comment.size > 0
      puts comment
    end
    if blocks.size > 0
      puts "<blockquote>"
      puts blocks.join("<br><br>[...]<br><br>")
      puts "</blockquote>"
    end
  when /\Aq\z/i
    if have_saved
      break
    else
      puts "Do you want to save?"
      yes_no = STDIN.gets.chomp
      case yes_no
      when /\Ay\z/i
        write_file(out_location, options[:url], page, comment, blocks)
        puts "Saved to #{out_location}"
        have_saved = true
        break
      when /\An\z/i
        break
      else
        break
      end
    end
  when /\Ah\z/i
    puts help_text
  else puts 'Invalid command'
  end
end
