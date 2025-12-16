class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include ActionPolicy::Controller

  before_action :configure_permitted_parameters, if: :devise_controller?
  layout :layout_by_resource

  def dom_id(record)
    ActionView::RecordIdentifier.dom_id(record)
  end


  private

  def authorization_context
    super.merge(user: current_user.presence || nil)
  end

  def layout_by_resource
    devise_controller? ? "devise" : "application"
  end

  def configure_permitted_parameters
    added_keys = %i[first_name last_name username age]
    devise_parameter_sanitizer.permit(:sign_up, keys: added_keys)
    devise_parameter_sanitizer.permit(:account_update, keys: added_keys)
  end
end
