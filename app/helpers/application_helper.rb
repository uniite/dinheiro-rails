module ApplicationHelper

  # Creates a button for creating new instances
  def button_to_new(model, options={})
    button_to_action model, :new, options
  end

  # Similar to button_to_new but for editing a specific record
  def button_to_edit(record, options={})
    button_to_action record, :edit, options
  end

  # Similar to button_to_edit but for destroy
  # The main difference is it needs to do a DELETE instead of a GET
  def button_to_destroy(record, options={})
    options[:method] = 'delete'
    # We want to emphasize this is dangerous
    options[:data] =  { confirm: 'Are you sure?' }
    options[:class] = 'btn-danger'
    button_to_action record, :destroy, options
  end


  private

    # Creates a link with the bootstrap btn class for an action against the specified model
    # (eg. link_to 'New Post', new_post_path, class: 'btn-default btn')
    def button_to_action(record_or_class, action, options)
      # Default to the btn-default style
      options[:class] ||= 'btn-default'
      options[:class] << ' btn'

      # Figure out the text (eg. 'post' => 'Post'), and the path (eg. new_post_path)
      if options[:text]
        text = options.delete :text
      else
        text = action.to_s.capitalize
      end
      route_options = {controller: ActiveModel::Naming.route_key(record_or_class), action: action}
      # If we're passed a record, use the ID in the route
      unless record_or_class.instance_of? Class
        route_options[:id] = record_or_class.id
      end
      # If this is a destroy, we need to pass the record rather than a URL
      if action == :destroy
        link_to text, record_or_class, options
      else
        link_to text, url_for(route_options), options
      end
    end
end
