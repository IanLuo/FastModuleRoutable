Pod::Spec.new do |s|
  s.name         = "FastModuleRoutable"
  s.version      = "0.0.1"
  s.summary      = "Routable."
  s.description  = "description"

  s.homepage     = "http://someplace/Routable"
  s.license      = "MIT"
  s.author             = { "luoxu" => "ianluo63@gmail.com.com" }
  s.source       = { :git => "http://somepace/HNARoutable.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/**/*.swift"
  s.dependency "FastModule"
  s.dependency "FastModuleLayoutable"
  s.resource_bundle = { 'image' => ["Media.xcassets"] }
end
