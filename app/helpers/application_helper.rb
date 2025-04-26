module ApplicationHelper
  def sortable(column, title = nil)
    title ||= column.titleize
    direction = column == params[:sort] && params[:direction] == 'asc' ? 'desc' : 'asc'
    icon = ''
    
    if column == params[:sort]
      icon = direction == 'asc' ? '↑' : '↓'
    end
    
    link_to "#{title} #{icon}".html_safe, 
            request.params.merge(sort: column, direction: direction, page: nil), 
            class: "sortable-header"
  end
end
