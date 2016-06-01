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

  def generate_header
    xml.xpath("//method").reduce(header) { |acc, method|
      class_name = objc_class_name(method)
      protocols = ["RMQMethod"]
      bits, fields, max_bit_length = bits_and_fields(method)
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
      response_name = objc_response_name(method)
      constructor = constructor(fields)
      class_part = method.xpath('..').first[:name].capitalize
      has_content_value = objc_boolean(method[:content] == "1")
      acc + template('methods_implementation_template').result(binding)
    }
  end

  private

  def objc_boolean(x)
    x ? "YES" : "NO"
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
#import "RMQTable.h"

      OBJC
  end

  def implementation
    <<-OBJC
#{implementation_start}
#import "RMQMethods.h"

    OBJC
  end

  def bits_and_fields(method)
    original_fields =
      camelized_fields(method.xpath('field')).
      reject {|f| blacklisted_bitfields.include?([method.parent[:name], method[:name], f[:name]])}
    bits = original_fields.select {|f| f[:type] == "RMQBit"}
    type = objc_class_name(method) + "Options"
    bit_name_lengths = ["nooptions".length] + bits.map {|b| b[:name].length}
    max_bit_length = bit_name_lengths.max
    [
      bits.map {|bit| bit.merge(name: bit[:name].camelize.ljust(max_bit_length))},
      collapse_bits_into_options(original_fields, type),
      max_bit_length,
    ]
  end

  def collapse_bits_into_options(fields, type)
    fields.slice_when(&method(:bit_transitioning)).reduce([]) {|acc, field_group|
      if field_group.first[:type] == "RMQBit"
        acc + [{
          base_property_options: %w(nonatomic),
          decode_object: "[RMQOctet class]",
          decode_type: "RMQOctet *",
          decode_property_call: ".integerValue",
          name: "options",
          payload_argument: "[[RMQOctet alloc] init:self.options]",
          pointer_type: type + " ",
          type: type,
        }]
      else
        acc + field_group
      end
    }
  end

  def bit_transitioning(before, after)
    before[:type] != after[:type] && [before[:type], after[:type]].include?('RMQBit')
  end

  def blacklisted_bitfields
    [%w(basic publish immediate)]
  end
end
