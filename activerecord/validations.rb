module Validations

  def validate(method)
    define_method "errors" do
      @errors ||= Hash.new
    end
    @validate_methods ||= []
    @validate_methods << method unless @validate_methods.include?(method)
    # obj = self.new(@attributes)
    # obj.send(method)

  end

  def validate_methods
    @validate_methods
  end

  def validate_methods_clear
    @validate_methods = []
  end
end