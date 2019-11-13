class Hashtag < ApplicationRecord
    has_many :persons
    has_many :posts
end
