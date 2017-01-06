#!/usr/bin/env ruby

require 'erb'
require 'optparse'

# Simple wrapper to create terraform templates
# For our default environment, the ELB is named
# with the environment name and is created with
# a) an associated security group 
# b) a security group for its child boxes
# in the main.tf.
class Pratchett
  def initialize
    @var_file = './shared/variables.tf'
  end

  def output_and_exit(msg)
    puts msg
    exit
  end

  def run(env, boxes)
    new_env = true;
    $env_name = env
    output_dir = "../ec2/#{$env_name}"

    new_env = false if File.exist?"#{output_dir}/main.tf"

    if new_env
      template_str = File.read('./templates/main.tf.erb')
      template = ERB.new(template_str)

      puts template.result

      `mkdir -p #{output_dir}`
      File.write("#{output_dir}/main.tf", template.result)
      `cp #{@var_file} #{output_dir}`
    end
puts "x #{boxes} x"
    if boxes
      boxes.each do |box|
        $box_name = box
        template_str = File.read('./templates/box.tf.erb')
        template = ERB.new(template_str)
  
        puts template.result
  
        File.write("#{output_dir}/#{$box_name}.tf", template.result)
      end
    end
  end
end

env = ARGV.shift
boxes = ARGV
Pratchett.new.run(env, boxes)
exit 0
