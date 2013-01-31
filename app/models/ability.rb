class Ability
  include CanCan::Ability
  # used to authorize program user actions

  def initialize(user)
    if user.liaison?
       liaison = Liaison.find(user.liaison_id)
#      can :manage, Payment
      if liaison then
        can [:edit, :update], Church, :id => liaison.church_id
        can [:read, :edit, :update], Liaison, :id => liaison.id
        can [:manage], Registration, :liaison_id => liaison.id
        can [:create], Registration
        puts "Name is: ", liaison.name
      end
      groups = ScheduledGroup.find_all_by_liaison_id(user.liaison_id)
      if groups then
        can [:manage], ScheduledGroup, :liaison_id => user.liaison_id
        groups.each do |group|
          roster = Roster.find_by_group_id(group.id)
          can :manage, Roster, :id => group.roster_id
          can :manage, RosterItem, :roster_id => group.roster_id
          can :manage, Payment, :scheduled_group_id => group.id
        end
      end
      registrations = Registration.find_all_by_liaison_id(user.liaison_id)
      if registrations then
        can [:manage], Registration, :liaison_id => user.liaison_id
        registrations.each do |reg|
          can [:cc_payment, :process_cc_payment], Payment, :registration_id => reg.id
        end
      end
  #move is defined as being able to move a scheduled group and to increase their numbers
      cannot :move, ScheduledGroup
    end
 # Need to restrict purchases to program

  if user.field_staff?
      program = ProgramUser.find_by_user_id(user.id).program
      program_id = program.id
#     program = Program.find(program_id)
      can :index, Vendor, :site_id => program.site_id
      can :manage, Vendor, :site_id => program.site_id
      can [:see_vendors_for], Site, :id => program.site.id
      can [:see_items_for], Site, :id => program.site.id
      can [:read, :see_purchases_for, :see_food_inventories_for, :see_projects_for, :report], Program,
          :id => program_id
      can :index, Item
      cannot :index, Church
      can [:edit, :create, :delete], Item, :program_id => program_id
      can :read, Church
      can :read, Liaison
      can :read, ScheduledGroup
      can :read, Item
      can :manage, Item, :program_id => program_id
      can :read, Roster
      can :read, RosterItem
      can :manage, Program, :id => program_id
      can :manage, Purchase, :program_id => program_id
      can :report, Program
      can :manage, Site, :id => program.site_id

      can :manage, ItemPurchase
      if user.cook? || user.sd?
        can [:read, :create, :destroy, :update], FoodInventory, :program_id => program.id
        can [:read, :create, :destroy, :update], FoodInventoryFoodItem, :food_inventory =>
            { :program_id => program_id }
        can [:inventory_prep_report], FoodInventory
      end
     if user.construction? || user.sd?
        can :read, StandardItem
        can [:read, :create, :destroy, :update, :move_stage], Project, :program_id => program.id
        #can [:read, :create, :destroy, :update], Item, :program_id => program.id
        can [:read, :create, :destroy, :update], LaborItem, :project => { :program_id => program_id }
        can [:read, :create, :destroy, :update], MaterialItemDelivered, :project => { :program_id => program_id }
        can [:read, :create, :destroy, :update], MaterialItemEstimated, :project => { :program_id => program_id }
      end
  end

  if user.construction_admin? || user.food_admin?
      can :index, Vendor
      can :manage, Vendor
      can :see_vendors_for, Program
      can :see_vendors_for, Site
      can :manage, Item
      can :manage, ItemType
      can :manage, ItemCategory
      can :index, Item
      can :manage, Program
      can :manage, Purchase
      can :report, Program
      can :manage, ItemPurchase
  end

  if user.food_admin?
      can :index, FoodInventory
      can :manage, FoodInventory
      can :manage, FoodInventoryFoodItem
  end
  if user.construction_admin?
    can :manage, Project
    can :approve, Project, :id => project.id
    can :manage, LaborItem
    can :manage, ProjectType
    can :manage, MaterialItemDelivered
    can [:read, :create, :destroy, :update], MaterialItemEstimated
  end

   if user.admin?
     can :manage, :all
   end

  end
end
