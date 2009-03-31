ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'site'
  map.connect "/what-is-this", :controller => 'site', :action => "what_is_this"
end
