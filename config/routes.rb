Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :documents, only: %i(index show update create) do
        resources :lines, only: %i(index update show create)
      end
    end
  end
end
