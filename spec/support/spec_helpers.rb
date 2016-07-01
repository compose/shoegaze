module SpecHelpers
  def random_named_class
    # generate a dynamic named class to avoid test suite conflicts
    class_name = "TestClass#{SecureRandom.hex(8)}"
    eval("class ::#{class_name}; end")
    class_name.constantize
  end
end
