# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end


source 'https://github.com/CocoaPods/Specs.git'
target 'LinkUp' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

    pod 'SDWebImage', '~> 4.0'
    pod 'AWSUserPoolsSignIn', '~> 2.6.6'
    pod 'AWSAuthUI'
    pod 'AWSMobileClient', '~> 2.6.6'
    pod 'GoogleSignIn', '~> 4.0'
    pod 'AWSGoogleSignIn', '~> 2.6.6'
    pod 'AWSFacebookSignIn', '~> 2.6.6'
    pod 'AWSCognito'
    pod 'FBSDKLoginKit'
    pod 'FacebookCore'
    pod 'Google-Mobile-Ads-SDK'
    pod 'FCAlertView'
    pod 'Sheeeeeeeeet'

end
