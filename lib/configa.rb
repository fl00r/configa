require "configa/version"
require "yaml"

module Configa
  extend self

  def new(path)
    yaml = load_yaml(path)
    to_magickstruct(yaml)
  end

  def load_yaml(path)
    file = File.read(path)
    yaml = YAML.load(file)
    root_keys = yaml.keys
    merger = Proc.new do |data|
      data.each do |k,v|
        next  unless Hash === v
        if root_keys.include? k
          data[k.to_s] = yaml[k].merge(data[k])
        else
          merger.call(data)
        end
      end
    end
    yaml.each do |k,v|
      merger.call(v)
    end
    yaml
  end

  def to_magickstruct(yaml)
    config = MagickStruct.new(yaml).data
  end

  class MagickStruct
    attr_reader :data

    def initialize(data)
      data = magick(data)
      @data = data
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
