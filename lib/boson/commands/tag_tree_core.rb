module TagTreeCore
  def self.included(mod)
    require 'namespace_tree'
  end

  # @config :global_options=>true
  # Open urls specified by id in browser
  def open_url(*args)
    urls = Url.console_find(args).map(&:name)
    browser *urls
    urls.join(' ')
  end

  #@options :view=>{:type=>:string, :values=>NamespaceTree::VIEWS}
  # Displays query tree given wildcard machine tag
  def query_tree(mtag, options={})
    QueryTree.new(mtag, options)
  end

  #@options :view=>{:type=>:string, :values=>NamespaceTree::VIEWS}
  # Displays different tag trees given a wildcard machine tag
  def tag_tree(mtag, options={})
    TagTree.new(mtag, options)
  end

  #@options :view=>{:type=>:string, :values=>NamespaceTree::VIEWS}
  # Displays namespace tree given wildcard machine tag
  def namespace_tree(mtag, options={})
    NamespaceTree.new(mtag, options)
  end
end