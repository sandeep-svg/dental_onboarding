# frozen_string_literal: true
class OnboardingController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_candidate_profile, only: [:review, :save_profile]
  before_action :redirect_if_completed, only: [:upload_cv]

  def upload_cv
    @profile = current_user.candidate_profile || current_user.build_candidate_profile
  end

  def process_cv
    @profile = current_user.candidate_profile || current_user.build_candidate_profile

    unless params[:file].present?
      flash.now[:alert] = "Please select a file to upload"
      return render :upload_cv, status: :unprocessable_content
    end

    file = params[:file]

    unless CandidateDocument::ALLOWED_CONTENT_TYPES.include?(file.content_type)
      flash.now[:alert] = "Unsupported file type. Please upload a PDF, DOC, or DOCX file."
      return render :upload_cv, status: :unprocessable_content
    end

    max_size = ENV.fetch("MAX_CV_SIZE_MB", 25).to_i.megabytes
    if file.size > max_size
      flash.now[:alert] = "File is too large. Maximum size is #{max_size / 1.megabyte} MB."
      return render :upload_cv, status: :unprocessable_content
    end

    document = @profile.candidate_documents.build(
      original_filename: file.original_filename,
      content_type: file.content_type,
      file_size: file.size,
      parsing_status: "pending"
    )
    document.file.attach(file)

    if document.save
      @profile.update!(parsing_status: "processing")
      ParseCandidateCvJob.perform_later(document.id)
      redirect_to onboarding_review_path, notice: "CV uploaded successfully. We're extracting your information..."
    else
      flash.now[:alert] = "Could not save the file. Please try again."
      render :upload_cv, status: :unprocessable_content
    end
  end

  def parsing_status
    document = current_user.candidate_profile&.candidate_documents&.last
    render json: {
      status: document&.parsing_status || "none",
      parsed_at: document&.parsed_at
    }
  end

  def review
    @document = @profile.candidate_documents.last
  end

  def save_profile
    @document = @profile.candidate_documents.last
    @profile.assign_attributes(profile_params)
    was_completed = @profile.onboarding_completed?

    if @profile.save(context: :final_save)
      @profile.sync_skills(params[:candidate_profile][:skill_ids])
      @profile.sync_languages(params[:candidate_profile][:languages])
      @profile.update(onboarding_completed: true, parsing_status: "completed")
      AdminNotificationJob.perform_later(@profile.id) unless was_completed
      redirect_to authenticated_root_path, notice: "Profile saved successfully!"
    else
      flash.now[:alert] = "Please fix the errors below."
      render :review, status: :unprocessable_content
    end
  end

  def retry_parsing
    @profile = current_user.candidate_profile
    document = @profile&.candidate_documents&.last
    if document && document.parsing_status == "failed"
      document.update!(parsing_status: "pending")
      @profile.update!(parsing_status: "processing")
      ParseCandidateCvJob.perform_later(document.id)
      redirect_to onboarding_review_path, notice: "Retrying CV parsing..."
    else
      redirect_to onboarding_upload_cv_path, alert: "No failed CV to retry."
    end
  end

  def continue_manual
    @profile = current_user.candidate_profile || current_user.create_candidate_profile!
    redirect_to onboarding_review_path
  end

  private

  def ensure_candidate_profile
    @profile = current_user.candidate_profile
    unless @profile
      redirect_to onboarding_upload_cv_path, notice: "Please upload your CV or continue manually."
    end
  end

  def redirect_if_completed
    if current_user.candidate_profile&.onboarding_completed?
      redirect_to authenticated_root_path, notice: "You have already completed the onboarding."
    end
  end

  def profile_params
    params.require(:candidate_profile).permit(
      :first_name, :last_name, :email, :phone_number, :city, :country,
      :desired_job_function_id, :max_travel_time,
      :search_status, :reason_for_looking,
      :desired_gross_salary, :desired_percentage,
      :average_daily_revenue, :big_registration_status, :big_number,
      :years_of_experience, :available_from,
      :notice_period, :motivation, :internal_notes, :professional_summary,
      :consent_accepted,
      preferred_regions: [],
      desired_employment_type: [],
      available_working_days: [],
      transport_type: [],
      skill_ids: [],
      educations_attributes: [:id, :institution, :study, :city_country, :level,
        :start_date, :end_date, :_destroy],
      work_experiences_attributes: [:id, :job_title, :company_name, :responsibilities,
        :start_date, :end_date, :current_job, :_destroy]
    )
  end
end
