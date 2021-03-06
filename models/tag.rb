require 'has_machine_tags/tag_console'
require 'console_update'

class Tag < ActiveRecord::Base
  include HasMachineTags::TagConsole
  #td: doesn't load properly
  # has_machine_tags :quick_mode=>true, :console=>true
  can_console_update :only=>%w{name description}

  # hack for check_unused_tags
  def taggings_size
    taggings.size
  end

  class <<self
    def machine_tag_names
      (namespaces + predicates + values).uniq
    end
  
    def machine_tag(namespace, predicate, value)
      find(:first, :conditions=>{:namespace=>namespace, :predicate=>predicate, :value=>value})
    end
  end
end
