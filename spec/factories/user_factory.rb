FactoryBot.define do

  sequence :email do |n|
    "user#{n}@example.com"
  end
  
  factory :user do
    name 'Jane Lee'
    email
    password 'validPassword123'
  end
  
end