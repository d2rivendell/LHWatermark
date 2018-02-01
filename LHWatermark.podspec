Pod::Spec.new do |s|
s.name         = "LHWatermark"
s.version      = "0.0.3"
s.summary      = "Add watermark on your Image."
s.homepage     = "https://github.com/LeonHwa/LHWatermark"
s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
s.author       = { "LeonHwa" => "hwestseacoast@163.com" }
s.platform     = :ios, "7.0"
s.source       = { :git => "https://github.com/LeonHwa/LHWatermark.git", :tag => s.version }
s.source_files  = "LHWatermark", "LHWatermark/*.{h,m}" 
s.requires_arc = true
end