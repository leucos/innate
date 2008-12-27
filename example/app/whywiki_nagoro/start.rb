# The minimal _why wiki in Innate

%w[rubygems innate haml maruku yaml/store].each{|l| require(l) }

DB = YAML::Store.new('wiki.yaml') unless defined?(DB)

class Wiki
  include Innate::Node
  map '/'
  provide :html => :xhtml
  layout 'wiki'

  def index(page = 'Home')
    @page = page
    @text = 'foo'
=begin
    Innate::STATE.sync do
      DB.transaction(true) do
        @text = DB[page].to_s.gsub(/\[\[(.*?)\]\]/) do
          %(<a href="#{r($1)}" class="#{DB[$1] ? 'exists' : 'missing'}">#{h($1)}</a>)
        end
      end
    end
=end
  end

  def edit(page)
    @page = page
    @text = DB.transaction(true){ DB[page].to_s }
  end

  def save
    redirect_referrer unless request.post?

    page, text = request[:page, :text]
    DB.transaction{ DB[page] = text } if page and text

    redirect(r(page))
  end
end

Innate.start :adapter => :mongrel
