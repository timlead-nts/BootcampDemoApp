class CommentsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_post
  before_action :set_comment, only: :destroy

  def create
    @comment = @post.comments.build(comment_params)

    respond_to do |format|
      if @comment.save
        @post.reload
        format.html { redirect_to @post, notice: "Comment added." }
        format.turbo_stream
        format.json { render json: @comment, status: :created }
      else
        format.html { render "posts/show", status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(dom_id(@post, :comment_form), partial: "comments/form", locals: { comment: @comment, post: @post }), status: :unprocessable_entity
        end
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @comment.destroy
    @post.reload

    respond_to do |format|
      format.html { redirect_to @post, notice: "Comment removed.", status: :see_other }
      format.turbo_stream
      format.json { head :no_content }
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
