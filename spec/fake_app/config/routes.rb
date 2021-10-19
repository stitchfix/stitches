Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
namespace :api do
  scope module: :v1, constraints: Stitches::ApiVersionConstraint.new(1) do
    resource 'ping', only: [ :create ]
    resource 'hellos'
    # Add your V1 resources here
  end
  scope module: :v2, constraints: Stitches::ApiVersionConstraint.new(2) do
    resource 'ping', only: [ :create ]
    resource 'hellos'
    # This is here simply to validate that versioning is working
    # as well as for your client to be able to validate this as well.
  end
end

end
