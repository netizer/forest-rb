Gem::Specification.new do |s|
  s.name = "forest"
  s.authors = ["Krzysiek Heród"]
  s.licenses = ["MIT"]
  s.homepage = "https://rubygems.org/netizer/groundcover"
  s.version = "0.0.1"
  s.date = "2020-06-13"
  s.summary = "Forest programming language."
  s.description = "Forest is a programming language for business logic, meant to be embedded in other languages."
  s.files = `git ls-files -z`.split("\x0")
  s.require_paths = ["lib"]
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
end
