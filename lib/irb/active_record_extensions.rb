module ConsoleExtensions
  def self.included(base)
    base.class_eval %[
      named_scope :find_by_regexp, lambda {|c,v| {:conditions=>[c + " REGEXP ?", v]}}
      def self.find_name_by_regexp(v); find_by_regexp('name', v); end
      class <<self
        alias_method :rn, :find_name_by_regexp
        alias_method :fr, :find_by_regexp
      end
    ]
  end
end

ActiveRecord::Base.class_eval %[
  class<<self
    def inherited(child)
      super
      child.class_eval do
        include ConsoleExtensions
      end
    end
    
    alias_method :f, :find
  end
  
  def rua(name, value)
    require 'abbrev'
    if name = self.class.column_names.abbrev[name.to_s]
      update_attribute(name, value)
    else
      puts "'\#{name}' doesn't match a column"
    end
  end

  def self.fn(*args); self.find_by_name(*args); end
]
#since Tag was already defined by gems
Tag.class_eval %[include ConsoleExtensions]