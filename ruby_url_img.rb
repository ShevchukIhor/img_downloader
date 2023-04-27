# frozen_string_literal: true

require 'net/http'
require 'byebug'

puts "Enter the URL, example 'https://my.avon.ua/mediamarket-ee/brochure/ua-uk/202304/001/':"
url_base = gets.chomp

puts "Enter the image name from url, example 'p000.jpg':"
image_name = gets.chomp

puts "Enter the range of images example '000..187':"
range_str = gets.chomp
range_start, range_end = range_str.split('..').map(&:to_i)

# check if the first file exists
first_file = "#{url_base}#{image_name.gsub(/\d/, range_start.to_s)}"
response = Net::HTTP.get_response(URI(first_file))
if response.code != '200'
  puts "Error: the first file in the range was not found: #{first_file}"
  exit
end
# in progress
=begin
last_valid_range_end = nil
while range_end >= range_start
  last_file = "#{url_base}#{image_name.gsub(/\d/, range_end.to_s)}"
  response = Net::HTTP.get_response(URI(last_file))
  if response.code == '200'
    last_valid_range_end = range_end
    break
  end
  range_end -= 1
end

if last_valid_range_end.nil?
  puts "Error: no valid range found"
  exit
end

range = range_start..last_valid_range_end
=end
###

range = range_start..range_end

range.each do |num|
  image_name = "p#{num}.jpg"
  url = URI.parse(url_base + image_name)
  file_name = image_name
  Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
    resp = http.get(url.path)
    open(file_name, 'wb') do |file|
      file.write(resp.body)
    end
  end
  puts "Image saved: #{file_name}"
end
