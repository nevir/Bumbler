Rails::Engine.class_eval do
  def load(initializer)
    initializer = initializer.sub(Rails.root.to_s, ".")
    Bumbler::Hooks.benchmark(initializer) { super }.last
  end
end

Rails::Initializable::Initializer.class_eval do
  alias_method :run_without_bumbler, :run
  def run(*args)
    name = (@name.is_a?(Symbol) ? @name.inspect : @name)
    Bumbler::Hooks.benchmark(name) { run_without_bumbler(*args) }.last
  end
end
