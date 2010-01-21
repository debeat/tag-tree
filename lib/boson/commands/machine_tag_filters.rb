require 'machine_tag'

module ::Boson::OptionCommand::Filters
  def mtag_argument(val)
    ::MachineTagFilters.filter(val)
  end

  def ourls_argument(args)
    args.flatten!
    unless args[0].is_a?(ActiveRecord::Base)
      args = MachineTag.query?(args[0].to_s) ? Url.super_tagged_with(args) :
        (args.empty? ? [] : Url.console_find(*args))
    end
    args
  end
end

module ::MachineTagFilters
  class <<self
    def namespaces
      @namespaces ||= Tag.namespaces.sort
    end

    def predicates
      @predicates ||= Tag.predicates.sort
    end

    def values
      @values ||= Tag.values.sort
    end

    def reset
      @predicates = @namespaces = @values = nil
    end

    def filter(value)
      mtags = MachineTag[value]
      new_mtags = unalias_mtags(mtags.dup)
      new_mtags.each do |field, new_val|
        old_val = mtags[field]
        if field == :namespace
          value.include?(':') ? value.sub!("#{old_val}:", "#{new_val}:") : value.sub!("#{old_val}.", "#{new_val}.")
        elsif field == :predicate
          value.include?(':') ? value.sub!(":#{old_val}", ":#{new_val}") : value.sub!("#{old_val}=", "#{new_val}=")
        elsif field == :value
          value.include?('=') ? value.sub!("=#{old_val}", "=#{new_val}") : value.include?('.') ?
            value.sub!(".#{old_val}", ".#{new_val}") : value.sub!(old_val, new_val)
        end
      end
      value
    end

    def unalias_mtags(hash)
      possibles = {:value=>values, :namespace=>namespaces, :predicate=>predicates}
      hash.each do |field, val|
        new_val = (possibles[field] || []).find {|e| e[/^#{val}/] }
        hash[field] = new_val if new_val
      end
    end
  end
end