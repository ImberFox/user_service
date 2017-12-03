require 'rails_helper'


RSpec.describe User, :type => :model do
  it "is not valid with valid attributes" do
    expect(User.new).to_not be_valid
  end




  it "is not valid without a name" do
    user = User.new(:email => 'sfe@gre.ru', :password => "srg")
  end

  it "is not valid without a email" do
    user = User.new(:name => 'gre', :password => "srg")
  end

  it "is not valid with incorrect email" do
    user = User.new(:name => 'gre', :email => 'sgre.ru', :password => "srg")
  end

  it "is not valid without password" do
    user = User.new(:name => 'gre', :email => 'serg@sgre.ru')
  end

  it "is valid" do
    user = User.new(:name => 'gre', :email => 'serg@sgre.ru', :password => "sdg")
  end

  it "is not valid by uniquess name" do
  end

  it "is not valid by uniquess email" do
    
  end
end
