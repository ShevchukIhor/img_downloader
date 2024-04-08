# frozen_string_literal: true

require 'net/http'
require 'byebug'
require 'fileutils'
require 'mini_magick'

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

  puts "Error: the first file in the range was not found: #{first_file}" if response.code == '404'

  puts "Enter the range of images, last image number, example '187':"
  range_end = gets.chomp

  last_file = "#{url_base}#{image_name.gsub(/\d+/, range_end.to_s)}"
  response = Net::HTTP.get_response(URI(last_file))

  puts "Error: the last file in the range was not found: #{last_file}" if response.code == '404'
  break if response.code != '404'
end


range = (range_start.to_i..range_end.to_i)
directory = nil
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
      puts "Image saved: #{file_name}"
    end
  else
    begin
      FileUtils.mkdir_p(directory)
    rescue Errno::ENOENT
      puts "Error creating directory: #{directory}"
      retry
    end
  end
end

# Define the directory where your downloaded images are located
downloaded_images_directory = directory.to_s
# Define the desired dimensions for resizing
desired_dimensions = '800x600' # Replace with your desired dimensions
# Get a list of all image files in the directory
image_files = Dir.glob(File.join(downloaded_images_directory, '*.jpg')) # Change the file extension if needed
# Loop through each image file and resize it
image_files.each do |image_file|
  image = MiniMagick::Image.open(image_file)
  image.resize(desired_dimensions)
  image.write(image_file)
  puts "Resized #{image_file} to #{image.width}x#{image.height}"
end

