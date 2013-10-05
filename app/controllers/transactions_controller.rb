class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :edit, :update, :destroy]

  # GET /transactions
  # GET /transactions.json
  def index
    filter_params = params.permit(:category_id, :date_start, :date_end)
    sort_params = params.permit(:sort)
    if filter_params
      @transactions = Transaction
      if filter_params[:category_id]
        @transactions = @transactions.where(category_id: filter_params[:category_id])
      end
      date_start, date_end = filter_params[:date_start], filter_params[:date_end]
      if date_start and date_end
        puts date_end
        @transactions = @transactions.where(date: Date.parse(date_start)..Date.parse(date_end))
      end
    else
      @transactions = Transaction.all
    end
    sort_by = sort_params[:sort] || 'payee'
    if sort_by.present?
      if sort_by.start_with? '-'
        sort_by = sort_by[1..-1]
        direction = 'DESC'
      else
        direction = 'ASC'
      end
      if %w{amount category date payee type}.include? sort_by
        @transactions = @transactions.order("#{sort_by} #{direction}")
      end
    end
  end

  # GET /transactions/1
  # GET /transactions/1.json
  def show
  end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
  end

  # GET /transactions/1/edit
  def edit
  end

  # POST /transactions
  # POST /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to @transaction, notice: 'Transaction was successfully created.' }
        format.json { render action: 'show', status: :created, location: @transaction }
      else
        format.html { render action: 'new' }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transactions/1
  # PATCH/PUT /transactions/1.json
  def update
    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html { redirect_to @transaction, notice: 'Transaction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.json
  def destroy
    @transaction.destroy
    respond_to do |format|
      format.html { redirect_to transactions_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transaction_params
      params[:transaction]
    end
end
