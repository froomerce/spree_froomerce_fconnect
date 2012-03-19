# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform     = Gem::Platform::RUBY
  s.name         = 'spree_froomerce_fconnect'
  s.version      = '0.70.3'
  s.summary      = 'Create your store to Facebook and create product widgets for your Fan Page'
  s.description  = 'Create your store to Facebook and create product widgets for your Fan Page'
  s.required_ruby_version = '>= 1.8.7'

  s.author       = 'Froomerce'
  s.email        = 'ali.naqi@coeus-solutions.de'
  s.homepage     = 'http://www.froomerce.com'

  s.files        = `git ls-files`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '>= 0.70.0'
end

