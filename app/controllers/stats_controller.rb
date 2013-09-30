class StatsController < ApplicationController

  # GET /stats
  # GET /stats.json
  def index
    #month_clause = 'DATE(DATE_FORMAT(date, "%Y-%m-01"))'
    exclude_category = Category.find_by_name('Excluded')
    @stats = Transaction.includes(:category).where.not(category_id: exclude_category.id)
    #@stats = @stats.group(:category_id, month_clause).sum(:amount).order("#{month_clause} ASC")
    @stats = @stats.select('category_id, DATE(DATE_FORMAT(date, "%Y-%m-01")) AS month, SUM(amount) AS total')
    @stats = @stats.group(:category_id, :month).order('month ASC')

    @categories = @stats.map { |s| s.category }.uniq.sort { |a,b|
      (a.nil? ? '' : a.name) <=> (b.nil? ? '' : b.name)
    }
    @months = @stats.map { |s| s.month }.uniq.sort
    idx_by_category = Hash[@categories.each_with_index.map { |c,i| [c, i] }]
    idx_by_month = Hash[@months.each_with_index.map { |m,i| [m, i] }]

    # Rows are categories, columns are months
    @table = @categories.map { |m| @months.map { |c| 0 } }

    @stats.each do |s|
      @table[idx_by_category[s.category]][idx_by_month[s.month]] = s.total
    end

    @date_ranges = @months.map { |m| { date_start: m, date_end: m.end_of_month } }
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def stat_params
      params[:stat]
    end
end
