require 'rails_helper'

RSpec.feature 'Health check' do
  it 'Returns ok response' do
    visit '/_health'
    
    expect(page).to have_content 'All is well'
  end
end