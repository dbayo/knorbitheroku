# Knorbit - knowledge management software
# Copyright (C) 2011  Davi Bayo, Galo Gimenez
#
#MIT License
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

OmniauthDeviseExample::Application.routes.draw do

  match 'spaces/:space_id/documents/:id/savecomment' => 'documents#savecommentajax'
  match 'spaces/:space_id/exportPDF' => 'spaces#exportPDF'
  match 'spaces/:space_id/version/:id' => 'spaces#version'
  resources :spaces do
    resources :comments
    resources :documents do
      resources :versions      
    end
  end
  
  resources :orbits do
    resources :sections
  end

  resources :messages

  get "pages/contact"

  get "pages/help"
  
  get "pages/about"
  
  match 'jobs/say_when' => 'jobs#say_when'
  	match 'jobs/template' => 'jobs#template'
  	match 'contributions/:id/remove/:user_id' => 'contributions#remove'
  	match 'contributions/:id/removeowner/:user_id' => 'contributions#removeowner'
  	match 'contributions/:id/removereader/:user_id' => 'contributions#removereader'

	resources :jobs do
    	member do
  			get 'addpage'
			  post 'createpage'
			  get 'open'
  			get 'close'
  			get 'internaltimeout'
  			get 'remove'
  			get 'replication'
  			get 'invitations'
  			get 'search'
  			get 'skilltagcloudajax'
  			get 'duplicateSectionAjax'
  			get 'sharejob'
  			get 'getGroupUsersFromMyNetwork'
  		end
	end
  
  resources :monkeys
	resources :sharejob do
	     member do
	         get 'addtomytrail'
	     end
	end
	resources :jobversions

	match 'invitations/:id/accept' => 'invitations#accept'
	match 'invitations/:id/refuse' => 'invitations#refuse'
  match 'invitations/:job_id/remove/:id' => 'invitations#remove'
  match 'invitations/:id' => 'invitations#update'
	match 'jobs/invitations/create' => 'invitations#create'

	match 'profiles/settags' => 'profiles#settags'
  

	resources :invitations do
	  	member do
	    	post 'invite'
		end
	end

	resources :contributions do
    	member do
  			get 'remove'
  			get 'addtomynetwork'
  		end
  	end
  
  get "home/index"

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" } do
  	get "/" => "devise/sessions#new"
  	post "/" => "devise/sessions#create"
  end
  
  match 'user' => "users#show", :as => :user_root
  resources :users
  resources :profiles
  resources :accounts
  
 	match 'people/:id/mail' => 'people#mail'
 	match 'people/changegroup' => 'people#changegroup'
 	match 'people/addnewgroup' => 'people#addnewgroup'
 	match 'people/removegroup' => 'people#removegroup'
  match 'people/:id/jobs' => 'people#publicjobs'
  
  resources :people
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "home#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
