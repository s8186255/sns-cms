ActionController::Routing::Routes.draw do |map|
  map.resources :topic_types

  
  map.resources :main,:collection=>{:live=>:get}
  map.resources :users,
    :collection=>{:list_users=>:get,
    :show_real_user=>:get,
    :list_followers=>:get,
    :list_maintainers=>:get,
    :edit_current_user=>:get,

  }

  map.resources :user_info_types,
    :collection=>{:edit_user_info_types=>:get,:update_user_info_types=>:put}
  map.resources :registers
  map.resources :user_managements,
    :collection=>{:update_user_info=>:put,:edit_user_info=>:get}
  map.resources :zones,
    :collection=>{:show_sign_in=>:get,
    :show_no_sign_in=>:get,
    :list_info=>:get,
    :display_info_details=>:get,
  }
  map.resources :gmap,
    :collection=>{:map=>:get}
  map.resources :attachments
  map.resources :pictures,:member=>{:thumb=>:get}
  map.resources :my,
    :collection=>{:app=>:get,
    :more_infos=>:get,
    :index_no_sign_in=>:get,
    :more_in_app=>:get,
    :maintainings_to_be_verified_by_logon_user=>:get,
    :followings_to_be_verified_by_logon_user=>:get,
    :topic_infos_to_be_verified_by_logon_user=>:get,
    :my_info=>:get,
    :my_c_topics=>:get,
    :my_m_topics=>:get,
    :my_f_topics=>:get,
    :info_detail=>:get,
    :edit_info=>:get,
    :drop_info=>:get,
    :update_info=>:put,
    :list_infos_of_topic=>:get,
    :new_info=>:get,
    :create_info=>:put,
    :list_topics=>:get,
    :new_topic=>:get,
    :create_topic=>:put,
    :edit_topic=>:get,
    :update_topic=>:put,
    :list_helpers_of_topic=>:get,
    :config_helpers_of_topic=>:get,
    

  }
  map.resources :roles
  map.namespace :admin do |admin|
    admin.resources :users,:collection=>{:activate=>:put}
    admin.resources :info_types,:collection=>{:add_field=>:get,:new_info_type=>:post}
    admin.resources :item_types,:collection=>{:update_infotype=>:put}
    admin.resources :content_types
    admin.resources :roles
    admin.resources :functions
    admin.resources :user_functions
    admin.resources :fee_records
    admin.resources :display_topics
  end

  map.namespace :example do |example|
    example.resources :chapter2,:collection=>{:myaction=>:get,:myresponse=>:get}
    example.resources :chapter3,:collection=>{:get_time=>:get,:reverse=>:get,:repeat=>:get,:add_tast=>:get}
    example.resources :chapter5,:collection=>{:alert_without_rjs=>:get,:alert_with_rjs=>:get,:external=>:get}
  end

  map.namespace :user do |user|
    user.resources :teams
    user.resources :tools,:collection=>{:my_tool=>:get,:myresponse=>:get}

  end

  map.resources :user_functions
  map.resources :functions

  map.resource :session
  map.resources :topics,
    :collection=>{
    :more_c_topics=>:get,
    :more_m_topics=>:get,
    :more_f_topics=>:get,
    


  }
  map.resources :followings,
    :collection=>{:edit_followings=>:get,
    :update_followings=>:put,
    :verify_following=>:get,
    :participate_following=>:get,
    :cancel_following=>:get,
  }

  map.resources :maintainings,
    :collection=>{:edit_maintainings=>:get,
    :update_maintainings=>:put,
    :verify_maintaining=>:get,
    :participate_maintaining=>:get,
    :cancel_maintaining=>:get,
  }

  map.resources :comments,:topic_infos
  map.resources :tags,:books
  #map.resources :info_types,:collection=>{:add_field=>:get,:new_info_type=>:post}
  map.resources :infos,
    :collection=>{:delete_info=>:put,
    :get_newest_infos=>:get,
    :get_my_infos=>:get,
    :update_info=>:put,
    :add_attachment=>:get,
    :list_info_types=>:get,
    :send_file_to_user=>:get,
    :show_info=>:get,
    :upload_editor_image=>:post,
    :upload_editor_attach=>:post,
    :verify_topic_info=>:get,
    :display_info_details=>:get
  }
  map.resources :special_displays,
    :collection=>{:grid_index=>:get}

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "main",:action=>'index'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':title', :controller => 'zones', :action => 'show'
  map.connect '', :controller => "index", :action => "i"
  #map.connect ':controller/:action/:id.:format'

  map.activate '/activate/:activation_code', :controller => 'registers', :action => 'activate'
end
