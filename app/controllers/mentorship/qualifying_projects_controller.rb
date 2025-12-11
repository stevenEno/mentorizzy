class Mentorship::QualifyingProjectsController < ApplicationController
  before_action :set_qualifying_project, only: %i[ show edit update submit approve reject ]
  before_action :ensure_teen_can_edit, only: %i[ edit update submit ]
  before_action :ensure_mentor_can_review, only: %i[ approve reject ]

  def index
    if Current.user.teen?
      @qualifying_projects = Current.user.qualifying_projects
        .includes(:reviewed_by)
        .order(created_at: :desc)
    else
      @qualifying_projects = Current.account.qualifying_projects
        .includes(:teen, :reviewed_by)
        .order(created_at: :desc)
    end
  end

  def show
  end

  def new
    ensure_teen_only
    @qualifying_project = QualifyingProject.new(teen: Current.user)
  end

  def create
    ensure_teen_only
    @qualifying_project = QualifyingProject.new(qualifying_project_params)
    @qualifying_project.teen = Current.user
    @qualifying_project.status = :in_progress

    if @qualifying_project.save
      redirect_to mentorship_qualifying_project_path(@qualifying_project), notice: "Qualifying project created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @qualifying_project.update(qualifying_project_params)
      redirect_to mentorship_qualifying_project_path(@qualifying_project), notice: "Qualifying project updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def submit
    @qualifying_project.update!(status: :submitted)
    redirect_to mentorship_qualifying_project_path(@qualifying_project), notice: "Project submitted for review"
  end

  def approve
    @qualifying_project.update!(
      status: :approved,
      reviewed_by: Current.user,
      reviewed_at: Time.current
    )
    redirect_to mentorship_qualifying_project_path(@qualifying_project), notice: "Project approved"
  end

  def reject
    @qualifying_project.update!(
      status: :rejected,
      reviewed_by: Current.user,
      reviewed_at: Time.current
    )
    redirect_to mentorship_qualifying_project_path(@qualifying_project), notice: "Project rejected"
  end

  private
    def set_qualifying_project
      if Current.user.teen?
        @qualifying_project = Current.user.qualifying_projects.find(params[:id])
      else
        @qualifying_project = Current.account.qualifying_projects.find(params[:id])
      end
    end

    def ensure_teen_only
      unless Current.user.teen?
        head :forbidden
      end
    end

    def ensure_teen_can_edit
      unless @qualifying_project.teen == Current.user
        head :forbidden
      end
    end

    def ensure_mentor_can_review
      unless Current.user.mentor? || Current.user.mentorship_role == "admin"
        head :forbidden
      end
    end

    def qualifying_project_params
      params.expect(qualifying_project: [ :title, :description, :submission_url, :feedback ])
    end
end

