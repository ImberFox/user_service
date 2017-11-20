require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "get user" do
    post '/get_user/', params: { userName: 'abs' }
  end
end
