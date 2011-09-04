module AuditHelper
  def audit_type_name(class_name)
    t("audit_problems.types.#{class_name.sub(/^AuditProblem::/,'')}.name")
  end

  def audit_type_description(class_name)
    t("audit_problems.types.#{class_name.sub(/^AuditProblem::/,'')}.description").html_safe
  end

  def audit_field_name(field_name)
    t("audit_problems.fields.#{field_name}")
  end
end
