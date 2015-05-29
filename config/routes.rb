Heaven::Application.routes.draw do
  get  "/" => redirect(ENV["ROOT_REDIRECT_URL"] || "https://github.com/atmos/heaven")

  github_authenticate(:team => :employees) do
    mount Resque::Server.new, :at => "/resque"
  end

  post "/events" => "events#create"
end
