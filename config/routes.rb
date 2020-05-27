Rails.application.routes.draw do
    
  get  '/' => 'linebot#index'
  post '/callback' => 'linebot#callback'

end
