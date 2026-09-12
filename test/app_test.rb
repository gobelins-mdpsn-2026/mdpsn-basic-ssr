ENV["RACK_ENV"] = "test"
require "minitest/autorun"
require "rack/test"
require_relative "../app"

class TodoAppTest < Minitest::Test
  include Rack::Test::Methods

  def app = TodoApp

  def setup
    DB[:todos].delete
  end

  def test_empty_list
    get "/"
    assert last_response.ok?
    assert_includes last_response.body, "Rien ici."
  end

  def test_add_redirects_then_shows_todo
    post "/todos", title: "Acheter du pain"
    assert_includes [302, 303], last_response.status
    follow_redirect!
    assert_includes last_response.body, "Acheter du pain"
    assert_includes last_response.body, "1 à faire"
  end

  def test_blank_title_is_ignored
    post "/todos", title: "   "
    assert_equal 0, DB[:todos].count
  end

  def test_toggle_and_filter
    id = DB[:todos].insert(title: "Lire", created_at: Time.now)
    post "/todos/#{id}/toggle"
    assert_equal true, DB[:todos].first[:done]
    get "/?filter=active"
    refute_includes last_response.body, "Lire"
    get "/?filter=done"
    assert_includes last_response.body, "Lire"
  end

  def test_delete
    id = DB[:todos].insert(title: "Vieux", created_at: Time.now)
    post "/todos/#{id}/delete"
    assert_equal 0, DB[:todos].count
  end

  def test_clear_done
    DB[:todos].insert(title: "A", done: true, created_at: Time.now)
    DB[:todos].insert(title: "B", done: false, created_at: Time.now)
    post "/todos/clear-done"
    assert_equal ["B"], DB[:todos].select_map(:title)
  end

  def test_title_is_escaped
    DB[:todos].insert(title: "<b>x</b>", created_at: Time.now)
    get "/"
    assert_includes last_response.body, "&lt;b&gt;x&lt;/b&gt;"
  end

  def test_healthz
    get "/healthz"
    assert last_response.ok?
    assert_equal '{"status":"ok"}', last_response.body
  end
end
