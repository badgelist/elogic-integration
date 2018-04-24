Rails.application.routes.draw do
  get '/_health', to: 'application#health'
end
