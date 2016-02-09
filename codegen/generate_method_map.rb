class GenerateMethodMap
  include CodegenHelpers

  attr_reader :xml

  def initialize(xml)
    @xml = xml
  end

  def generate_header
    <<-OBJC
#{header_start}

@interface AMQProtocolMethodMap : NSObject
+ (NSDictionary *)methodMap;
@end
    OBJC
  end

  def generate_implementation
    pairs = xml.xpath('//method').map { |method|
      klass = method.xpath('..').first
      class_index = klass[:index]
      method_index = method[:index]
      class_name = objc_class_name(method)
      "@[@(#{class_index}), @(#{method_index})] : [#{class_name} class]"
    }
    <<-OBJC
#{implementation_start}
#import "AMQProtocolMethodMap.h"
#import "AMQProtocolMethods.h"

@implementation AMQProtocolMethodMap
+ (NSDictionary *)methodMap {
    return @{#{pairs.join(",\n             ")}};
}
@end
    OBJC
  end
end
