module MentorshipHelper
  def project_status_class(status)
    case status
    when "approved"
      "txt-positive font-weight-bold"
    when "rejected"
      "txt-negative font-weight-bold"
    when "submitted"
      "txt-warning font-weight-bold"
    when "in_progress"
      "txt-subtle"
    else
      "txt-subtle"
    end
  end
end

