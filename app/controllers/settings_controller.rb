class SettingsController < ApplicationController

  before_action :require_login

  #=== CONSTANTS ===#

  # In order for these to display properly in the UI, order them in the exact order that you want them to show up.
  # Also include a section value for every setting, a header is included every time the section changes.
  AVAILABLE_SETTINGS = [
    { key: :elogic_wsdl_url, type: :text, section: 'eLogic Server', label: 'SOAP API WSDL URL' },
    { key: :elogic_api_token, type: :text, section: 'eLogic Server', label: 'SOAP API Token' },
    { key: :elogic_user_query_frequency, type: :number, section: 'eLogic Server', label: 'User Query Freqency', 
        help_text: 'How often to query for new users (in minutes)' }
  ]

  #=== ACTIONS ===#

  def show
    @sections = generate_sections
  end

  def edit
    @sections = generate_sections
  end

  def update
    @settings = generate_settings
    setting_params = params[:setting]

    @settings.each do |setting_item|
      if setting_params[setting_item[:key]] != setting_item[:value]
        Setting[setting_item[:key]] = setting_params[setting_item[:key]]
      end
    end

    flash[:success] = 'Settings updated successfully!'
    redirect_to settings_path
  end

private
  
  # Returns a flat settings list with the values injected
  def generate_settings
    return AVAILABLE_SETTINGS.map do |setting_item|
      setting_item.merge({
        value: Setting[setting_item[:key]]
      })
    end
  end

  # Returns a nested list of sections with the child settings underneath
  def generate_sections
    settings = generate_settings

    return settings.map do |setting_item| 
      setting_item[:section] 
    end.uniq.map do |section|
      {
        label: section,
        settings: settings.select{ |setting_item| setting_item[:section] == section }
      }
    end
  end

end
