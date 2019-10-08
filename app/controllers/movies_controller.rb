class MoviesController < ApplicationController
  protect_from_forgery except: :index
  skip_before_action :authenticate_user!, only: [:index]

  def index
    # if the id params is present
    if params[:query].present?
      @movies = Movie.search_by_title_and_plot(params[:query])
    elsif params[:id]
      @movies = Movie.where('id <?', params[:id]).limit(20)
      render json: { movies: render_to_string('movies/_movie', layout: false, locals: { movies: @movies }) }
    else
      @movies = Movie.limit(20)
    end
  end
end
