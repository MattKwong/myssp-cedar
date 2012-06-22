# == Schema Information
# Schema version: 20110331025929
#
# Table name: purchases
#
#  id           :integer         not null, primary key
#  program_id   :integer
#  vendor_id    :integer
#  date         :date
#  purchaser_id :integer
#  total        :decimal(, )
#  created_at   :datetime
#  updated_at   :datetime
#  tax          :decimal(, )

class Purchase < ActiveRecord::Base
  attr_accessible :date, :total, :tax, :purchase_type

  validates :program_id, :presence => true
  validates :vendor_id, :presence => true
  validates :purchaser_id, :presence => true
  validates :total, :presence => true
  validates :tax, :presence => true
  validates :date, :presence => true
  validates_inclusion_of :purchase_type, :in => ['Credit', 'Cash']
  validate :date_range

  belongs_to :program
  belongs_to :vendor
  belongs_to :purchaser, :class_name => "AdminUser"

  has_many :item_purchases, :dependent => :destroy
  has_many :items, :through => :item_purchases

  scope :for_program, lambda { |program| where(:program_id => program.id) }
  scope :after, lambda { |date| where('date > ?', date) }
  scope :before, lambda { |date| where('date <=', date) }

  default_scope :order => 'date DESC'

  def to_s
    "#{vendor.name} #{date}"
  end

  def accounted_for
    (item_purchases.map &:total_price_with_tax).sum
  end

  def unaccounted_for
    total - accounted_for
  end

  def food_item_total
    budget_item_id = BudgetItemType.find_by_name('Food').id
    (item_purchases.by_budget_line_type(budget_item_id).map &:total_price_with_tax).sum
  end

  def effective_tax_rate
    tax / total
  end

  def actual_tax_rate
    total_taxable = (item_purchases.taxable.map &:total_price).sum
    unless total_taxable == 0
      tax / total_taxable
    else
      0
    end
  end

  def purchased_by
    self.purchaser.name
  end


  private

  def date_range
    if self.date < program.start_date || self.date > program.end_date
      errors.add(:date, "The purchase date must be within the beginning and end dates of the program.")
    end
  end

end
