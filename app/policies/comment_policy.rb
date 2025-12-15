class CommentPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def destroy?
    return false unless logged_in?

    record.user_id == user.id || record.post.user_id == user.id || admin?
  end
end
