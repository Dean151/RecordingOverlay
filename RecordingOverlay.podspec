Pod::Spec.new do |spec|

  spec.name         = "RecordingOverlay"
  spec.version      = "0.3.0"
  spec.summary      = "Creates an bordered overlay around the screen."

  spec.description  = <<-DESC
  Adds a UIWindow containing a border layer of the color of your choise. Perfect to show an active state, or a recording state.
                   DESC

  spec.homepage     = "https://github.com/Dean151/RecordingOverlay"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = "Dean"
  spec.social_media_url   = "https://twitter.com/deanatoire"

  spec.ios.deployment_target = "9.0"
  spec.tvos.deployment_target = "9.0"

  spec.source       = { :git => "https://github.com/Dean151/RecordingOverlay.git", :tag => "#{spec.version}" }

  spec.source_files  = "Sources/**"
  spec.exclude_files = "SampleApps"

end
