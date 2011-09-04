module ApplicationHelper
  def partial_exists?(partial_name)
    File.exists?(Rails.root.join("app", "views", params[:controller], "_#{partial_name}.html.erb"))
  end
end
