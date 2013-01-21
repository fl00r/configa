require "configa/version"
require "yaml"

module Configa
  class UnknownEnvironment < StandardError; end
  class UnknownKey < StandardError; end

  extend self

  def new(path, opts={})
    MagicContainer.new(path, opts)
  end

  class MagicContainer
    def initialize(path, opts={})
      @base_extname = File.extname(path)
      @base_env = File.basename(path, @base_extname)
      @base_dir = File.dirname(path)
      @yamls = {}
      @yaml = {}

      if opts[:env]
        fn = File.join(@base_dir, opts[:env].to_s + @base_extname)
        if File.exist?(fn)
          @default_env = opts[:env]
        else
          puts "Configa WARNING: can't find #{fn}, using base configuration"
        end
      end

      parser(@base_env)
    end

    def to_s
      @yaml
    end

    def parser(env=nil)
      load_yaml(env)
      load_yaml(@default_env.to_s) if @default_env

      @yaml = merge_yamls
      @yaml = @yaml[@default_env.to_s] || {} if @default_env

      @yaml = magic(@yaml)
    end

    def load_yaml(env)
      @yamls[env] ||= begin
        path = File.join(@base_dir, env.to_s + @base_extname)

        file = File.read(path)
        yaml = YAML.load(file)
        yaml
      end
    end

    def merge_yamls
      base = @yamls[@base_env]
      yaml = dup(base)
      @yamls.each do |env, data|
        next if env == @base_env
        yaml[env.dup] = dup(base.merge data)
      end
      merge_yaml(yaml)
      yaml
    end

    # Tree traverse
    def merge_yaml(yaml, cache={})
      yaml.each do |k,v|
        next  unless Hash === v
        cache[k] ||= {}
        cache[k] = v  if cache[k] != v
      end
      yaml.each do |k,v|
        next  unless Hash === v
        v.each do |key, val|
          if cache[key]
            yaml[k][key] = cache[key].merge yaml[k][key]  if cache[key] != val
          end
        end
        yaml[k] = merge_yaml(yaml[k], cache)
      end
      yaml
    end

    def magic(data)
      data.each do |k,v|
        data.define_singleton_method(k) do |*args|
          opts = {}
          opts = args.pop if Hash === args.last
          hash = opts[:hash]
          res = if args.any?
            args.map do |arg|
              data[k][arg.to_s]
            end
          else
            data[k]
          end
          if hash
            if args.any?
              Hash[ [res].flatten.map{ |r| [args.shift, r]} ]
            else
              res
            end
          else
            res
          end
        end
        data.define_singleton_method(:method_missing) do |name, *args, &blk|
          raise Configa::UnknownKey, "Unknown key '#{name}' for current node. Available keys are: '#{data.keys * '\', \''}'. Current node: #{data.inspect}"
        end
        if Hash === v
          data[k] = magic(v)
        end
      end
      data
    end

    def method_missing(name, *args, &blk)
      path = File.join(@base_dir, name.to_s + @base_extname)
      unless @yaml[name.to_s] || @yamls[name.to_s]
        if File.exist?(path)
          parser(name.to_s)
        end
      end
      @yaml.send(name, *args, &blk)
    rescue
      raise Configa::UnknownEnvironment, "Unknown environment '#{name}', and file '#{path}' doesn't exist also"
    end

  private

    def dup(hash)
      marshal = Marshal.dump(hash)
      Marshal.load(marshal)
    end
  end
end