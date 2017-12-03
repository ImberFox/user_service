require 'rails_helper'

RSpec.describe User, :type => :model do
  before :context do
    # p 'drgr'
    user = User.new(:name => "Name", :email => "Email@email.em", :password => "111")
    # p user.valid?
    # p user.errors.messages
    user.save
  end

  context "check user" do
    it "is not valid with valid attributes" do
      expect(User.new).to_not be_valid
    end


    it "is not valid without a name" do
      user = User.new(:email => 'sfe@gre.ru', :password => "srg")
      expect(user).to_not be_valid
      expect(user.errors.messages[:name][0]).to eq("Name can't be empty.")
    end

    it "is not valid without a email" do
      user = User.new(:name => 'gre', :password => "srg")
      expect(user).to_not be_valid
      expect(user.errors.messages[:email]).to eq(["Email can't be empty.",
      "is invalid"])
    end

    it "is not valid with incorrect email" do
      user = User.new(:name => 'gre', :email => 'sgre.ru', :password => "srg")
      expect(user).to_not be_valid
      expect(user.errors.messages[:email]).to eq(["is invalid"])
    end

    it "is not valid without password" do
      user = User.new(:name => 'gre', :email => 'serg@sgre.ru')
      expect(user).to_not be_valid
      expect(user.errors.messages[:password]).to eq(["Password can't be empty."])
    end

    it "is valid" do
      user = User.new(:name => 'gre', :email => 'serg@sgre.ru', :password => "sdg")
      expect(user).to be_valid
    end

    it "is not valid by uniquess name" do
      user = User.new(:name => "Name", :email => "email@sefe.em", :password=>"111")
      expect(user).to_not be_valid
      expect(user.errors.messages[:name]).to eq(["Name already occupied."])
    end

    it "is not valid by uniquess email" do
      user = User.new(:name => "me", :email => "Email@email.em", :password=>"111")
      expect(user).to_not be_valid
      expect(user.errors.messages[:email]).to eq(["Email already exists."])
    end
  end
end
