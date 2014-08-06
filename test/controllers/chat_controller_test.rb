require 'test_helper'

class ChatControllerTest < ActionController::TestCase
  test "should get room" do
    get :room
    assert_response :success
  end

end
