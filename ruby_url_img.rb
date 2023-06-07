# frozen_string_literal: true

require 'net/http'
require 'byebug'
require 'fileutils'


puts "Enter the URL, example 'https://my.avon.ua/mediamarket-ee/brochure/ua-uk/202304/001/':"
url_base = gets.chomp

puts "Enter the image name from url, example 'p000.jpg':"
image_name = gets.chomp

range_start = nil
range_end = nil

loop do
  puts "Enter the range of images, first image number, example '000':"
  range_start = gets.chomp

  first_file = "#{url_base}#{image_name.gsub(/\d+/, range_start.to_s)}"
  response = Net::HTTP.get_response(URI(first_file))

  if response.code != '200'
    raise StandardError, "Error: the first file in the range was not found: #{first_file}"
  end

  puts "Enter the range of images, last image number, example '187':"
  range_end = gets.chomp

  last_file = "#{url_base}#{image_name.gsub(/\d+/, range_end.to_s)}"
  response = Net::HTTP.get_response(URI(last_file))

  if response.code != '200'
    raise StandardError, "Error: the last file in the range was not found: #{last_file}"
  end

  break if response.code == '200'
end

range = (range_start.to_i..range_end.to_i)

range.each do |num|
  image_name = "p#{num}.jpg"
  url = URI.parse(url_base + image_name)
  directory = File.join('avon_catalog', File.dirname(url.path).split('/')[4..5].join('/'))

  if Dir.exist?(directory)
    file_name = File.join(directory, image_name)
    Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
      resp = http.get(url.path)

      open(file_name, 'wb') do |file|
        file.write(resp.body)
      end
    end
    puts "Image saved: #{file_name}"
  else
    begin
      FileUtils.mkdir_p(directory)
    rescue Errno::ENOENT
      puts "Error creating directory: #{directory}"
      retry
    end
  end
end
