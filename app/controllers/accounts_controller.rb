class AccountsController < ApplicationController
  #before_action :set_account, only: [:show]

  # GET /accounts
  # GET /accounts.json
  def index
    @accounts = Account.all
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
    @account = Account.includes(transactions: :category).find(params[:id])
  end

  private
    def set_account
      @account = Account.find(params[:id])
    end

    def account_params
      params[:account]
    end
end
