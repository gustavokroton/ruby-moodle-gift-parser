Gem::Specification.new do |s|
  s.name        = 'moodle_gift_parser'
  s.version     = '0.1.0'
  s.date        = '2017-01-10'
  s.summary     = 'Parse Moodle Gift format'
  s.description = 'First version of a GIFT file parser.'
  s.authors     = ['Oliver Kuster']
  s.email       = 'olivervbk@gmail.com'
  s.files       = Dir['Rakefile', '{bin,lib,man,test,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
  s.homepage    = 'https://github.com/olivervbk/ruby-moodle-gift-parser'
  s.license     = 'MIT'
  s.add_development_dependency 'rake', '12.0.0'
  s.add_development_dependency 'rspec', '3.5.0'
  s.add_development_dependency 'rspec-collection_matchers', '1.1.3'
end
