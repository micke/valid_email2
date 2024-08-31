module DeprecationHelper
  def deprecate_method(old_method, new_method)
    define_method(old_method) do |*args, &block|
      warn "Warning: `#{old_method}` is deprecated; use `#{new_method}` instead."
      send(new_method, *args, &block)
    end
  end

  def deprecation_message(old_name, new_name)
    warn "Warning: `#{old_name}` is deprecated; use `#{new_name}` instead."
  end
end