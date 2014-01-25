Rails::Engine.class_eval do
  def load(initializer)
    initializer = initializer.sub(Rails.root.to_s, ".")
    Bumbler::Hooks.benchmark(initializer) { super }.last
  end
end
