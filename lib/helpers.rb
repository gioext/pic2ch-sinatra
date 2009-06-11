helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def content(name)
    @content_variables ? @content_variables[name] : ''
  end

  def content_for(name, content)
    @content_variables ||= {}
    if @content_variables[name]
      @content_variables[name] += content
    else
      @content_variables[name] = content
    end
  end

  def partial(name)
    sym = ("_" + name.to_s).to_sym
    erb sym, :layout => false
  end

  def parts(name)
    __send__("parts_" + name.to_s)
  end

  def atom_time(date)
    date.getgm.strftime("%Y-%m-%dT%H:%M:%SZ")
  end
end
