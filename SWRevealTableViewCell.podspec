Pod::Spec.new do |s|
  s.name          = "SWRevealTableViewCell"
  s.version       = "0.3.5"
  s.summary       = "UITableViewCell subclass to easily display left and right buttons based on user pan gestures or developer programmatic actions."
  s.homepage      = "https://github.com/John-Lluch/SWRevealTableViewCell"
  s.license       = "MIT"
  s.author        = { "John Lluch Zorrilla" => "joan.lluch@sweetwilliamsl.com" }
  s.source        = { :git => "https://github.com/John-Lluch/SWRevealTableViewCell.git", :tag =>  "v#{s.version}" }
  s.platform      = :ios, "7.0"
  s.source_files  = "SWRevealTableViewCell/*.{h,m}"
  s.framework     = "CoreGraphics"
  s.requires_arc  = true
end
