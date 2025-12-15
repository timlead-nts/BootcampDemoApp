class PostPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.present?
  end

  alias_method :new?, :create?

  def update?
    owner?
  end

  alias_method :edit?, :update?

  def destroy?
    owner?
  end

  private

  def owner?
    logged_in? && (record.user_id == user.id || admin?)
  end
end
