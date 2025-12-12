ruby
class MentorshipMatcher
    def initialize(teen, mentor)
        @teen = teen
        @mentor = mentor
    end

    def call
        return failure ('Teen is not qualified') unless @teen.eligible_for_mentorship?
        return failure ('Mentor has no capacity') unless @mentor.can_accept_mentee?

        mentorship = Mentorship.create!(
            teen: @teen,
            mentor: @mentor,
            status: :active
        )

        success (mentorship)
    rescue StandardError => e
        failure (e.message)
    end

    private
    def success(mentorship)
        {success: true, mentorship: mentiorship}
    end

    def failure(message)
        {success: false, error: message}
    end
end