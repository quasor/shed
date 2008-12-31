module IntervalsHelper
  def pretty_duration(interval)
    d = Duration.new(interval.end - interval.start)
    d.to_s.gsub(/(\d+)/,'<strong><span class="big">\1</span></strong>')
  end
end
