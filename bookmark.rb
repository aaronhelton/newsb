#!/bin/env ruby

require 'optparse'
require 'metainspector'

# configure these
github_pages_location = '/Users/aaronhelton/dev/aaronhelton.github.io/'
bookmarks_path = '_bookmarks/'

file_date = Time.now.strftime('%Y-%m-%d')

options = {}

options[:url] = ARGV[0]
options[:note] = ARGV[1]
options[:quote] = ARGV[2]


# get some metadata from the bookmarked site

page = MetaInspector.new(options[:url])

out_location =  github_pages_location + bookmarks_path + file_date.to_str + '_' + page.best_title[0..10].gsub(/\W/,'_') + '.md'

File.open(out_location, 'a+') do |file|
  file.puts "---"
  file.puts "title: #{page.best_title}"
  file.puts "link: #{options[:url]}"
  file.puts "date: #{Time.now}"
  file.puts "---"
  if options[:quote]
    file.puts "<blockquote><p>#{options[:quote]}</p></blockquote>"
  else
    file.puts "<blockquote><p>#{page.description}</p></blockquote>"
  end
  file.puts "<img src='#{page.images.best}'>"
end
