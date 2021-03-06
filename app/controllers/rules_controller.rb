class RulesController < ApplicationController
  before_action :set_rule, only: [:show, :edit, :update, :destroy]

  # GET /rules
  # GET /rules.json
  def index
    @rules = Rule.all
  end

  # GET /rules/1
  # GET /rules/1.json
  def show
  end

  # GET /rules/new
  def new
    # Allow category_id to be specified as an optional param
    # Default field to payee
    @rule = Rule.new(params.permit(:category_id).merge({ field: 'payee' }))
  end

  # GET /rules/1/edit
  def edit
  end

  # POST /rules
  # POST /rules.json
  def create
    @rule = Rule.new(rule_params)

    respond_to do |format|
      if @rule.save
        format.html { redirect_to edit_category_path(id: @rule.category_id), notice: 'Rule was successfully created.' }
        format.json { render action: 'show', status: :created, location: @rule }
      else
        format.html { render action: 'new' }
        format.json { render json: @rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rules/1
  # PATCH/PUT /rules/1.json
  def update
    respond_to do |format|
      if @rule.update(rule_params)
        format.html { redirect_to edit_category_path(id: @rule.category_id), notice: 'Rule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rules/1
  # DELETE /rules/1.json
  def destroy
    @rule.destroy
    respond_to do |format|
      format.html { redirect_to edit_category_path(id: @rule.category_id) }
      format.json { head :no_content }
    end
  end

  private
    def set_rule
      @rule = Rule.find(params[:id])
    end

    # Never trusst parameters from the scary internet, only allow the white list through.
    def rule_params
      params.require(:rule).permit(:category_id, :field, :operator, :content)
    end
end
