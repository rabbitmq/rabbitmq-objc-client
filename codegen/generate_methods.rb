require 'active_support/inflector'
require 'erb'
require 'pathname'
require_relative 'codegen_helpers'

class GenerateMethods
  include CodegenHelpers

  attr_reader :xml

  def initialize(xml)
    @xml = xml
  end

  def type_for_domain(xml, domain)
    domain = xml.xpath("/amqp/domain[@name='#{domain}']").first
    if domain
      domain[:type]
    else
      ""
    end
  end

  def colon_aligned_name(first_line, name)
    to_colon, _ = first_line.split(':')
    "#{name}:".rjust(to_colon.length + 1)
  end

  def property_type_and_label(field)
    "(nonnull #{field[:type]} *)#{field[:name]}"
  end

  def chassis_names(method)
    method.xpath('chassis').map {|c| c[:name]}
  end

  def outgoing?(method)
    chassis_names(method).include?('server')
  end

  def header
    <<-OBJC
#{header_start}
@import Mantle;
#import "AMQProtocolValues.h"

      OBJC
  end

  def implementation
    <<-OBJC
#{implementation_start}
#import "AMQProtocolMethods.h"

    OBJC
  end

  def method_fields(method)
    method.xpath('field').map { |f|
      type = if f[:domain]
               type_for_domain(xml, f[:domain]).underscore.camelize
             else
               f[:type].underscore.camelize
             end
      {
        type: "AMQ#{type}",
        name: f[:name].underscore.camelize(:lower),
      }
    }
  end

  def method_constructor(method)
    fields = method_fields(method)
    if fields.any?
      first_field_name = "#{fields[0][:name][0].upcase}#{fields[0][:name][1..-1]}:"
      first_line = "- (nonnull instancetype)initWith#{first_field_name}#{property_type_and_label(fields[0])}"
      constructor_rest = fields[1..-1].map { |field|
        "#{colon_aligned_name(first_line, field[:name])}#{property_type_and_label(field)}"
      }
      "#{([first_line] + constructor_rest).join("\n")}"
    end
  end

  def generate_header
    xml.xpath("//method").reduce(header) { |acc, method|
      fields = method_fields(method)
      constructor = method_constructor(method)
      protocols = ["AMQMethod"]
      class_name = objc_class_name(method)
      acc + template('methods_header_template').result(binding)
    }
  end

  def generate_implementation
    xml.xpath("//method").reduce(implementation) { |acc, method|
      fields = method_fields(method)
      class_name = objc_class_name(method)
      class_id = method.xpath('..').first[:index]
      method_id = method[:index]
      constructor = method_constructor(method)
      class_part = method.xpath('..').first[:name].capitalize
      acc + template('methods_implementation_template').result(binding)
    }
  end
end
