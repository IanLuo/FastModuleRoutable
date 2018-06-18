Pod::Spec.new do |s|
  s.name         = "FastModuleRoutable"
  s.version      = "0.0.1"
  s.summary      = "Routable."
  s.description  = "description"

  s.homepage     = "https://github.com/IanLuo/FastModuleRoutable"
  s.license      = "MIT"
  s.author             = { "luoxu" => "ianluo63@gmail.com.com" }
  s.source       = { :git => "git@github.com:IanLuo/FastModuleRoutable.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/**/*.swift"
  s.dependency "FastModule"
  s.dependency "FastModuleLayoutable"
  s.resource_bundle = { 'image' => ["Media.xcassets"] }
end
