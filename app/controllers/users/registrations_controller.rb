# frozen_string_literal: true
class Users::RegistrationsController < Devise::RegistrationsController
  def create
    build_resource(sign_up_params)
    resource.save
    yield resource if block_given?
    if resource.persisted?
      flash[:notice] = "Account created successfully. Please sign in."
      redirect_to new_user_session_path
    else
      clean_up_passwords resource
      set_minimum_password_length
      render :new, status: :unprocessable_content
    end
  end
end
