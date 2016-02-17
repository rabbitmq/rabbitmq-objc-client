module CodegenHelpers
  def template(name)
    ERB.new(Pathname(__dir__).join("#{name}.erb").read, nil, '-')
  end

  def objc_class_name(method)
    class_name = method.xpath('..').first[:name].capitalize
    method_name = method[:name].underscore.camelize
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

  def constructor(fields)
    if fields.any?
      first_field_name = "#{fields[0][:name][0].upcase}#{fields[0][:name][1..-1]}:"
      first_line = "- (nonnull instancetype)initWith#{first_field_name}#{property_type_and_label(fields[0])}"
      constructor_rest = fields[1..-1].map { |field|
        "#{colon_aligned_name(first_line, field[:name])}#{property_type_and_label(field)}"
      }
      "#{([first_line] + constructor_rest).join("\n")}"
    end
  end

  def property_type_and_label(field)
    "(nonnull #{field[:type]} *)#{field[:name]}"
  end

  def colon_aligned_name(first_line, name)
    to_colon, _ = first_line.split(':')
    "#{name}:".rjust(to_colon.length + 1)
  end

  def camelized_fields(fields)
    fields.map { |f|
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

  def type_for_domain(xml, domain)
    domain = xml.xpath("/amqp/domain[@name='#{domain}']").first
    if domain
      domain[:type]
    else
      ""
    end
  end
end
