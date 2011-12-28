module Innate
  class MiddlewareCompiler
    COMPILED = {}

    def self.build(name, &block)
      COMPILED[name] ||= new(name, &block)
    end

    def self.build!(name, &block)
      COMPILED[name] = new(name, &block)
    end

    attr_reader :middlewares, :name

    def initialize(name)
      @name = name.to_sym
      @middlewares = []
      @compiled = nil
      yield(self) if block_given?
    end

    def use(middleware, *args, &block)
      @middlewares << [middleware, args, block]
    end

    def apps(*middlewares)
      @middlewares.concat(middlewares.map{|mw| [mw, [], nil]})
    end

    def run(app)
      @app = app
    end

    def cascade(*apps)
      @app = Rack::Cascade.new(apps)
    end

    # Default application for Innate
    def innate(app = Innate::DynaMap, options = Innate.options)
      roots, publics = options[:roots], options[:publics]

      joined = roots.map{|root| publics.map{|public| ::File.join(root, public)}}

      apps = joined.flatten.map{|public_root| RackFileWrapper.new(public_root) }
      apps << Current.new(Route.new(app), Rewrite.new(app))

      cascade(*apps)
    end

    def call(env)
      compile
      @compiled.call(env)
    end

    def compile
      @compiled ? self : compile!
    end

    def compile!
      @compiled = @middlewares.reverse.
        inject(@app){|app, (middleware, args, block)|
          middleware.new(app, *args, &block) }
      self
    end
  end
end
