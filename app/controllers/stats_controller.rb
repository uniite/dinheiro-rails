class StatsController < ApplicationController

  # GET /stats
  # GET /stats.json
  def index
    # Compile a list of categories that are children of the "Excluded" category
    categories = Category.all
    excluded = Category.find_by_name('Excluded')
    income = Category.find_by_name('Income')
    excluded_categories = categories.select { |c| [excluded, income].include? c.top_level }
    income_categories = categories.select { |c| c.top_level == income }

    # Get all the transactions that aren't in the excluded categories
    @stats = Transaction.includes(:category).where.not(['category_id in (?)', excluded_categories])
    #@stats = @stats.group(:category_id, month_clause).sum(:amount).order("#{month_clause} ASC")
    # Get the total amounts for each category in these transactions, by month
    # The items in stats end up being variations of the Transaction model, with category, total, and month
    @stats = @stats.select('category_id, DATE(DATE_FORMAT(date, "%Y-%m-01")) AS month, SUM(amount) AS total')
    # TODO: There seems to be a bug in ActiveRecord that comes up with you use 'month ASC' for the order
    @stats = @stats.group(:category_id, :month).order('month, category_id')

    # Separate out income into a separate data set
    @incomes = Transaction.select('category_id, DATE(DATE_FORMAT(date, "%Y-%m-01")) AS month, SUM(amount) AS total')\
                          .where(['category_id in (?)', income_categories])\
                          .group(:month)\
                          .order('month ASC')
    @income_by_month = {}
    @incomes.each do |i|
      @income_by_month[i.month] ||= 0
      @income_by_month[i.month] += i.total
    end
    @stats.reject! { |s| s.category == income }

    # Further sum/group them by top-level category if the top_level param is given
    if stat_params[:top_level].present?
      @top_level = true
      # Basically, map-reduce them into a hash
      revised_stats = {}
      @stats.each do |s|
        # Map to top-level category and month
        s.category = s.category.top_level
        key = [s.category, s.month]
        # Reduce
        if revised_stats[key].present?
          revised_stats[key].total += s.total
        else
          revised_stats[key] = s
        end
      end
      # Then, collapse them back into a list of Transaction instances
      @stats = revised_stats.values
    end

    # Sort the categories by name
    @categories = @stats.map { |s| s.category }.uniq.sort { |a,b|
      (a.nil? ? '' : a.name.downcase) <=> (b.nil? ? '' : b.name.downcase)
    }
    # Sort the months
    @months = @stats.map { |s| s.month }.uniq.sort
    # Index them for easy lookup while rendering the table
    idx_by_category = Hash[@categories.each_with_index.map { |c,i| [c, i] }]
    idx_by_month = Hash[@months.each_with_index.map { |m,i| [m, i] }]

    # Populate the table data (rows are categories, columns are months)
    @table = @categories.map { |m| @months.map { |c| 0 } }
    @stats.each do |s|
      @table[idx_by_category[s.category]][idx_by_month[s.month]] = s.total
    end

    # Pre-calculate date ranges for linking to TransactionsConttroller#index
    @date_ranges = @months.map { |m| { date_start: m, date_end: m.end_of_month } }
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def stat_params
      params.permit(:top_level)
    end
end
