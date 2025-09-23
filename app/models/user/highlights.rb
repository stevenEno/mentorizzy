module User::Highlights
  extend ActiveSupport::Concern

  class_methods do
    def generate_all_weekly_highlights_later
      User::Highlights::GenerateAllJob.perform_later
    end

    def generate_all_weekly_highlights
      # We're not interested in parallelizing individual generation. Better for AI quota limits and, also,
      # most summaries will be reused for users accessing the same collections.
      active.find_each(&:generate_weekly_highlights)
    end
  end

  def generate_weekly_highlights(date = Time.current)
    in_time_zone do
      date = date - 1.day if date.sunday?
      PeriodHighlights.create_or_find_for collections, starts_at: highlights_starts_at(date), duration: 1.week
    end
  end

  def weekly_highlights_for(date)
    in_time_zone do
      PeriodHighlights.for(collections, starts_at: highlights_starts_at(date), duration: 1.week)
    end
  end

  private
    def highlights_starts_at(date = Time.current)
      date = date.in_time_zone(timezone)
      date.beginning_of_week(:sunday)
    end
end
