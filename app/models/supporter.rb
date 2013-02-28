class Supporter < ActiveRecord::Base
  attr_accessible :address1, :address2, :city, :phone, :phone_type,
                  :first_name, :gender, :last_name, :state, :zip,
                  :employer, :profession,
                  :church_name, :church_type, :church_denom,
                  :email, :newsletter_subscribe, :ssp_current_youth, :ssp_former_youth,
                  :ssp_adult, :ssp_parent, :ssp_grandparent, :ssp_leader, :ssp_heard,
                  :ssp_friends, :ssp_web, :ssp_other, :desire_board, :desire_training,
                  :desire_outreach, :desire_publicity, :desire_work_projects, :desire_web,
                  :desire_other, :desire_other_comments, :church_city, :church_role, :employer_comments,
                  :service_club, :other_community, :other_community_text, :skill_architecture,
                  :skill_auto_repair, :skill_board, :skill_carpentry, :skill_comp_prog,
                  :skill_comp_prog_comments, :skill_const, :skill_electrical, :skill_food_prep,
                  :skill_plumbing, :skill_press, :skill_safety, :skill_sewing, :skill_tool_repair,
                  :skill_video, :skill_web, :skill_other_comments, :fund_exper, :fund_exper_comments,
                  :fund_connect, :fund_connect_comments, :fund_in_kind, :fund_in_kind_comments,
                  :final_comments

  #validates_with Validator::SupporterValidator
  validates :first_name, :last_name, :address1, :city, :state, :email,
            :gender, :presence => true
  validates_inclusion_of :state, :in => State::STATE_ABBREVIATIONS, :message => 'Invalid state.'
  validates :zip, :presence => true, :length => { :maximum => 10, :minimum => 5 }
  validates :phone, :length => { :maximum => 20 }
end