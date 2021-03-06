# frozen_string_literal: true

Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  root to: 'dashboard#new_dash', as: :dashboard

  # Have to have this root route *without* the as: parameter, otherwise we get weirdness like #247
  root to: 'dashboard#new_dash'

  scope '/dumps' do
    root to: 'dashboard#db_dumps', as: :dumps
    get 'download', to: 'dashboard#download_dump', as: :download_dump
  end

  scope '/authentication' do
    get 'status', to: 'authentication#status', as: :authentication_status
    get 'redirect_target', to: 'authentication#redirect_target'
    get 'login_redirect_target', to: 'authentication#login_redirect_target'
  end

  scope '/users' do
    root to: 'admin#users', as: :users
    get 'username', to: 'users#username', as: :users_username
    post 'username', to: 'users#set_username'
    get 'apps', to: 'users#apps', as: :users_apps
    delete 'revoke_app', to: 'users#revoke_app', as: :users_revoke_app

    get '2fa', to: 'users#tf_status'
    post '2fa/enable', to: 'users#enable_2fa'
    get '2fa/enable/code', to: 'users#enable_code'
    post '2fa/enable/code', to: 'users#confirm_enable_code'
    get '2fa/disable/code', to: 'users#disable_code'
    post '2fa/disable/code', to: 'users#confirm_disable_code'

    post 'update_email', to: 'users#update_email'

    get 'denied', to: 'users#missing_privileges', as: :missing_privileges

    get ':id', to: 'users#show', as: :user, constraints: { id: /\d+/ }
    post ':id/update_ids', to: 'users#refresh_ids', as: :update_user_chat_ids
    post ':id/reset_pass', to: 'users#send_password_reset', as: :send_password_reset
    post ':id/update_mod_sites', to: 'users#update_mod_sites', as: :update_mod_sites
  end

  scope '/review' do
    root to: 'review#index', as: :review
    post 'feedback', to: 'review#add_feedback', as: :review_feedback
    post 'skip', to: 'review#skip', as: :review_skip
    get 'history', to: 'review#history', as: :review_history
    post 'unskip', to: 'review#delete_skip', as: :review_unskip
  end

  get 'spammers', to: 'stack_exchange_users#index'
  get 'spammers/sites', to: 'stack_exchange_users#sites', as: :spammers_site_index
  get 'spammers/site', to: 'stack_exchange_users#on_site', as: :spammers_on_site
  post 'spammers/site/:site/update', to: 'stack_exchange_users#update_data'
  post 'spammers/dead/:id', to: 'stack_exchange_users#dead'
  get 'spammers/:id', to: 'stack_exchange_users#show', as: :stack_exchange_user

  get 'search', to: 'search#index'

  scope '/graphs' do
    root to: 'graphs#index', as: :graphs
    get 'flagging_results', to: 'graphs#flagging_results'
    get 'flagging_timeline', to: 'graphs#flagging_timeline', as: :flagging_timeline_graph
    get 'reports_hours', to: 'graphs#reports_by_hour', as: :reports_by_hour_graph
    get 'reports_sites', to: 'graphs#reports_by_site'
    get 'reports_hod', to: 'graphs#reports_by_hour_of_day'
    get 'ttd', to: 'graphs#time_to_deletion'
    get 'dttd', to: 'graphs#detailed_ttd'
    get 'monthly_ttd', to: 'graphs#monthly_ttd', as: :monthly_ttd_graph
    get 'reports', to: 'graphs#reports', as: :reports_graph
    get 'af_accuracy', to: 'graphs#af_accuracy', as: :af_accuracy
  end

  get 'status', to: 'status#index', as: :status
  get 'status/code.json', to: 'code_status#api'
  get 'status/code', as: :code_status, to: 'code_status#index'
  post 'status/kill', to: 'status#kill', as: :kill_smokey

  get 'smoke_detector/mine', to: 'smoke_detectors#mine'
  get 'smoke_detector/new', to: 'smoke_detectors#new'
  post 'smoke_detector/create', to: 'smoke_detectors#create'
  post 'smoke_detector/:id/token_regen', to: 'smoke_detectors#token_regen', as: :smoke_detector_token_regen
  get 'smoke_detector/:id/statistics', to: 'statistics#index', as: :smoke_detector_statistics
  delete 'smoke_detector/:id', to: 'smoke_detectors#destroy', as: :smoke_detector_delete
  post 'smoke_detector/:id/force_failover', to: 'smoke_detectors#force_failover', as: :smoke_detector_force_failover
  get 'smoke_detector/audits', to: 'smoke_detectors#audits'
  get 'smoke_detector/check_token/:token', to: 'smoke_detectors#check_token'
  post 'statistics.json', to: 'statistics#create'

  get 'admin', to: 'admin#index'
  get 'admin/invalidated', to: 'admin#recently_invalidated'
  get 'admin/user_feedback', to: 'admin#user_feedback', as: :admin_user_feedback
  get 'admin/api_feedback', to: 'admin#api_feedback'
  get 'admin/flagged', to: 'admin#flagged'
  post 'admin/clear_flag', to: 'admin#clear_flag'
  get 'admin/users', to: 'admin#users'
  get 'admin/ignored_users', to: 'admin#ignored_users'
  patch 'admin/ignore/:id', to: 'admin#ignore'
  patch 'admin/unignore/:id', to: 'admin#unignore'
  delete 'admin/destroy_ignored/:id', to: 'admin#destroy_ignored'
  get 'admin/permissions'
  put 'admin/permissions/update', to: 'admin#update_permissions'

  get 'admin/invalidate_tokens', to: 'authentication#invalidate_tokens'
  post 'admin/invalidate_tokens', to: 'authentication#send_invalidations'

  get 'admin/new_key', to: 'api_keys#new'
  post 'admin/new_key', to: 'api_keys#create'
  get 'admin/keys', to: 'api_keys#index'
  get 'admin/keys/mine', to: 'api_keys#mine'
  get 'admin/edit_key/:id', to: 'api_keys#edit'
  patch 'admin/edit_key/:id', to: 'api_keys#update'
  get 'admin/owner_edit/:id', to: 'api_keys#owner_edit'
  patch 'admin/owner_edit/:id', to: 'api_keys#owner_update'
  delete 'admin/revoke_write', to: 'api_keys#revoke_write_tokens'
  delete 'admin/owner_revoke', to: 'api_keys#owner_revoke'
  post 'admin/keys/:id/trust', to: 'api_keys#update_trust'

  get 'posts', to: 'posts#index', as: :posts
  get 'posts/latest', to: 'posts#latest'
  get 'posts/by-url', to: 'posts#by_url'
  get 'posts/by-site', to: 'dashboard#spam_by_site', as: :spam_by_site
  post 'posts/needs_admin', to: 'posts#needs_admin'
  get 'post/:id/feedback/clear', to: 'feedbacks#clear', as: :clear_post_feedback
  delete 'feedback/:id/delete', to: 'feedbacks#delete', as: :delete_feedback

  get 'post/:id', to: 'posts#show'
  get 'post/:id/body', to: 'posts#body'
  get 'post/:id/feedbacks.json', to: 'posts#feedbacksapi'
  get 'post/:id/flag_logs', to: 'flag_log#by_post', as: :post_flag_logs
  get 'post/:id/eligible_flaggers', to: 'flag_log#eligible_flaggers', as: :post_eligible_flaggers
  post 'post/:id/index_feedback', to: 'posts#reindex_feedback'
  post 'post/:id/spam_flag', to: 'posts#cast_spam_flag'
  post 'post/:id/delete', to: 'posts#delete_post', as: :dev_delete_post

  get 'users', to: 'stack_exchange_users#index'

  post 'feedbacks.json', to: 'feedbacks#create'
  post 'posts.json', to: 'posts#create'
  post 'deletion_logs.json', to: 'deletion_logs#create'
  post 'status-update.json', to: 'status#status_update'

  get 'reasons', to: 'dashboard#index', as: :reasons
  get 'reason/:id', to: 'reasons#show', as: :reason
  get 'reason/:id/site_chart', to: 'reasons#sites_chart', as: :reason_site_chart
  get 'reason/:id/accuracy_chart', to: 'reasons#accuracy_chart', as: :reason_accuracy_chart

  get 'posts/recent.json', to: 'posts#recentpostsapi'
  post 'posts/add_feedback', to: 'review#add_feedback'

  scope '/github' do
    post 'status_hook', to: 'github#status_hook', as: :github_status_hook
    post 'pull_request_hook', to: 'github#pull_request_hook', as: :github_pull_request_hook
    post 'ci_hook', to: 'github#ci_hook', as: :github_ci_hook
    post 'update_deploy_to_master', to: 'github#update_deploy_to_master', as: :github_update_deploy_to_master
    post 'metasmoke_push_hook', to: 'github#metasmoke_push_hook', as: :github_metasmoke_push_hook
    post 'gollum', to: 'github#gollum_hook', as: :github_gollum_hook
    post 'project_status', to: 'github#any_status_hook', as: :github_project_status_hook
    post 'pr_merge', to: 'github#pullapprove_merge_hook', as: :github_pr_merge_hook
    post 'pr_approve/:number', to: 'github#add_pullapprove_comment', as: :github_pr_approve_comment
  end

  scope '/api' do
    root to: 'api#api_docs', as: :api_docs
    get  'filters', to: 'api#filter_generator'
    post 'filters', to: 'api#calculate_filter'

    get  'filter_fields', to: 'api#filter_fields'
    get  'stats/last_week', to: 'api#spam_last_week'
    get  'stats/detailed_ttd', to: 'api#detailed_ttd'
    get  'smoke_detectors/status', to: 'api#current_status'
    get  'smoke_detectors', to: 'api#smoke_detectors'
    get  'posts/urls', to: 'api#posts_by_url'
    post 'posts/urls', to: 'api#posts_by_url'
    get  'posts/feedback', to: 'api#posts_by_feedback'
    get  'posts/undeleted', to: 'api#undeleted_posts'
    get  'posts/site', to: 'api#posts_by_site'
    get  'posts/between', to: 'api#posts_by_daterange'
    get  'posts/search', to: 'api#search_posts'
    get  'posts/search/regex', to: 'api#regex_search'
    get  'posts/:ids', to: 'api#posts'
    get  'post/:id/feedback', to: 'api#post_feedback'
    get  'post/:id/reasons', to: 'api#post_reasons'
    get  'post/:id/valid_feedback', to: 'api#post_valid_feedback'
    get  'reasons', to: 'api#all_reasons'
    get  'reasons/:ids', to: 'api#reasons'
    get  'reason/:id/posts', to: 'api#reason_posts'
    get  'blacklist', to: 'api#blacklisted_websites'
    get  'users', to: 'api#users'
    get  'users/code_privileged', to: 'api#users_with_code_privs'
    get  'post/:id/domains', to: 'api#post_domains', as: :api_post_domains
    get  'domains/:id/tags', to: 'api#domain_tags', as: :api_domain_tags

    post 'w/post/:id/feedback', to: 'api#create_feedback'
    post 'w/post/report', to: 'api#report_post'
    post 'w/post/:id/spam_flag', to: 'api#spam_flag'
    post 'w/post/:id/deleted', to: 'api#post_deleted'
    post 'w/domains/:id/add_tag', to: 'api#add_domain_tag', as: :api_add_domain_tag
  end

  scope '/oauth' do
    get 'request', to: 'micro_auth#token_request', as: :oauth_request
    post 'authorize', to: 'micro_auth#authorize', as: :oauth_authorize
    get 'authorized', to: 'micro_auth#authorized', as: :oauth_authorized
    get 'reject', to: 'micro_auth#reject', as: :oauth_reject
    get 'token', to: 'micro_auth#token', as: :oauth_token
    get 'invalid_key', to: 'micro_auth#invalid_key', as: :oauth_invalid_key
  end

  scope '/dev' do
    post 'update_sites', to: 'developer#update_sites', as: :dev_update_sites
    get 'prod_log', to: 'developer#production_log', as: :dev_prod_log
    get 'blank', to: 'developer#blank_page', as: :dev_blank
    get 'websockets', to: 'developer#websocket_test'
    post 'websockets', to: 'developer#send_websocket_test'
  end

  # flagging
  get 'flagging', to: 'flag_settings#dashboard', as: :flagging
  scope '/flagging' do
    post 'smokey_disable', to: 'flag_settings#smokey_disable_flagging'
    resources :flag_settings, path: '/settings', except: [:show]
    get 'by-site', to: 'flag_settings#by_site', as: :flagging_by_site

    get 'ocs', to: 'flag_conditions#one_click_setup'
    post 'run_ocs', to: 'flag_conditions#run_ocs'

    get 'conditions/all', to: 'flag_conditions#full_list'
    get 'conditions/preview', to: 'flag_conditions#preview'
    get 'conditions/sandbox', to: 'flag_conditions#sandbox'
    resources :flag_conditions, path: '/conditions', except: [:show]
    patch 'conditions/:id/enable', to: 'flag_conditions#enable', as: :flag_conditions_enable

    get 'preferences/user/:user', to: 'user_site_settings#for_user'
    post 'preferences/enable', to: 'user_site_settings#enable_flagging'
    resources :user_site_settings, path: '/preferences', except: [:show]

    get 'logs', to: 'flag_log#index', as: :flag_logs
    get 'logs/unflagged', to: 'flag_log#not_flagged', as: :unflagged_logs
    get 'users/:user_id/logs', to: 'flag_log#index', as: :flag_logs_by_user
    get 'users/overview', to: 'flag_conditions#user_overview', as: :user_overview
    get 'users', to: 'users#flagging_enabled', as: :flagging_users

    scope '/audits' do
      get 'settings', to: 'flag_settings#audits', as: 'flag_settings_audits'
    end
  end

  scope '/announcements' do
    root               to: 'announcements#index', as: :announcements
    post ':id/expire', to: 'announcements#expire', as: :announcements_expire
    get  'new',        to: 'announcements#new'
    post 'new',        to: 'announcements#create'
    post 'enable',     to: 'users#set_announcement_emails'
  end

  scope '/data' do
    root             to: 'data#index',        as: :data_explorer
    get  'retrieve', to: 'data#retrieve',     as: :data_retrieve
    get  'schema',   to: 'data#table_schema', as: :data_schema
  end

  scope '/domains' do
    scope '/tags' do
      root                to: 'domain_tags#index',           as: :domain_tags
      post   'add',       to: 'domain_tags#add',             as: :add_domain_tag
      post   'remove',    to: 'domain_tags#remove',          as: :remove_domain_tag
      get    'mass',      to: 'domain_tags#mass_tagging',    as: :domain_tags_mass_tagging
      post   'mass',      to: 'domain_tags#submit_mass_tag', as: :domain_tags_submit_tagging
      get    ':id/edit',  to: 'domain_tags#edit',            as: :edit_domain_tag
      patch  ':id/edit',  to: 'domain_tags#update',          as: :update_domain_tag
      get    ':id',       to: 'domain_tags#show',            as: :domain_tag
      delete ':id',       to: 'domain_tags#destroy',         as: :destroy_domain_tag
    end

    root                  to: 'spam_domains#index',   as: :spam_domains
    post   'create.json', to: 'spam_domains#create',  as: :create_spam_domain
    get    ':id/edit',    to: 'spam_domains#edit',    as: :edit_spam_domain
    patch  ':id/edit',    to: 'spam_domains#update',  as: :update_spam_domain
    get    ':id',         to: 'spam_domains#show',    as: :spam_domain
    delete ':id',         to: 'spam_domains#destroy', as: :destroy_spam_domain
  end

  devise_for :users, controllers: { sessions: 'custom_sessions' }
  devise_scope :user do
    get  'users/2fa/login', to: 'custom_sessions#verify_2fa'
    post 'users/2fa/login', to: 'custom_sessions#verify_code'
  end

  # This should always be right at the end of this file, so that it doesn't override other routes.
  mount API::Base => '/api'
end
