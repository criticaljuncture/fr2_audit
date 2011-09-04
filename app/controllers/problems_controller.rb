class ProblemsController < ApplicationController
  def show
    @audit = Audit.find(params[:audit_id])
    @number = params[:id].to_i
    @problem = @audit.audit_problems[@number - 1]
  end
end
