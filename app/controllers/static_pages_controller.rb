class StaticPagesController < ApplicationController

  def code_of_conduct
  end

  def details
  end

  def home
  end

  def accessibility
  end

  private

  def home_page?
    params[:action] == "home"
  end
end
