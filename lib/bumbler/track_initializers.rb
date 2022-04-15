# frozen_string_literal: true
Rails::Engine.prepend(
  Module.new do
    def load(file, *)
      initializer = file.sub(Rails.root.to_s, ".")
      Bumbler::Hooks.benchmark(initializer) { super }.last
    end
  end
)

Rails::Initializable::Initializer.prepend(
  Module.new do
    def run(*)
      name = (@name.is_a?(Symbol) ? @name.inspect : @name)
      Bumbler::Hooks.benchmark(name) { super }.last
    end
  end
)
