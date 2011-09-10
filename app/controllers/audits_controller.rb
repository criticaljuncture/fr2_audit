class AuditsController < ApplicationController
  def index
    @audits = Audit.without(:audit_problems).all
  end

  def show
    @audit = Audit.first(:conditions => {:_id => params[:id]})
  end

  def by_date
  end
end
