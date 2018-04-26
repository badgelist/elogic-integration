require 'rails_helper'

RSpec.feature 'Settings pages' do
  include RSpec::Rails::ControllerExampleGroup

  let(:user) { create(:user) }

  scenario 'User views current settings' do
    manually_sign_in_user(user)
    expect(page).to have_link 'Sign out'

    expect(page).to have_link 'eLogic Integration Settings'
    click_link 'eLogic Integration Settings'
    
    expect(page).to have_link 'Modify Settings'

    SettingsController::AVAILABLE_SETTINGS.each do |setting_item|
      expect(page).to have_text setting_item[:label]
      expect(page).to have_css('#' + setting_item[:key].to_s)
      if (Setting[setting_item[:key]].present?)
        expect(page.find_by_id(setting_item[:key].to_s)).to have_text Setting[setting_item[:key]].to_s
      end
    end
  end

  scenario 'User changes settings' do
    manually_sign_in_user(user)
    expect(page).to have_link 'Sign out'

    expect(page).to have_link 'eLogic Integration Settings'
    click_link 'eLogic Integration Settings'
    
    expect(page).to have_link 'Modify Settings'
    click_link 'Modify Settings'
    expect(page).to have_button 'Save changes'

    SettingsController::AVAILABLE_SETTINGS.each do |setting_item|
      expect(page).to have_field setting_item[:label]
      current_value = Setting[setting_item[:key]].to_s
      expect(find_field(setting_item[:label]).value).to eq current_value
    end

    first_setting_item = SettingsController::AVAILABLE_SETTINGS.first
    current_value = Setting[first_setting_item[:key]].to_s
    new_value = current_value + '1'
    fill_in first_setting_item[:label], with: new_value
    click_button 'Save changes'

    expect(Setting[first_setting_item[:key]]).to eq new_value
  end

end