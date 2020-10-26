class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: 'jbrhel@blueberryapps.com', password: 'heslo123'
end
