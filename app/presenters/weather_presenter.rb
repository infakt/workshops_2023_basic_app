class WeatherPresenter
  attr_reader :description, :temperature, :icon

  def initialize(data)
    @data = data
    @description = data['current']['condition']['text']
    @temperature = data['current']['temp_c']
    @icon = data['current']['condition']['icon']
  end
  
  def nice_weather?
    @description == 'Sunny' || @description == 'Partly cloudy'
  end

  def good_to_read_outside?
    nice_weather? && temperature > 15
  end

  def encourage_text
    if good_to_read_outside?
      "Get some snacks and go read a book in a park!"
    else
      "It's always a good weather to read a book!"
    end
  end

  def description
    data['current']['condition']['text']
  end

  def temperature
    data['current']['temp_c']
  end

  def icon
    data['current']['condition']['icon']
  end

  def location
    data['location']['name']
  end

  private

  attr_reader :data

  def nice_weather?
    description == 'Sunny' || 'Partly cloudy'
  end

  def good_to_read_outside?
    nice_weather? && temperature > 15
  end
end
