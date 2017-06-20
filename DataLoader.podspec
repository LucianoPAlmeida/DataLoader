#
# Be sure to run `pod lib lint FlatPickerView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DataLoader'
  s.version          = '0.1.7'
  s.summary          = 'Key/Value memory cache manager'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                This is a key/value memory cache convenience library for Swift.With DataLoader you can mantain your data loaded cached during an operation that sometimes requires you manage the state loaded and not loaded.
                Inspired on the opensource facebook/dataloader library. 
                        DESC

  s.homepage         = 'https://github.com/LucianoPAlmeida/DataLoader/'
  s.license          = { :type => 'MIT', :text => <<-LICENSE
                                                    Copyright 2017
                                                    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
                                                    LICENSE
                        }
  s.author           = { 'Luciano Almeida' => 'passos.luciano@outlook.com' }
  s.source           = { :git => 'https://github.com/LucianoPAlmeida/DataLoader.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/LucianoPassos11'

  s.ios.deployment_target = '10.0'

  s.source_files = 'DataLoader/**/*'

end
