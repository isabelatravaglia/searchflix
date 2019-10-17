class MoviesController < ApplicationController
  protect_from_forgery except: :index
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    if params[:query].present?
      @movies = Movie.search_by_title_and_plot(params[:query])
    elsif params[:id]
      @movies = Movie.where('id <?', params[:id]).limit(20)
      render json: { movies: render_to_string('movies/_movie', layout: false, locals: { movies: @movies }) }
    else
      @movies = Movie.limit(20)
    end
  end

  def show
    @movie = Movie.find(params[:id])
    @movies = Movie.search_by_title_and_plot(params[:query])
  end
end
