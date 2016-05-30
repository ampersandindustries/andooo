module UsersHelper
  def user_gravatar(user, size = 20)
    image_tag user.gravatar_url(size), {
      alt:   user.username,
      title: user.username,
      class: "icon-#{size}" }
  end

  def short_transit(transit)
    if transit == "I will be taking the free shuttle leaving downtown San Francisco on FRIDAY, August 12th at 3pm"
      "Friday Shuttle"
    elsif transit == "I will be taking the free shuttle leaving St. Dorothy's Rest on SUNDAY, August 14th at 8pm, returning to downtown San Francisco"
      "Sunday Shuttle"
    elsif transit == "I will be taking the free shuttle leaving St. Dorothy's Rest on MONDAY, August 15th at 10am, returning to downtown San Francisco"
      "Monday Shuttle"
    else
      "Driving or Carpooling"
    end
  end

  def dietary_restrictions_as_array(diet)
    diet.gsub(/[\[\]\"]/, "").split(",")
  end
end
