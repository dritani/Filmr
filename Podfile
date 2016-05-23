# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'Filmr' do
    pod 'Koloda', '~> 3.1.1'
    pod 'BubbleTransition'
    pod 'SCLAlertView'
    pod 'Firebase'
end


post_install do |installer|
    `find Pods -regex 'Pods/pop.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)pop\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
end

