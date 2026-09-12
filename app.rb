require "sinatra/base"
require_relative "db"

# Every route below answers one HTTP request with one full HTML page (or a
# redirect that makes the browser ask for one). No JavaScript involved.
class TodoApp < Sinatra::Base
  set :views, File.join(__dir__, "views")
  set :public_folder, File.join(__dir__, "public")

  FILTERS = %w[all active done].freeze

  # GET / — render the list. ?filter=active|done narrows it.
  get "/" do
    @filter = FILTERS.include?(params[:filter]) ? params[:filter] : "all"
    scope = DB[:todos]
    scope = scope.where(done: false) if @filter == "active"
    scope = scope.where(done: true) if @filter == "done"
    @todos = scope.order(:created_at, :id).all
    @remaining = DB[:todos].where(done: false).count
    @rendered_at = Time.now
    erb :index
  end

  # POST /todos — the <form> on the page submits here, then we redirect to GET /.
  # That redirect is what makes "refresh" safe: the browser re-asks for the page
  # instead of re-sending the form.
  post "/todos" do
    title = params[:title].to_s.strip
    DB[:todos].insert(title: title, created_at: Time.now) unless title.empty?
    redirect "/"
  end

  post "/todos/:id/toggle" do
    DB[:todos].where(id: params[:id].to_i).update(done: Sequel.~(:done))
    redirect back_to_list
  end

  post "/todos/:id/delete" do
    DB[:todos].where(id: params[:id].to_i).delete
    redirect back_to_list
  end

  post "/todos/clear-done" do
    DB[:todos].where(done: true).delete
    redirect back_to_list
  end

  get "/healthz" do
    DB.test_connection
    content_type :json
    '{"status":"ok"}'
  end

  private

  # Keep the current filter across a redirect: the form carries it as a hidden field.
  def back_to_list
    filter = params[:filter].to_s
    FILTERS.include?(filter) && filter != "all" ? "/?filter=#{filter}" : "/"
  end
end
