module WendingMachine
  class Inventory

    class UnregisteredItemError < StandardError; end
    class NegativeQuantityError < StandardError; end
    class NonPositiveValueError < StandardError; end
    class InsufficientItemsError < StandardError; end

    def initialize(list = [])
      @registered_items = {}
      @quantities = {}
      list.each do |item|
        name = item[:name] || item[:value].to_s
        register(name: name, value: item[:value])
        add(name, quantity: item[:quantity])
      end
    end

    def register(name:, value:)
      raise NonPositiveValueError unless value.to_f > 0

      @registered_items[name] = value.to_f
      @quantities[name] ||= 0
    end

    def list
      @registered_items.map do |item_name, value|
        {name: item_name, value: value, quantity: @quantities[item_name]}
      end
    end

    def add(name, quantity: 1)
      validate_input(name, quantity)
      @quantities[name] += quantity
    end

    def remove(name, quantity: 1)
      validate_input(name, quantity)
      raise InsufficientItemsError if @quantities[name] < quantity
      @quantities[name] -= quantity
    end

    def total_value
      @quantities.inject(0.0) do |total, e|
        name, quantity = e
        total += @registered_items[name] * quantity
      end
    end
    
    def merge!(inventory)
      inventory.list.each do |item|
        add(item[:name], quantity: item[:quantity])
      end
    end

    def quantity(name)
      @quantities[name]
    end

    def price(name)
      @registered_items[name]
    end

    def clear_quantities!
      @quantities.each do |k, _|
        @quantities[k] = 0
      end
    end

    def names
      @registered_items.keys
    end

    private

    def validate_input(name, quantity)
      raise UnregisteredItemError unless @registered_items.keys.include?(name)
      raise NegativeQuantityError unless quantity.to_i >= 0
    end
  end
end
