#
# Be sure to run `pod lib lint PullToRefreshViewDotSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PullToRefreshViewDotSwift'
  s.version          = '1.0.0'
  s.summary          = 'A simple Swift implementation of a pull-to-refresh control, for use with UITableView.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A simple Swift implementation of a pull-to-refresh control, for use with UITableView.

Written as a simple, customizable alternative to UIRefreshControl.
                       DESC

  s.homepage         = 'https://github.com/appsandwich/PullToRefreshView'
  s.screenshots     = 'https://github.com/appsandwich/PullToRefreshView/raw/master/ptr.gif'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Vinny Coyne' => 'vinny+cocoapods@vinnycoyne.com' }
  s.source           = { :git => 'https://github.com/appsandwich/PullToRefreshView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/vinnycoyne'

  s.ios.deployment_target = '10.0'

  s.source_files = 'PullToRefreshViewDotSwift/Classes/**/*'
  
  # s.resource_bundles = {
  #   'PullToRefreshViewDotSwift' => ['PullToRefreshViewDotSwift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
