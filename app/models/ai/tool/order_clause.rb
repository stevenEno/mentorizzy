class Ai::Tool::OrderClause
  ALLOWED_DIRECTIONS = %w[ ASC DESC ].freeze
  attr_reader :order
  attr_accessor :defaults, :permitted

  def self.parse(value, **options)
    new(nil, **options).tap do |order_clause|
      if value
        value.split(",").each do |clause|
          column, direction = clause.split(" ", 2)
          order_clause.add(column.strip, direction.strip)
        end
      end
    end
  end

  def initialize(order = nil, defaults: nil, permitted: nil)
    @order = order || {}
    @defaults = defaults || {}
    @permitted = permitted || []
  end

  def add(column, direction)
    if ALLOWED_DIRECTIONS.none? { |allowed_direction| direction.casecmp?(allowed_direction) }
      raise ArgumentError, "Invalid direction"
    end

    order[column] = direction.downcase.to_sym
  end

  def to_h
    hash = order.with_indifferent_access

    defaults.each do |key, value|
      hash[key] = value unless hash.key?(key)
    end

    hash.slice(*permitted)
  end
end
