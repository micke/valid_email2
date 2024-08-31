module DeprecationHelper
  def deprecate_method(old_method, new_method)
    define_method(old_method) do |*args, &block|
      klass = is_a? Module
      target = klass ? "#{self}." : "#{self.class}#"
      warn "Warning: `#{target}#{old_method}` is deprecated and will be removed in version 6 of valid_email2; use `#{new_method}` instead."
      send(new_method, *args, &block)
    end
  end

  def deprecation_message(old_name, new_name)
    warn "Warning: `#{old_name}` is deprecated and will be removed in version 6 of valid_email2; use `#{new_name}` instead."
  end
end
