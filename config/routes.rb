Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'home#index'
  resources :uploads, only: [ :new, :create ]
  get 'get-zip' => 'uploads#download_zip'
end
