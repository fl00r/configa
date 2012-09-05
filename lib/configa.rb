require "configa/version"
require "yaml"

module Configa
  extend self

  def new(path)
    MagicContainer.new(path)
  end

  class MagicContainer
    def initialize(path)
      @base_extname = File.extname(path)
      @base_env = File.basename(path, @base_extname)
      @base_dir = File.dirname(path)
      @yamls = {}
      @yaml = {}
      parser
    end

    def parser(env=nil)
      env ||= @base_env
      load_yaml(env)
      @yaml = merge_yamls
      @yaml = merge_yaml(@yaml)
      @yaml = magic(@yaml)
    end

    def load_yaml(env)
      @yamls[env] ||= begin
        path = File.join(@base_dir, env.to_s + @base_extname)
        file = File.read(path)
        yaml = YAML.load(file)
        yaml = merge_yaml(yaml)
        yaml
      end
    end

    def merge_yaml(yaml)
      root_keys = yaml.keys
      yaml.each do |k,v|
        next  unless Hash === v
        v.each do |key, data|
          yaml[k][key] = yaml[key].merge data  if root_keys.include? key
        end
      end
      yaml
    end

    def merge_yamls
      ymls = @yamls.dup
      base = ymls.delete(@base_env)
      yaml = base
      ymls.each do |env, data|
        yaml[env] = base.merge(data)
      end
      yaml
    end

    def magic(data)
      data.each do |k,v|
        data.define_singleton_method(k) do |*args|
          if args.any?
            args.map do |arg|
              data[k][arg.to_s]
            end
          else
            data[k]
          end
        end
        if Hash === v
          data[k] = magic(v)
        end
      end
      data
    end

    def method_missing(name, *args, &blk)
      unless @yaml[name.to_s] || @yamls[name.to_s]
        path = File.join(@base_dir, name.to_s + @base_extname)
        if File.exist?(path)
          parser(name)
        end
      end
      @yaml.send(name, *args, &blk)
    end
  end
end