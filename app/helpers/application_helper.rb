# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # outputs a class attribute for the body if @body_class is set
  def body_class
    unless @body_class.blank?
      %{ class="#{@body_class}"}
    end
  end
end
