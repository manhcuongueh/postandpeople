Rails.application.routes.draw do
  root 'posts#index'

  get '/hashtag' => 'hashtags#index'
  post '/hashtag' => 'hashtags#count'

  get '/description' => 'descriptions#index'
  post '/description' => 'descriptions#count'

  post '/' => 'posts#crawl'
  delete '/:id' => 'posts#destroy'
  post '/posts/:id' => 'posts#posts_download'
  post '/people/:id' => 'posts#people_download'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
