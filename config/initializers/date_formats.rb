my_formats = {
  :cal_picker_datetime => '%B %d, %Y %I:%M %p',
  :cal_picker_date => '%B %d, %Y',
  :month_only => '%B',
  :mdy_time => '%m-%d-%y %I:%M %p',
  :forum_datetime => '%a %b %d, %Y %I:%M %p',
  :compact => '%b %d, %Y',
  :cache => '%j%H%M%S',
  :mdy => '%m/%d/%Y'
}

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(my_formats)
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(my_formats)