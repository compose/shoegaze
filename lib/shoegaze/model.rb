require "active_model"

class Shoegaze::Model
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON

  class UnknownRecordError < StandardError; end;

  class << self
    attr_writer :store

    def drop_records
      Shoegaze::Model.store = {}
    end

    def store
      if self == Shoegaze::Model
        @store ||= {}
      else
        Shoegaze::Model.store
      end
    end

    def ensure_model_namespace(model)
      # using an array here so that the models appear in the order they were created
      store[model.class] ||= []
    end

    def register_model(model)
      ensure_model_namespace(model)
      store[model.class] << model
      model
    end

    def unregister_model(model)
      ensure_model_namespace(model)
      store[model.class].delete(model)
      model
    end

    def records_for_class(klass)
      store[klass] || []
    end

    def where(options)
      records_for_class(self).select do |r|
        options.all? do |k, v|
          if v.is_a?(Enumerable)
            v.include?(r.send(k))
          else
            r.send(k) == v
          end
        end
      end
    end

    def find_by(options)
      where(options).first
    end

    def all
      records_for_class(self)
    end

    def first
      all[0]
    end

    def last
      all[-1]
    end

    def raw_find(id) #:nodoc:
      records_for_class(self).find { |r| r.id == id } ||
        raise(UnknownRecordError, "Couldn't find #{self} with ID=#{id}")
    end

    def find(id)
      raw_find(id)
    end
    alias :[] :find

    def exists?(id)
      raw_find(id) != nil
    end

    def count
      records_for_class(self).length
    end

    def select(&block)
      records_for_class(self).select(&block)
    end

    def create(attrs = {})
      instance = self.new(attrs)
      register_model(instance)
    end

    def update(id, atts)
      find(id).update_attributes(atts)
    end

    def destroy(id)
      find(id).destroy
    end

    def find_by_attribute(name, value) #:nodoc:
      records_for_class(self).find {|r| r.send(name) == value }
    end

    def method_missing(method_symbol, *args) #:nodoc:
      method_name = method_symbol.to_s

      if method_name =~ /^find_by_(\w+)!/
        send("find_by_#{$1}", *args) || raise(UnknownRecord)
      elsif method_name =~ /^find_by_(\w+)/
        find_by_attribute($1, args.first)
      elsif method_name =~ /^find_or_create_by_(\w+)/
        send("find_by_#{$1}", *args) || create($1 => args.first)
      elsif method_name =~ /^find_all_by_(\w+)/
        find_all_by_attribute($1, args.first)
      else
        super
      end
    end
  end

  attr_accessor :id

  def initialize(attrs = {})
    @id = SecureRandom.uuid
    @__data = RecursiveOpenStruct.new(attrs)
  end

  def save
    Shoegaze::Model.register_model(self)
  end
  alias :save! :save

  def destroy
    Shoegaze::Model.unregister_model(self)
  end
  alias :destroy! :destroy

  def update_attributes(attrs)
    attrs.each do |k, v|
      send("#{k}=", v)
    end
  end
  alias :update_attributes! :update_attributes

  def reload
    self.class.find(id) || raise(Shoegaze::Model::UnknownRecordError)
  end

  def method_missing(method_symbol, *args) #:nodoc:
    @__data.send(method_symbol, *args)
  end

  def as_json(_options = nil) # options not presently actually supported
    @__data.to_h.with_indifferent_access
  end
  alias :attributes :as_json
end
