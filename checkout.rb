class CheckOut
  attr_accessor :items, :rules

  def initialize(rules)
    @rules = rules
    @items = []
  end

  def scan(item)
    @items << item
  end

  def total
    return 0 if items.empty?

    items_with_count.reduce(0) do |total, (item, count)|
      product = Product.new(rules[item])
      total += if product.discount?
                 product.apply_discount(count)
               else
                 count * product.price
               end
      total
    end
  end

  private

  def items_with_count
    @items_count = items.each_with_object(Hash.new(0)) do |item, items_count|
      items_count[item] += 1
    end
  end
end

class Product
  attr_reader :price

  def initialize(rule)
    @price = rule[:unit_price]
    @discount = rule[:special_price]
  end

  def discount?
    !@discount.nil?
  end

  def discounted_amount
    @discount[:count]
  end

  def discounted_price
    @discount[:price]
  end

  def apply_discount(count)
    if count < discounted_amount
      count * price
    else
      discounted_price = (count / discounted_amount) * self.discounted_price
      price_for_single_units = (count % discounted_amount) * price
      discounted_price + price_for_single_units
    end
  end
end
