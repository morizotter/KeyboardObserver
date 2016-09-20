Pod::Spec.new do |s|
  s.name         = "KeyboardObserver"
  s.version      = "0.5.1"
  s.summary      = "For less complicated keyboard event handling."
  s.description  = <<-DESC
                    - Less complicated keyboard event handling.
                    - Do not use `NSNotification` , but `event` .
                   DESC

  s.homepage     = "https://github.com/morizotter/KeyboardObserver"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Morita Naoki" => "namorit@gmail.com" }
  s.social_media_url   = "http://twitter.com/morizotter"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/morizotter/KeyboardObserver.git", :tag => s.version }
  s.source_files  = "KeyboardObserver/**/*.swift"
  s.requires_arc = true
end
