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
#import "RMQTable.h"

@protocol RMQBasicValue <NSObject, RMQEncodable>
+ (NSUInteger)flagBit;
- (NSUInteger)flagBit;
@end

@interface RMQBasicProperties : NSObject
+ (NSArray *)properties;
+ (NSArray<RMQValue *> *)defaultProperties;
@end

    OBJC
  end

  def implementation(fields)
    <<-OBJC
#{implementation_start}
#import "RMQBasicProperties.h"

@implementation RMQBasicProperties
+ (NSArray *)properties {
    return @[#{fields.map {|f| "[#{basic_field_class(f)} class]"}.join(",\n             ")}];
}
+ (NSArray<RMQValue *> *)defaultProperties {
    return @[[[RMQBasicContentType alloc] init:@"application/octet-stream"],
             [[RMQBasicDeliveryMode alloc] init:1],
             [[RMQBasicPriority alloc] init:0]];
}
@end

    OBJC
  end

  def basic_field_class(field)
    "RMQBasic#{field[:name].underscore.camelize}"
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
