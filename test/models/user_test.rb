require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "user without name" do
    user = User.new()
    assert !user.save
  end
end
