class Url < ActiveRecord::Base
  has_machine_tags :quick_mode=>true, :reverse_has_many=>true, :console=>true
  validates_presence_of :name
  validates_uniqueness_of :name
  
  class<<self
    def console_find(args)
      if args[0].is_a?(Integer)
        results = args.map {|e| find(e)}
      elsif args[0].is_a?(ActiveRecord::Base)
        results = args
      else
        results = tagged_with(*args)
      end
      results
    end
      
    def quick_create(string)
      name, description, tags = string.split(",,")
      create_hash = {:name=>name}
      if tags.nil?
        create_hash[:tag_list] = description
      else
        create_hash[:description] = description
        create_hash[:tag_list] = tags
      end
      create(create_hash)
    end
    
    def tagged_with_count(*args)
      tagged_with(*args).count
    end

    def find_and_change_machine_tags(*args)
      options = args[-1].is_a?(Hash) ? args[-1].pop : {}
      results = console_find(args)
      namespace = results.select {|e| 
        nsp = e.tag_list.select {|f| break $1 if f =~ /^(\S+):/}
         break nsp if !nsp.empty?
        false
      }
      if namespace
        results.each {|e|
          new_tag_list = e.tag_list.map {|f|
            f.include?("#{namespace}:") ? f : "#{namespace}:#{f}"
          }
          p [e.id, e.tag_list, new_tag_list]
          if options[:save]
            e.tag_and_save(new_tag_list)
          end
        }
      else
        puts "no namespace detected"
      end
      nil
    end

    def find_and_regex_change_tags(find_args, regex, substitution, options={})
      results = Url.console_find(find_args)
      results.each do |e|
        new_tag_list = e.tag_list.map {|f| f.gsub(regex, substitution)}
        p [e.id, e.tag_list, new_tag_list]
        if options[:save]
          e.tag_and_save(new_tag_list)
        end
      end
      nil
    end
  end  
end
