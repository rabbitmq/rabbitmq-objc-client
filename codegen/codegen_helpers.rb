# This source code is dual-licensed under the Mozilla Public License ("MPL"),
# version 1.1 and the Apache License ("ASL"), version 2.0.
#
# The ASL v2.0:
#
# ---------------------------------------------------------------------------
# Copyright 2017 Pivotal Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ---------------------------------------------------------------------------
#
# The MPL v1.1:
#
# ---------------------------------------------------------------------------
# The contents of this file are subject to the Mozilla Public License
# Version 1.1 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# https://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.
#
# The Original Code is RabbitMQ
#
# The Initial Developer of the Original Code is Pivotal Software, Inc.
# All Rights Reserved.
#
# Alternatively, the contents of this file may be used under the terms
# of the Apache Standard license (the "ASL License"), in which case the
# provisions of the ASL License are applicable instead of those
# above. If you wish to allow use of your version of this file only
# under the terms of the ASL License and not to allow others to use
# your version of this file under the MPL, indicate your decision by
# deleting the provisions above and replace them with the notice and
# other provisions required by the ASL License. If you do not delete
# the provisions above, a recipient may use your version of this file
# under either the MPL or the ASL License.
# ---------------------------------------------------------------------------

module CodegenHelpers
  def template(name)
    ERB.new(Pathname(__dir__).join("#{name}.erb").read, nil, '-')
  end

  def objc_class_name(method)
    class_name = method.xpath('..').first[:name].capitalize
    method_name = method[:name].underscore.camelize
    "RMQ#{class_name}#{method_name}"
  end

  def objc_response_name(method)
    if method.xpath('response').any?
      class_name = method.xpath('..').first[:name].capitalize
      response_name = method.xpath('response').first[:name].underscore.camelize
      "RMQ#{class_name}#{response_name}"
    end
  end

  def do_not_edit
    <<-OBJC.chomp
// License goes here

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
    if field[:base_property_options].include?('nonnull')
      "(nonnull #{field[:pointer_type].strip})#{field[:name]}"
    else
      "(#{field[:pointer_type].strip})#{field[:name]}"
    end
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
      camelized_name = f[:name].underscore.camelize(:lower)
      doc = if f.children.any?
              f.xpath('doc').text.gsub(/[\n ]+/, " ").strip
            end
      {
        base_property_options: %w(nonnull copy nonatomic),
        decode_object: "[RMQ#{type} class]",
        decode_type: "RMQ#{type} *",
        doc: doc,
        name: camelized_name,
        payload_argument: "self.#{camelized_name}",
        pointer_type: "RMQ#{type} *",
        type: "RMQ#{type}",
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
