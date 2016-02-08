#!/usr/bin/env ruby

require 'active_support/inflector'
require 'erb'
require 'pathname'

class GenerateMethods
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

  def outgoing?(method)
    method.xpath('chassis').first[:name] == 'server'
  end

  def header
    <<-OBJC
// This file is generated. Do not edit.
#import <Foundation/Foundation.h>
@import Mantle;
#import "AMQProtocolValues.h"

      OBJC
  end

  def template
    ERB.new(Pathname(__dir__).join('template.erb').read, nil, '-')
  end

  def generate
    xml.xpath("//method").reduce(header) do |acc, method|
      method_name = method[:name].underscore.classify
      fields = method.xpath('field').map { |f|
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

      constructor =
        if outgoing?(method) && fields.any?
          first_field_name = "#{fields[0][:name][0].upcase}#{fields[0][:name][1..-1]}:"
          first_line = "- (nonnull instancetype)initWith#{first_field_name}#{property_type_and_label(fields[0])}"
          constructor_rest = fields[1..-1].map { |field|
            "#{colon_aligned_name(first_line, field[:name])}#{property_type_and_label(field)}"
          }
          "#{([first_line] + constructor_rest).join("\n")};"
        end

      protocol = outgoing?(method) ? "AMQOutgoing" : "AMQIncoming"
      class_name = method.xpath('..').first[:name].capitalize

      acc + template.result(binding)
    end
  end
end
