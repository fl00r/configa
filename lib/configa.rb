require "configa/version"
require "yaml"

module Configa
  extend self

  def new(path)
    MagickStruct.new(path).data
  end

  class MagickStruct
    attr_reader :data

    def initialize(path)
      @base_path = path
      @base_dir = File.dirname(path)
      load_and_parse_yaml
    end

    def load_and_parse_yaml(env=nil)
      @yaml ||= begin
        file = File.read(@base_path)
        YAML.load(file)
      end
      if env
        env_path = File.join(@base_dir, env.to_s + ".yml")
        return nil  unless File.exist?(env_path)
        file = File.read(env_path)
        env_yaml = { "#{env}" => YAML.load(file) }
        @yaml.merge!(env_yaml)
      end
      root_keys = @yaml.keys
      merger = Proc.new do |data|
        data.each do |k,v|
          next  unless Hash === v
          if root_keys.include? k
            data[k.to_s] = @yaml[k].merge(data[k])
          else
            merger.call(data)
          end
        end
      end
      @yaml.each do |k,v|
        merger.call(v)
      end
      @data = magick(@yaml)

      struct = self
      @data.define_singleton_method(:__struct) do
        return struct
      end

      @data.define_singleton_method(:method_missing) do |name, *args, &blk|
        if new_data = __struct.load_and_parse_yaml(name) 
          @data.define_singleton_method(name) do
            new_data[name]
          end
          new_data.send(name)
        else
          super(name, args, &blk)
        end
      end

      @data
    end

    def magick(data)
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
          data[k] = magick(v)
        end
      end
      data
    end
  end
end
