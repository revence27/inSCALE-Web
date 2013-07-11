Contentment::Application.routes.draw do
  root                  :to => 'contentment#chooser', :as => 'beginning'
  match 'record/:data', :to => 'contentment#record',  :as => 'record'
  match 'inbound',      :to => 'contentment#inbound', :as => 'inbound',   :via => :post
  match 'monthly',      :to => 'contentment#monthly', :as => 'monthly'
  match 'weekly',       :to => 'contentment#weekly',  :as => 'weekly'

  scope '/system' do
    root                                                :to => 'contentment#index',                                                 :as => 'home'
    match 'clients',                                    :to => 'contentment#clients',                                               :as => 'clients'
    match 'get_latest/:code/:version/:status',          :to => 'contentment#update',                                                :as => 'client_update'
    match 'client_download/:code/:version.:format',     :to => 'contentment#client_download',                                       :as => 'client_download'
    match 'auth(/:who)',                                :to => 'contentment#auth',                                                  :as => 'auth'
    match 'publisher(/:id)',                            :to => 'contentment#publisher',                                             :as => 'publisher'
    match 'application/:id',                            :to => 'contentment#application',                                           :as => 'application'
    match 'messaging(/:dest)',                          :to => 'contentment#messaging',                                             :as => 'messaging'
    match 'excel',                                      :to => 'statistics#csv',                                                    :as => 'csv'
    match 'feedback(/:page)',                           :to => 'contentment#feedback',                                              :as => 'feedback'
    match 'users(/:userid)',                            :to => 'contentment#users',                                                 :as => 'users'
    match 'admins',                                     :to => 'contentment#admins',                                                :as => 'admins'
    match 'mails',                                      :to => 'contentment#mails',                                                 :as => 'mails'
    match 'supervisors/:supid',                         :to => 'contentment#supervisors',                                           :as => 'sups'
    match 'tag(/:name)',                                :to => 'contentment#tags',                                                  :as => 'tag'
    match 'sendmessages',                               :to => 'contentment#send_messages',                                         :as => 'send_messages'
    match 'responses',                                  :to => 'contentment#vht_responses',                                         :as => 'responses'
    match 'response/:id',                               :to => 'contentment#vht_response_change',                                   :as => 'response_change'
    match 'motivators',                                 :to => 'contentment#vht_motivators',                                        :as => 'motivators'
    match 'motivator/:id',                              :to => 'contentment#vht_motivator_change',                                  :as => 'motivator_change'
    match 'users_update/:id',                           :to => 'contentment#users_update',                                          :as => 'users_update'
    match 'sups_update/:id',                            :to => 'contentment#sups_update',                                           :as => 'sups_update'
    match 'periodic',                                   :to => 'contentment#periodic',                                              :as => 'periodic'
    match 'system_health',                              :to => 'contentment#system_health',                                         :as => 'system_health'
    match 'search',                                     :to => 'contentment#search',                                                :as => 'search'
    # match 'locations',                                  :to => 'contentment#locations',                                             :as => 'locations'

    match 'download_feedbacks',                         :to => 'contentment#download_feedbacks',                                    :as => 'download_feedbacks',              :via => :post
    match 'ranged_excel',                               :to => 'statistics#ranged_csv',                                             :as => 'ranged_csv',                      :via => :post
    match 'motivator_changer/:id',                      :to => 'contentment#vht_motivator_changer',                                 :as => 'motivator_changer',               :via => :post
    match 'response_changer/:id',                       :to => 'contentment#vht_response_changer',                                  :as => 'response_changer',                :via => :post
    match 'destroy/:app',                               :to => 'contentment#destroy_app',                                           :as => 'destroy_app',                     :via => :post
    match 'create_app',                                 :to => 'contentment#create_app',                                            :as => 'app_create',                      :via => :post
    match 'upload_client',                              :to => 'contentment#upload_client',                                         :as => 'client_upload',                   :via => :post
    match 'update_publisher/:id',                       :to => 'contentment#update_publisher',                                      :as => 'update_publisher',                :via => :post
    match 'update_application/:id',                     :to => 'contentment#update_application',                                    :as => 'update_application',              :via => :post
    match 'create_publisher',                           :to => 'contentment#create_publisher',                                      :as => 'publisher_create',                :via => :post
    match 'delete_publisher/:id',                       :to => 'contentment#delete_publisher',                                      :as => 'publisher_delete',                :via => :post
    match 'delete_application/:id',                     :to => 'contentment#delete_application',                                    :as => 'application_delete',              :via => :post
    match 'create_tag/:id',                             :to => 'contentment#create_tag',                                            :as => 'create_tag',                      :via => :post
    match 'delete_tag/:id',                             :to => 'contentment#delete_tag',                                            :as => 'delete_tag',                      :via => :post
    match 'create_user',                                :to => 'contentment#create_user',                                           :as => 'create_user',                     :via => :post
    match 'delete_user/:id',                            :to => 'contentment#delete_user',                                           :as => 'delete_user',                     :via => :post
    match 'delete_mail/:id',                            :to => 'contentment#delete_mail',                                           :as => 'delete_mail',                     :via => :post
    match 'add_mail',                                   :to => 'contentment#add_mail',                                              :as => 'add_mail',                        :via => :post
    match 'delete_sup/:id',                             :to => 'contentment#delete_supervisor',                                     :as => 'delete_sup',                      :via => :post
    match 'users_change/:id',                           :to => 'contentment#users_change',                                          :as => 'users_change',                    :via => :post
    match 'sups_change/:id',                            :to => 'contentment#sups_change',                                           :as => 'sups_change',                     :via => :post
    match 'periodic_send',                              :to => 'contentment#periodic_send',                                         :as => 'periodic_send',                   :via => :post
    match 'create_task',                                :to => 'contentment#create_task',                                           :as => 'create_task',                     :via => :post
    match 'new_bug_report',                             :to => 'contentment#new_bug_report',                                        :as => 'new_bug_report',                  :via => :post
    match 'qc',                                         :to => 'contentment#quality_control',                                       :as => 'quality_control',                 :via => :post
  end

  scope '/data' do
    root :to => 'statistics#index', :as => 'data'
  end
end
