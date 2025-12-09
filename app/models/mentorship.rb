class Mentorship < ApplicationRecord
  belongs_to :account, default: -> { mentor.account }
  belongs_to :mentor, class_name: "User"
  belongs_to :teen, class_name: "User"

  enum :status, %w[ active completed paused ].index_by(&:itself), default: :active

  validate :mentor_capacity_not_exceeded, if: -> { active? && (new_record? || status_changed_to_active?) }
  validate :teen_has_only_one_active_mentorship, if: -> { active? && (new_record? || status_changed_to_active?) }

  scope :active, -> { where(status: :active) }

  private
    def mentor_capacity_not_exceeded
      active_count = mentor.mentorships_as_mentor.active.where.not(id: id).count
      if active_count >= mentor.mentor_capacity
        errors.add(:mentor, "has reached maximum capacity of #{mentor.mentor_capacity} active mentorships")
      end
    end

    def teen_has_only_one_active_mentorship
      if teen.mentorships_as_teen.active.where.not(id: id).exists?
        errors.add(:teen, "can only have one active mentorship")
      end
    end

    def status_changed_to_active?
      saved_change_to_status? && status == "active" && status_before_last_save != "active"
    end
end

