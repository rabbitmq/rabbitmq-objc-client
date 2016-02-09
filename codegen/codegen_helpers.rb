module CodegenHelpers
  def objc_class_name(method)
    class_name = method.xpath('..').first[:name].capitalize
    method_name = method[:name].underscore.classify
    "AMQProtocol#{class_name}#{method_name}"
  end

  def do_not_edit
    <<-OBJC.chomp
// This file is generated. Do not edit.
    OBJC
  end
  alias :implementation_start :do_not_edit

  def header_start
    <<-OBJC.chomp
#{do_not_edit}
#import <Foundation/Foundation.h>
      OBJC
  end
end
