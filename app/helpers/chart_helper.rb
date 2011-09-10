module ChartHelper
  def year_distribution_sparkline(audit, options = {})
    starting_year = 1994
    current_year = Date.current.year

    year_counts = year_distribution(audit,starting_year..current_year)
    Gchart.line(
      :data => year_counts,
      :size => '300x50',
      :line_colors => 'E4A529', #'0069D6',
      :axis_with_labels => 'x,y',
      :axis_labels => [
        [starting_year, (starting_year+current_year)/2, current_year],
        [0,year_counts.max]
      ]
     )
  end

  def year_distribution_chart(audit, options = {})
    starting_year = 1994
    current_year = Date.current.year

    year_counts = year_distribution(audit,starting_year..current_year)
    max = year_counts.max
    Gchart.bar(
      :data => year_counts,
      :size => '600x200',
      :line_colors => 'E4A529', #'0069D6',
      :axis_with_labels => 'x,y',
      :axis_labels => [
        (starting_year .. current_year).map{|i| i.to_s.sub(/^\d\d/,"'")},
        [0, max / 4, max / 2, (max / 4) * 3, max]
      ]
     )
  end

  private

  def year_distribution(audit, range)
    audit.problem_counts_by_year.values_at(*range.to_a.map(&:to_s))
  end
end
