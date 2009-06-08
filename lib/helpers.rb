helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def content(name)
    @content_variables ? @content_variables[name] : ''
  end

  def content_for(name, content)
    @content_variables ||= {}
    @content_variables[name] = content
  end

  def partial(name)
    erb name, :layout => false
  end

  def parts(name)
    __send__("parts_" + name.to_s)
  end

  def atom_time(date)
    date.strftime("%Y-%m-%dT%H:%M:%SZ")
  end
end
