class QualifyingProject < ApplicationRecord
  belongs_to :account, default: -> { teen.account }
  belongs_to :teen, class_name: "User"
  belongs_to :reviewed_by, class_name: "User", optional: true

  enum :status, %w[ not_started in_progress submitted approved rejected ].index_by(&:itself), default: :not_started

  validates :title, presence: true
  validates :description, presence: true
  validates :teen_id, presence: true

  scope :by_status, ->(status) { where(status: status) }
end

