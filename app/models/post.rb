class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_one_attached :cover

  validates :title, presence: true
  validates :content, presence: true, length: { minimum: 10 }
end
