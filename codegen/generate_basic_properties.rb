require 'erb'
require 'pathname'
require_relative 'codegen_helpers'

class GenerateBasicProperties
  include CodegenHelpers

  attr_reader :xml

  def initialize(xml)
    @xml = xml
  end

  def header
    <<-OBJC
#{do_not_edit}
#import "AMQValues.h"

@protocol AMQBasicValue <NSObject, AMQEncoding>
+ (NSUInteger)flagBit;
- (NSUInteger)flagBit;
@end

@interface AMQBasicProperties : NSObject
+ (NSArray *)properties;
@end

    OBJC
  end

  def implementation(fields)
    <<-OBJC
#{implementation_start}
#import "AMQBasicProperties.h"

@implementation AMQBasicProperties
+ (NSArray *)properties {
    return @[#{fields.map {|f| "[#{basic_field_class(f)} class]"}.join(",\n             ")}];
}
@end

    OBJC
  end

  def basic_field_class(field)
    "AMQBasic#{field[:name].underscore.camelize}"
  end

  def generate_header
    fields = camelized_fields(xml.xpath("/amqp/class[@name='basic']/field"))
    fields.reduce(header) { |acc, field|
      class_name = basic_field_class(field)
      superclass = field[:type]
      acc + template('basic_properties_header_template').result(binding)
    }
  end

  def generate_implementation
    fields = camelized_fields(xml.xpath("/amqp/class[@name='basic']/field"))
    fields.each_with_index.reduce(implementation(fields)) { |acc, (field, index)|
      class_name = basic_field_class(field)
      superclass = field[:type]
      bit = 15 - index
      flag_bit = 1 << bit
      acc + template('basic_properties_implementation_template').result(binding)
    }
  end
end
