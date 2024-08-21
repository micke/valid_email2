# frozen_string_literal:true

module ValidEmail2
  class DynamicOptionValues
    class << self
      def deny_list
        @deny_list ||= Set.new
      end

      def deny_list=(set)
        return unless set.is_a?(Set)

        @deny_list = set
      end

      def deny_list_active_record_query
        @deny_list_active_record_query ||= default_active_record_query
      end

      def deny_list_active_record_query=(query_hash)
        return unless valid_query_hash?(query_hash)

        @deny_list_active_record_query = query_hash
      end

      def parse_option_for_additional_items(type, value)
        return false unless respond_to?("#{type}=")

        case value
        when NilClass
          return false
        when TrueClass, FalseClass
          return value
        when Set
          send("#{type}=", value)
        when Array
          send("#{type}=", Set.new(value))
        when Proc
          result_value = value.call
          return parse_option_for_additional_items(type, result_value)
        when Hash, HashWithIndifferentAccess
          return false unless valid_query_hash?(value)
          return false unless respond_to?("#{type}_active_record_query=")

          send("#{type}_active_record_query=", value)
        else
          return false
        end

        true
      end

      def domain_is_in?(type, address)
        return false unless type.is_a?(Symbol)
        return false unless respond_to?(type)
        return false unless address.is_a?(Mail::Address)

        downcase_domain = address.domain.downcase
        type_result = send(type).include?(downcase_domain)
        return type_result if type_result

        return false unless respond_to?("#{type}_active_record_query")

        option_hash = send("#{type}_active_record_query")
        return false unless valid_query_hash?(option_hash)

        scope = option_hash[:active_record_scope]
        attribute = option_hash[:attribute]
        scope.exists?(attribute => downcase_domain)
      end

      private

      def valid_query_hash?(query_hash)
        valid_class_array = [Hash]
        valid_class_array << HashWithIndifferentAccess if defined?(HashWithIndifferentAccess)
        return false unless valid_class_array.include?(query_hash.class)

        scope = query_hash[:active_record_scope]
        unless scope.is_a?(Class) &&
               scope.respond_to?(:where) &&
               scope.respond_to?(:exists?) &&
               scope.respond_to?(:column_names)
          return false
        end

        attribute = query_hash[:attribute]
        return false unless attribute.is_a?(Symbol) && scope.column_names.include?(attribute.to_s)

        true
      end

      def default_active_record_query
        @default_active_record_query ||= { active_record_scope: nil, attribute: nil }
      end
    end
  end
end
