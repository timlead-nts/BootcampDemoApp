class CommentsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :authenticate_user!
  before_action :set_post
  before_action :set_comment, only: :destroy

  def create
    @comment = @post.comments.build(comment_params.merge(user: current_user))
    authorize! @comment

    respond_to do |format|
      if @comment.save
        @post.reload
        format.html { redirect_to @post, notice: "Comment added." }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend("flash_container", partial: "shared/flash", locals: { flash: { notice: "Comment added." } }),
            turbo_stream.remove("comments_empty_state"),
            turbo_stream.prepend("comments", partial: "comments/comment", locals: { comment: @comment }),
            turbo_stream.replace(dom_id(@post, :comment_count), partial: "comments/count_badge", locals: { post: @post }),
            turbo_stream.update(dom_id(@post, :comment_form), partial: "comments/form", locals: { comment: Comment.new, post: @post })
          ]
        end
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
    authorize! @comment
    @comment.destroy
    @post.reload

    respond_to do |format|
      format.html { redirect_to @post, notice: "Comment removed.", status: :see_other }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.prepend("flash_container", partial: "shared/flash", locals: { flash: { notice: "Comment removed." } }),
          turbo_stream.remove(dom_id(@comment)),
          turbo_stream.replace(dom_id(@post, :comment_count), partial: "comments/count_badge", locals: { post: @post }),
          (@post.comments.exists? ? nil : turbo_stream.append("comments") do
            view_context.render(inline: '<div id="comments_empty_state" class="rounded-2xl border border-dashed border-slate-300 bg-white px-6 py-8 text-center shadow-sm shadow-sky-50"><p class="text-lg font-semibold text-slate-900">No comments yet</p><p class="mt-2 text-sm text-slate-600">Be the first to drop feedback or encouragement.</p></div>')
          end)
        ].compact
      end
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
