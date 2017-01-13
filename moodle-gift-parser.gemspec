Gem::Specification.new do |spec|
  spec.name        = 'moodle_gift_parser'
  spec.version     = '0.1.0'
  spec.date        = '2017-01-10'
  spec.summary     = 'Parse Moodle Gift format'
  spec.description = 'First version of a GIFT file parser.'
  spec.authors     = ['Oliver Kuster']
  spec.email       = 'olivervbk@gmail.com'
  spec.files       = Dir['Rakefile', '{bin,lib,man,test,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
  spec.homepage    = 'https://github.com/olivervbk/ruby-moodle-gift-parser'
  spec.license     = 'MIT'

  spec.add_development_dependency 'rake', '12.0.0'
  spec.add_development_dependency 'rspec', '3.5.0'
  spec.add_development_dependency 'rspec-collection_matchers', '1.1.3'
end
