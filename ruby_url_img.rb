# frozen_string_literal: true

require 'net/http'
require 'byebug'

puts "Enter the URL, example 'https://my.avon.ua/mediamarket-ee/brochure/ua-uk/202304/001/':"
url_base = gets.chomp

puts "Enter the image name from url, example 'p000.jpg':"
image_name = gets.chomp
loop do
  puts "Enter the range of images, first image number, example '000':"
  range_start = gets.chomp
  first_file = "#{url_base}#{image_name.gsub(/\d+/, range_start.to_s)}"
  response = Net::HTTP.get_response(URI(first_file))
  if response.code != '200'
    puts "Error: the first file in the range was not found: #{first_file}"
  end
  @range_start = range_start
  puts "Enter the range of images, last image number, example '187':"
  range_end = gets.chomp
  last_file = "#{url_base}#{image_name.gsub(/\d+/, range_end.to_s)}"
  response = Net::HTTP.get_response(URI(last_file))
  if response.code != '200'
    puts "Error: the last file in the range was not found: #{last_file}"
  end
  @range_end = range_end

  break if response.code == '200'
end

range = @range_start..@range_end

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
