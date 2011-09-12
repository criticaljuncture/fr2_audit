class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate

  private

  def authenticate
    authenticate_or_request_with_http_digest do |username|
      self.class.valid_users[username]
    end
  end

  def self.valid_users
    @valid_users ||= YAML.load_file(Rails.root.join('config', 'secrets.yml'))['users']
  end
end
