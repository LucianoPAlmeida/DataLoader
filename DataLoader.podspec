#
# Be sure to run `pod lib lint FlatPickerView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DataLoader'
  s.version          = '0.1.0'
  s.summary          = 'Key/Value memory cache manager'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                An iOS visual element witch behaviors like a UIPickerView but with flat design and more customizable. You can customize the direction of picker, the highlighted element view, and the actual element view also.
                        DESC

  s.homepage         = 'https://github.com/LucianoPAlmeida/DataLoader/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Luciano Almeida' => 'passos.luciano@outlook.com' }
  s.source           = { :git => 'https://github.com/LucianoPAlmeida/DataLoader.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/LucianoPassos11'

  s.ios.deployment_target = '10.0'

  s.source_files = 'DataLoader/**/*'

end
