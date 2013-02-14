module ApplicationHelper
  include Rails.application.routes.url_helpers

  def cancel_link
    return link_to 'Cancel', request.env["HTTP_REFERER"],
      :class => 'cancel',
     :confirm => 'Are you sure? Any changes will be lost.'
  end

# return the title of each page
	def title
		base_title = "SSP Online Information Center"
		if @title.nil?
			base_title
		else
			"#{base_title} | #{@title}"
		end
  end

  def logo
      image_tag("logo.jpg", :alt => "SSP Logo", :class => "round", :width => 75, :height => 75)
  end

  def format_phone(phone)
    "(#{phone[0..2]}) #{phone[3..5]}-#{phone[6..9]}"
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    logger.debug column
    logger.debug sort_column
    css_class = (column == sort_column) ? "sorted-#{sort_direction}" : "sortable"
    direction = (sort_column &&  sort_direction == "asc") ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end
#def button(name,url)
  def button(*args)
    if args.size == 2
      name = args[0]
      url = args[1]
      content_tag :button, :type => "button", :onclick => "window.location.href =  '#{url_for(url)}'; " do
        "#{name}"
      end
    elsif args.size == 1
      name = args[0]
      content_tag :button, :type => "button" do
        "#{name}"
      end
    end
  end

end
