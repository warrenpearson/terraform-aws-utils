#!/usr/bin/env ruby

require 'erb'
require 'optparse'

# Simple wrapper to create terraform templates
class Wogan
  def initialize
    @var_file = './shared/variables.tf'
  end

  def valid_type?(aws_type)
    aws_types = %w(elb ec2 rds sg)

    return true if aws_types.include?(aws_type)

    false
  end

  def output_and_exit(msg)
    puts msg
    exit
  end

  def do_delete(box_name)
    unless File.directory?("../#{box_name}") &&
        File.exist?("../#{box_name}/main.tf")
      puts "'../#{box_name}/main.tf' does not exist, exiting"
      exit
    end

    # TODO: actually do the delete
  end

  def create_db_server(aws_name, args)
    $rds_name    = aws_name
    $rds_id      = aws_name.dup
    $rds_id.gsub!('_', '-')
    $rds_sg_name = aws_name + '_sg'
    $rds_sng_name = aws_name + '_sng'

    template_str = File.read('./templates/new_db.erb')
    template = ERB.new(template_str)

    puts template.result

    output_dir = "../rds/#{$rds_name}"

    `mkdir -p #{output_dir}`
    File.write("#{output_dir}/main.tf", template.result)
    `cp #{@var_file} #{output_dir}`

  end

  def create_load_balancer(aws_name, args)
    $elb_name = aws_name
    $subnet   = args[:subnet]
    $group_name = $elb_name + '_sg'
    # these seem like safe defaults
    $port_list = [80]
    $internal_cidr = '0.0.0.0/32'

    template_str = File.read('./templates/new_elb.erb')
    template = ERB.new(template_str)

    puts template.result

    output_dir = "../elb/#{$elb_name}"

    `mkdir -p #{output_dir}`
    File.write("#{output_dir}/main.tf", template.result)
    `cp #{@var_file} #{output_dir}`
  end

  def create_security_group(aws_name, args)
    $group_name = aws_name

    sg_ports  = args[:ports]

    if sg_ports.include?(',')
      $port_list = sg_ports.split(',')
    else
      $port_list = [sg_ports]
    end

    template_str = File.read('./templates/new_sec_grp.erb')
    template = ERB.new(template_str)

    puts template.result

    output_dir = "../sg/#{$group_name}"

    `mkdir -p #{output_dir}`
    File.write("#{output_dir}/main.tf", template.result)
    `cp #{@var_file} #{output_dir}`
  end

  def create_box(aws_name, args)
    $box_name = aws_name

    if args.key?(:type)
      $box_type = args[:type]
    else
      $box_type = 't2.micro'
    end

    if args.key?(:group)
      $group_name = args[:group]
    else
      $group_name = $box_name + '_sg'
    end

    sg_ports  = args[:ports]

    if args.key?(:vol_size)
      $vol_size = args[:vol_size]
    else
      $vol_size = 30
    end

    $box_name = $box_name.gsub(' ', '-')

    $port_list = []

    if sg_ports
      if sg_ports.include?(',')
        $port_list = sg_ports.split(',')
      else
        $port_list = [sg_ports]
      end
    else
      $port_list = [22]
    end

    template_str = File.read('./templates/new_box.erb')
    template = ERB.new(template_str)

    puts template.result

    output_dir = "../ec2/#{$box_name}"

    `mkdir -p #{output_dir}`
    File.write("#{output_dir}/main.tf", template.result)
    `cp #{@var_file} #{output_dir}`
  end

  def validate_input(opt_list, aws_type, aws_name)
    output_and_exit(opt_list) unless aws_type && aws_name

    unless valid_type?(aws_type)
      puts('aws_type must be either ec2 or elb')
      output_and_exit(opt_list)
    end
  end

  def run
    args = {}
    opt_list = nil

    OptionParser.new do |opts|
      opts.banner = 'Usage: wogan.rb <aws_type> [options] <aws_name>'

      opts.on('-d', '--delete', 'Specify EC2 instance to delete') { args[:delete] = true }
      opts.on('-p', '--port-list ', 'Specify ports for security group') { |v| args[:ports] = v }
      opts.on('-g', '--group-name ', 'Specify name for security group') { |v| args[:group] = v }
      opts.on('-t', '--instance-type ', 'Specify EC2 instance type') { |v| args[:type] = v }
      opts.on('-s', '--subnet ', 'Specify AWS subnet') { |v| args[:subnet] = v }
      opts.on('-v', '--volume-size ', 'Specify size of root device') { |v| args[:vol_size] = v }

      opts.on_tail('-h', '--help', 'Show this message') do
        output_and_exit(opts)
      end

      opt_list = opts
    end.parse!

    aws_type  = ARGV[0]
    aws_name  = ARGV[1]

    validate_input(opt_list, aws_type, aws_name)

    do_delete(aws_name) if args.key?(:delete)

    create_box(aws_name, args) if aws_type == 'ec2'
    create_load_balancer(aws_name, args) if aws_type == 'elb'
    create_db_server(aws_name, args) if aws_type == 'rds'
    create_security_group(aws_name, args) if aws_type == 'sg'
  end
end

Wogan.new.run
