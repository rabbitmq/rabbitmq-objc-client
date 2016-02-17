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

  def bits_and_fields(method)
    bits, fields = camelized_fields(method.xpath('field')).partition {|f| f[:type] == "AMQBit"}
    if bits.any?
      type = objc_class_name(method) + "Options"
      bit_name_lengths = bits.map {|b| b[:name].length}
      [bits.map {|bit| bit.merge(name: bit[:name].camelize.ljust(bit_name_lengths.max))},
       fields + [{
        base_property_options: %w(nonatomic),
        decode_object: "[AMQOctet class]",
        decode_type: "AMQOctet *",
        decode_property_call: ".integerValue",
        name: "options",
        payload_argument: "[[AMQOctet alloc] init:self.options]",
        pointer_type: type + " ",
        type: type,
      }]]
    else
      [[], fields]
    end
  end

  def generate_header
    xml.xpath("//method").reduce(header) { |acc, method|
      class_name = objc_class_name(method)
      protocols = ["AMQMethod"]
      bits, fields = bits_and_fields(method)
      constructor = constructor(fields)
      acc + template('methods_header_template').result(binding)
    }
  end

  def generate_implementation
    xml.xpath("//method").reduce(implementation) { |acc, method|
      _, fields = bits_and_fields(method)
      class_name = objc_class_name(method)
      class_id = method.xpath('..').first[:index]
      method_id = method[:index]
      constructor = constructor(fields)
      class_part = method.xpath('..').first[:name].capitalize
      acc + template('methods_implementation_template').result(binding)
    }
  end
end
