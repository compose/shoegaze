module SpecHelpers
  def random_named_class(&block)
    # generate a dynamic named class to avoid test suite conflicts
    class_name = "TestClass#{SecureRandom.hex(8)}"
    eval("class ::#{class_name}; end")

    klass = class_name.constantize

    if block_given?
      klass.class_eval(&block)
    end

    klass
  end
end
