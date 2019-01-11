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
      bits, fields, max_bit_length = bits_and_fields(class_name, method)
      constructor = constructor(fields)

      header = template('methods_header_template').result(binding)

      acc + header
    }
  end

  def generate_implementation
    xml.xpath("//method").reduce(implementation) { |acc, method|
      class_name = objc_class_name(method)
      _, fields = bits_and_fields(class_name, method)
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

  def bits_and_fields(class_name, method)
    original_fields =
      camelized_fields(method.xpath('field')).
      reject { |f| blacklisted_bitfields.include?([method.parent[:name], method[:name], f[:name]]) }
    bits = original_fields.select { |f| f[:type] == "RMQBit" }
    type = objc_class_name(method) + "Options"

    bit_name_lengths = ["nooptions".length] + bits.map {|b| b[:name].length}

    max_bit_length = bit_name_lengths.max
    [
      bits.map { |bit| bit.merge(name: bit[:name].camelize.ljust(max_bit_length)) },
      collapse_bits_into_options(original_fields, type),
      max_bit_length
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
