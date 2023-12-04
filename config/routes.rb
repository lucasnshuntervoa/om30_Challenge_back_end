# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :citizens, only: %i[index show update create]
    end
  end
end
