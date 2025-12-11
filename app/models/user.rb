class User < ApplicationRecord
  include Accessor, Assignee, Attachable, Avatar, Configurable, EmailAddressChangeable,
    Mentionable, Named, Notifiable, Role, Searcher, Watcher
  include Timelined # Depends on Accessor

  belongs_to :account
  belongs_to :identity, optional: true

  enum :mentorship_role, { teen: 0, mentor: 1, admin: 2 }, default: :teen
  enum :qualification_status, { unqualified: 0, in_progress: 1, qualified: 2 }, default: :unqualified

  has_many :comments, inverse_of: :creator, dependent: :destroy

  has_many :filters, foreign_key: :creator_id, inverse_of: :creator, dependent: :destroy
  has_many :closures, dependent: :nullify
  has_many :pins, dependent: :destroy
  has_many :pinned_cards, through: :pins, source: :card
  has_many :exports, class_name: "Account::Export", dependent: :destroy
  has_many :mentorships_as_mentor, class_name: "Mentorship", foreign_key: :mentor_id, dependent: :destroy
  has_many :mentorships_as_teen, class_name: "Mentorship", foreign_key: :teen_id, dependent: :destroy
  has_many :qualifying_projects, foreign_key: :teen_id, dependent: :destroy
  has_many :reviewed_qualifying_projects, class_name: "QualifyingProject", foreign_key: :reviewed_by_id, dependent: :nullify

  scope :with_avatars, -> { preload(:account, :avatar_attachment) }

  def deactivate
    transaction do
      accesses.destroy_all
      update! active: false, identity: nil
      close_remote_connections
    end
  end

  def setup?
    name != identity.email_address
  end

  def verified?
    verified_at.present?
  end

  def verify
    update!(verified_at: Time.current) unless verified?
  end

  private
    def close_remote_connections
      ActionCable.server.remote_connections.where(current_user: self).disconnect(reconnect: false)
    end
end
