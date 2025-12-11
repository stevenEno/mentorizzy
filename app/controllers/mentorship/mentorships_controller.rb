class Mentorship::MentorshipsController < ApplicationController
  before_action :set_mentorship, only: %i[ destroy complete pause resume ]

  def dashboard
    if Current.user.mentor?
      @active_mentorships = Current.user.mentorships_as_mentor.active.includes(:teen)
      @active_count = @active_mentorships.count
      @capacity = Current.user.mentor_capacity
      @available_capacity = @capacity - @active_count
    elsif Current.user.teen?
      @active_mentorship = Current.user.mentorships_as_teen.active.first
      @qualifying_projects = Current.user.qualifying_projects.includes(:reviewed_by).order(created_at: :desc)
    end
  end

  def index
    @mentorships = Current.user.mentorships_as_mentor.or(Current.user.mentorships_as_teen)
      .includes(:mentor, :teen)
      .order(created_at: :desc)
  end

  def create
    @mentorship = Mentorship.new(mentorship_params)

    if @mentorship.save
      redirect_to mentorship_mentorships_path, notice: "Mentorship established"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @mentorship.destroy!
    redirect_to mentorship_mentorships_path, notice: "Mentorship ended"
  end

  def complete
    @mentorship.update!(status: :completed)
    redirect_to mentorship_mentorships_path, notice: "Mentorship completed"
  end

  def pause
    @mentorship.update!(status: :paused)
    redirect_to mentorship_mentorships_path, notice: "Mentorship paused"
  end

  def resume
    @mentorship.update!(status: :active)
    redirect_to mentorship_mentorships_path, notice: "Mentorship resumed"
  end

  private
    def set_mentorship
      @mentorship = Current.account.mentorships.find(params[:id])
      ensure_mentorship_access
    end

    def ensure_mentorship_access
      unless @mentorship.mentor == Current.user || @mentorship.teen == Current.user
        head :forbidden
      end
    end

    def mentorship_params
      params.expect(mentorship: [ :teen_id, :mentor_id ])
    end
end

