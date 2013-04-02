Spoic3::Application.routes.draw do

  get "roster_item/update"

  get "scheduled_group/new"

  get "scheduled_group/confirmation"
  ActiveAdmin.routes(self)

#  devise_for :admin_users, ActiveAdmin::Devise.config
  as :admin_user do
    match '/admin_user/confirmation' => 'confirmations#update', :via => :put, :as => :update_admin_user_confirmation
  end

  devise_for :admin_users, :controllers => { :admin_users => "admin_users", :passwords => "passwords",
            :confirmations => "confirmations", :sessions => "sessions", :registrations => "devise_registrations" }

  resources :admin_users
  match 'admin/admin_users/:id/soft_delete', :to => 'admin_users#soft_delete', :as => 'soft_delete_admin_user'
  match 'admin/admin_users/:id/reactivate', :to => 'admin_users#reactivate', :as => 'reactivate_admin_user'
#  match "admin/confirmation/new", :to => 'active_admin/devise/confirmations#new', :as => 'new_admin_user_confirmation'

  resources :sites do
      resources :vendors, :shallow => true
  end

  resources :programs do
    resources :projects do
      resources :material_item_estimateds, :shallow => true
      resources :material_item_delivereds, :shallow => true
      resources :labor_items, :shallow => true
      resources :standard_items, :shallow => true
      end
    resources :periods, :shallow => true
    resources :purchases, :shallow => true do
      resources :item_purchases, :shallow => true
    end
    resources :food_inventories, :shallow => true do
      resources :food_inventory_food_items, :shallow => true
    end
    resources :items, :shallow => true
    get :autocomplete_user_name
    get :autocomplete_item
    get :activation
  end

  match "ops_pages/timeout" => 'ops_pages#timeout', :as => 'timeout_error'
  match "ops_pages/blocked_user" => 'ops_pages#blocked_user', :as => 'blocked_user'
  match "item_purchases/:program_id/index/:id" => 'item_purchases#index', :as => 'item_purchases'
  match "purchases/:id/delete" => 'purchases#destroy', :as => 'delete_purchase'
  match "food_inventory/:id/delete" => 'food_inventories#destroy', :as => 'delete_food_inventory'
  match "food_inventory_food_items/:id/delete" => 'food_inventory_food_items#destroy', :as => 'delete_item_inventory'
#Routes for jquery calls
  match 'food_inventories/:food_inventory_id/food_inventory_food_items/update_item_info/:id', :to => 'food_inventory_food_items#update_item_info'
  match 'programs/:program_id/items/show_similar_items', :to => 'items#show_similar_items'
  match 'programs/:id/get_budget_info', :to => 'programs#get_budget_items'
  match 'programs/:id/get_food_info', :to => 'programs#get_food_items'
  match 'programs/:id/get_projects_info', :to => 'programs#get_projects_items'
  match 'programs/:id/get_purchases_info', :to => 'programs#get_purchases_items'
  match 'programs/:id/get_sessions_info', :to => 'programs#get_sessions_items'
  match 'programs/:id/get_staff_info', :to => 'programs#get_staff_items'

#Auto scheduling routes
  match 'application/auto_schedule', :to => 'application#auto_schedule', :as => 'auto_schedule'
  match 'application/run_schedule', :to => 'application#run_schedule', :as => 'run_schedule'
  match 'application/rollback_junior_schedule', :to => 'application#rollback_junior_schedule', :as => 'rollback_junior_schedule'
  match 'application/rollback_senior_schedule', :to => 'application#rollback_senior_schedule', :as => 'rollback_senior_schedule'
  match 'application/update_requests', :to => 'application#update_requests', :as => 'update_requests'
  match 'application/report_results', :to => 'application#report_results', :as => 'report_results'
  match 'application/send_emails', :to => 'application#send_emails', :as => 'send_emails'

#Routes for registration jquery calls
  match 'registration/get_limit_info', :to => 'registration#get_limit_info'
  match 'registration/check_for_sessions_for_type', :to => 'registration#check_for_sessions_for_type'
  match 'registration/terms_and_conditions', :to => 'registration#terms_and_conditions'
  match 'registration/get_sites_for_group_type', :to => 'registration#get_sites_for_group_type'
  match 'registration/get_sites_for_other_groups', :to => 'registration#get_sites_for_other_groups'
  match 'registration/get_alt_sites_for_group_type', :to => 'registration#get_alt_sites_for_group_type'
  match 'registration/get_sessions_for_type_and_site', :to => 'registration#get_sessions_for_type_and_site'
  match 'registration/get_other_sessions_for_site', :to => 'registration#get_other_sessions_for_site'
  match 'registration/get_alt_sessions_for_type_site', :to => 'registration#get_alt_sessions_for_type_site'
  match 'registration/save_registration_data', :to => 'registration#save_registration_data'
  match 'registration/payment_gateway', :to => 'registration#process_cc_dep_payment'
  match 'registration/final_confirmation', :to => 'registration#final_confirmation'
  match 'registration/process_cc_dep_payment', :to => 'registration#process_cc_dep_payment'
  match 'registration/pay_by_check', :to => 'registration#pay_by_check'
  match 'registration/request_matrix', :to => 'registration#request_matrix'
  match 'registration/availability_matrix', :to => 'registration#availability_matrix'
  match 'registration/other_availability_matrix', :to => 'registration#other_availability_matrix'
  match 'registration/get_session_name', :to => 'registration#get_session_name'

  match 'payment/:id/cc_payment', :to => 'payment#cc_payment', :as => 'cc_payment'
  match 'payment/:id/process_cc_payment', :to => 'payment#process_cc_payment', :as => 'process_cc_payment'
  match 'payment/:id/create', :to => 'payment#create', :as => 'create'
  match "payment/:group_id/new" => 'payment#new', :as => "record_payment"
  match "payment/new_standalone_cc" => 'payment#new_standalone_cc', :as => "standalone_cc_payment"
  match "payment/create_standalone_cc" => 'payment#create_standalone_cc', :as => "create_standalone_cc"

  match "registration/:id/edit" => 'registration#edit', :as => "edit_registration"
  match "registration/:id/show" => 'registration#show', :as => "show_registration"
  match "registration/new_weekend" => 'registration#new_weekend', :as => "new_weekend_registration"
  match "registration/new" => 'registration#new', :as => "new_registration"

  match "items/new", :to => 'items#new', :as => 'add_item'
  resources :vendors #, :only => [:index]
  resources :purchases, :only => [:index]
  resources :food_inventories, :only => [:index]
  resources :items
  resources :projects
  resources :material_item_estimateds
  resources :material_item_delivereds, :only => [:index]
  resources :labor_items, :only => [:index]
  resources :standard_items
  resources :supporters
  match "supporter_survey", :to => 'supporters#new'
  #resources :login_requests
  match "/new_login_request", :to => 'login_requests#new_login_request', :as => 'new_login_request'
  match "/login_requests", :to => 'login_requests#create_login_request'
  match "/show_login_requests", :to => 'login_requests#login_requests_index', :as => 'show_requests'
  match "/thank_you", :to => 'login_requests#thank_you'
  match "/process_login_request/:id", :to => 'login_requests#process_login_request', :as => 'process_login_request'
  match "/delete_login_request/:id", :to => 'login_requests#delete_login_request', :as => 'delete_login_request'
  match "/create_church_from_request/:id", :to => 'login_requests#create_church', :as => 'create_church_from_request'
  match "/create_liaison_from_request/:id", :to => 'login_requests#create_liaison', :as => 'create_liaison_from_request'


  match "purchase/show_budgets/:id", :to => 'purchases#show_budgets', :as => 'purchase_budget'
  match "material_item_estimated/add_standard/:id", :to => 'material_item_estimateds#add_standard', :as => 'add_standard_item'

  #reports

  get "staff_reports", :controller => :staff_reports, :action => 'show', :as => 'staff_reports'
  get "staff_reports/food_reconciliation/:id", :controller => :staff_reports, :action => 'food_reconciliation', :as => 'food_reconciliation_report'
  get "staff_reports/food_inventory/:id", :controller => :staff_reports, :action => 'food_inventory', :as => 'food_inventory_report'
  get "staff_reports/materials_inventory/:id", :controller => :staff_reports, :action => 'materials_inventory', :as => 'materials_inventory_report'
  get "staff_reports/food_budget/:id", :controller => :staff_reports, :action => :food_budget, :as => 'food_budget_report'
  get "staff_reports/food_consumption/:id", :controller => :staff_reports, :action => :food_consumption, :as => 'food_consumption_report'
  get "staff_reports/session/:id", :controller => :staff_reports, :action => :session, :as => 'session_report'
  get "food_inventories/:program_id/inventory_prep_report", :controller => :food_inventories, :action => 'inventory_prep_report', :as => 'inventory_prep_report'

  match "material_item_delivereds/add/:id", :to => 'material_item_delivereds#new', :as => 'deliver_project'
  match "material_item_delivereds", :to => 'material_item_delivereds#create', :as => 'add_material_item'
  match "material_item_estimateds/:id/edit", :to => 'material_item_estimateds#edit', :as => 'edit_material_item_estimated'
  match "material_item_estimateds", :to => 'material_item_estimateds#delete', :as => 'delete_material_item_estimated'
  match "material_item_estimateds", :to => 'material_item_estimateds#create', :as => 'add_material_item_estimated'
  match "labor_item", :to => 'labor_items#create', :as => 'add_labor_item'
  match "labor_items/add/:id", :to => 'labor_items#new', :as =>'labor_project'

  #match "food_inventory_food_item/:id/new", :to => 'food_inventory_food_items#new', :as => 'add_food_inventory_food_item'

# Old registration routes
  match "move_stage/:id" => 'projects#move_stage', :as =>'project_review'
  match "registration/schedule", :to => 'registration#schedule', :as => "registration_schedule"
  #match "registration/register", :to => 'registration#register'
  match "registration/:id/update", :to => 'registration#process_payment', :as => 'registration_payment'
  match "registration/:id/finalize" => 'registration#finalize', :as => 'registration_finalize'
  match "registration/:id/successful" => 'registration#successful', :as => 'registration_success'
  match "registration/show_schedule" => 'registration#show_schedule'

  match "registration/:id/schedule" => 'registration#schedule', :as => 'schedule_request'
  match "registration/:id/program_session" => 'session#program_session', :as => 'reg_program_session'
  match "registration/alt_schedule" => 'registration#alt_schedule', :as => 'alt_schedule_group'
  match "scheduled_groups/:id/program_session" => 'scheduled_groups#program_session', :as => 'sched_program_session'

  match "scheduled_groups/:id/new" => 'scheduled_groups#new', :as => "new_scheduled_group"
  match "scheduled_groups/:id/success" => 'scheduled_groups#success', :as => "scheduled_group_confirmation"
  match "scheduled_groups/:id/change_success" => 'scheduled_groups#change_success', :as => "change_confirmation"
  match "liaisons/:id/create_user" => 'liaisons#create_user', :as => 'create_user'
#  match "liaisons/:id/update" => 'liaisons#update', :as => 'update_liaison'

  match "payments" => 'payment#create', :as => 'payments'
  match "payment/:id" => 'payment#show', :as => 'show_payment'
  match "adjustment/:group_id/new" => 'adjustment#new', :as => "make_adjustment"
  match "adjustments" => 'adjustment#create', :as => 'adjustments'

  match "scheduled_groups/:id/invoice" => 'scheduled_groups#invoice', :as => "invoice"
  match "scheduled_groups/:id/statement" => 'scheduled_groups#statement', :as => "statement"
  match "budget/budget_summary" => 'budget#budget_summary', :as => "budget_show"
  match "roster_item/new" => 'roster_item#new', :as => 'new_roster_item'
  match "roster_items" => 'roster_item#create', :as => 'roster_items'
  match "roster_items/:id" => 'roster_item#edit', :as => 'edit_roster_item'
  match "roster_items/:id/delete" => 'roster_item#delete', :as => 'delete_roster_item'
  match "rosters/:id" => 'rosters#show', :as => "show_roster"
#  match "rosters/:id" => 'rosters#update', :as => "update_roster_items"

  resources :roster_item do
#    show 'show'
     post 'update'
   end

  resources :registration do
    post 'create'
    put :edit
    put 'process_payment'
  end
  match "scheduled_groups/invoice_report" => 'scheduled_groups#invoice_report', :as => 'invoice_report'
  #match "scheduled_groups/invoice_report.csv" => 'scheduled_groups#invoice_report', :as => 'invoice_report_csv'
  match "scheduled_groups/tshirt_report" => 'scheduled_groups#tshirt_report', :as => 'tshirt_report'
  match "scheduled_groups/tshirt_report.csv" => 'scheduled_groups#tshirt_report', :as => 'tshirt_report_csv'
  match "reports/church_and_liaison" => 'reports#church_and_liaison', :as => 'church_and_liaison_csv'
  match "reports/scheduled_liaisons" => 'reports#scheduled_liaisons', :as => 'scheduled_liaisons_csv'
  match "reports/scheduled_liaisons" => 'reports#scheduled_liaisons', :as => 'scheduled_liaisons_html'
  match "reports/rosters" => 'reports#rosters', :as => 'rosters_csv'
  match "reports/rosters" => 'reports#rosters', :as => 'rosters_html'
  match "reports/participation_summary" => 'reports#participation_summary', :as => 'part_sum_csv'
  match "reports/missing_churches" => 'reports#missing_churches_alt', :as => 'missing_churches_csv'
  match "reports/new_churches" => 'reports#new_churches', :as => 'new_churches_csv'
  match "scheduled_groups/two_year_report.csv" => 'scheduled_groups#two_year_report', :as => 'two_year_report_csv'

  match "reports/purchases_with_unaccounted" => 'purchases#show_all_unaccounted', :as => 'unaccounted_report'
  match "staff_reports/spending_by_site" => 'staff_reports#spending_by_site', :as => 'spending_by_site_report'
  match "staff_reports/get_spending_info" => 'staff_reports#get_spending_items'
  resources :vendors
  resources :churches
  resources :liaisons
  resources :scheduled_groups
#  match "liaisons/edit/:id", :to => 'liaisons#edit', :as => 'edit_liaison'
#  match "churches/edit/:id", :to => 'churches#edit', :as => 'edit_church'
  match "churches/main/:id", :to => 'liaisons#show', :as => "myssp"
  match "churches/main/:id", :to => 'liaisons#show', :as => "liaison"
  match "registration", :to => 'index', :as => 'registrations'
  match "registration/show_schedule", :to => 'registration#show_schedule'
  match "registration/update", :to => 'registration#update'
  match "registration/delete", :to => 'registration#delete'
  match 'RegistrationController', :to => 'pages#groups'

  match "application/log_off_and_lock_out_users", :to => "application#lock_out_users", :as => 'lock_out'
  match "application/unlock_users", :to => "application#unlock_users", :as => 'unlock'
  match "application/update_flags", :to => "application#update_flags", :as => 'update_flags'

  match '/admin', :to => 'admin#index'
  match 'ops_pages/food', :to => 'ops_pages#food', :as => 'food'
  match 'ops_pages/show', :to => 'ops_pages#show', :as => 'ops_pages_show'
  match 'ops_pages/show_prior_year', :to => 'ops_pages#show_prior_year', :as => 'ops_pages_show_old'
  match 'ops_pages/construction', :to => 'ops_pages#construction', :as => 'construction'
  match 'ops_pages/staff', :to => 'ops_pages#staff', :as => 'staff'
  match 'ops_pages/index', :to => 'ops_pages#index', :as => 'ops_index'

  match '/help', :to => 'pages#help', :as => 'help'
  match '/contact', :to => 'pages#contact'
  match '/about', :to => 'pages#about'
  match '/signin', :to => 'pages#home'
  match '/signout', :to => 'pages#home'
  match '/availability', :to => 'pages#availability'
  match '/availability_other', :to => 'pages#availability_other'
  match '/index', :to => 'SspWeb#index'
  match '/support', :to => 'SspWeb#support'
  root :to => 'pages#home'

  get "program_type/show"

end
