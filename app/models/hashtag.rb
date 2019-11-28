class Hashtag < ApplicationRecord
    has_many :persons, dependent: :destroy
    has_many :posts, dependent: :destroy
end
