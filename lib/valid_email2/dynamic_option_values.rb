# frozen_string_literal:true

module ValidEmail2
  class DynamicOptionValues
    class << self
      def deny_list_function
        @deny_list_function ||= ->(_domain) { false }
      end

      def deny_list_function=(lambda_function)
        return unless lambda_function.is_a?(Proc)
        return unless lambda_function.arity == 1

        @deny_list_function = lambda_function
      end

      def parse_option_for_additional_items(type, value)
        return false unless respond_to?("#{type}_function=")

        case value
        when NilClass
          return false
        when TrueClass, FalseClass
          return value
        when Set, Array
          self.deny_list_function = ->(domain) { value.include?(domain) }
        when Proc
          self.deny_list_function = value
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

        send(type).call(downcase_domain)
      end
    end
  end
end
