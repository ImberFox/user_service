class AddTokensToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :accessToken, :string
    add_column :users, :refreshToken, :string
    add_column :users, :created, :datetime
    add_column :users, :life, :integer
  end
end
