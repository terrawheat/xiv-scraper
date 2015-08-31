Rails.application.routes.draw do

  resources :items

  root 'index#index'
end
