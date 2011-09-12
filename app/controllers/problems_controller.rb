class ProblemsController < ApplicationController
  def show
    @number = params[:id].to_i
    @audit = Audit.all(:fields => {
                :audit_problems => {"$slice" => [@number - 1, 1]},
                :type => true,
                :problem_count => true,
                :started_at => true}).find(params[:audit_id])
    @problem = @audit.audit_problems.first
  end
end
