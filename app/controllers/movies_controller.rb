class MoviesController < ApplicationController
  # def index
  #   @movies = Movie.all
  # end

  def index
    # if the id params is present
    if params[:id]
      # get all records with id less than 'our last id'
      # and limit the results to 5
      @movies = Movie.where('id < ?', params[:id]).limit(10)
    else
      @movies = Movie.limit(10)
    end
    respond_to do |format|
      format.html
      format.js
    end
  end
end
