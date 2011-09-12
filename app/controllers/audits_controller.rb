class AuditsController < ApplicationController
  def index
    @audits_by_date = Audit.without(:audit_problems).asc(:completed_at).all.group_by{|a| a.completed_at.to_date}
    @audit_types = YAML.load_file(Rails.root.join('config','locales','en.yml'))['en']['audit_problems']['types'].keys
  end

  def show
    @audit = Audit.first(:conditions => {:_id => params[:id]})
  end

  def by_date
    @date = Date.parse("#{params[:year]}-#{params[:month]}-#{params[:day]}")
    @audits = Audit.where(:completed_at => {'$gte' => @date.beginning_of_day, '$lte' => @date.end_of_day})
  end
end
