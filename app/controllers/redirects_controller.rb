# frozen_string_literal: true

class RedirectsController < ApplicationController
  respond_to :html, :mobile

  def redirect
    if user_signed_in?
      redirect_to edit_user_path
    else
      redirect_to new_user_session_path
    end
  end
end
