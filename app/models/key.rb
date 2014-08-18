class Key < ActiveRecord::Base
  validates :username, uniqueness: true
  validates :username, :content, presence: true
end
