# Base class for application policies
class ApplicationPolicy < ActionPolicy::Base
  authorize :user, optional: true

  private

  def logged_in?
    user.present?
  end

  def admin?
    user.respond_to?(:admin?) && user.admin?
  end
end
