class Article
  include Mongoid::Document

  belongs_to :user
  belongs_to :book
end
