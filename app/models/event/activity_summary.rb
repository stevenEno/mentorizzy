class Event::ActivitySummary < ApplicationRecord
  validates :key, :contents, presence: true

  after_create_commit :broadcast_activity_summarized

  class << self
    def create_for(events)
      summary = Event::Summarizer.new(events).summarize
      key = key_for(events)

      unless find_by key: key
        create!(key: key, content: summary)
      end
    end

    def for(events)
      find_by key: key_for(events)
    end

    def key_for(events)
      Digest::SHA256.hexdigest(events.ids.sort.join("-"))
    end
  end

  def to_html
    renderer = Redcarpet::Render::HTML.new
    markdowner = Redcarpet::Markdown.new(renderer, autolink: true, tables: true, fenced_code_blocks: true, strikethrough: true, superscript: true,)
    markdowner.render(content).html_safe
  end

  private
    def broadcast_activity_summarized
      broadcast_replace_later_to :activity_summaries, target: key, partial: "events/day_timeline/activity_summary", locals: { summary: self }
    end
end
