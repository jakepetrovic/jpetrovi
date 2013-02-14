class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index

    # Want to check if we have saved data or settings. If it's nil then it's not
    # saved. If it's saved then we're redirecting to the path with the saved
    # settings
    if params[:sort].nil? && params[:ratings].nil? &&
        (!session[:sort].nil? || !session[:ratings].nil?)
      redirect_to movies_path(:sort => session[:sort], :ratings => session[:ratings])
    end

    # Setting the variables equal to what's available (params).
    @sort = params[:sort]
    @ratings = params[:ratings]

    # If there aren't ratings, then we by default want to populate it with all the
    # ratings. Other wise if there are ratings already in there sorted a certain way,
    # then we want to save them to the hash.
    if @ratings.nil?
      ratings = Movie.ratings
    else
      ratings = @ratings.keys
    end

    #In here we're just getting all the ratings into a variable so we can
    # iterate through it a little later. We want to be current with what the
    # user has selected.
    @all_ratings = Movie.ratings.inject(Hash.new) do |all_ratings, rating|
          all_ratings[rating] = @ratings.nil? ? false : @ratings.has_key?(rating)
          all_ratings
      end

    # Check if the sort is active, then we sort if it's not null(active).
    # We iterate through all the movies and sort them all and iterate through each
    # rating.
    # If we don't want to sort, then we're just getting all the ratings
    # normally.
    if !@sort.nil?
      begin
        @movies = Movie.order("#{@sort}").find_all_by_rating(ratings)
      end
    else
      @movies = Movie.find_all_by_rating(ratings)
    end

    #Save the sort and ratings
    session[:sort] = @sort
    session[:ratings] = @ratings
  end

  def new
    # default: render 'new' template
  end

  def hilite_class(search, field)
    if search.sorts.detect {|s| s.name == field.to_s}.present?
      then {:class => 'hilite'}
    end
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
