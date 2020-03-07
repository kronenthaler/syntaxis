#
#  Be sure to run `pod spec lint Syntaxis.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name = "Syntaxis"
  spec.version = "0.1.0"
  spec.summary = "Yet another functional parser library"
  spec.homepage = "https://github.com/kronenthaler/Syntaxis"
  spec.license = { :type => "MIT", :file => "LICENSE" }
  spec.author = { "kronenthaler" => "kronenthaler@gmail.com" }
  spec.source = { :git => "https://github.com/kronenthaler/Syntaxis.git", :tag => "#{spec.version}" }

  spec.description = <<-DESC
    A parsing library based on the concept of parsing combinators.
    Allows to create parsers that read as a BNF specification and allows to construct
    AST objects as the parser goes along.
  DESC

  spec.platform = :ios, "11.0"
  spec.requires_arc = true
  spec.swift_versions = [ 5.0 ]

  spec.source_files = "Classes/**/*.{swift,h}"
  spec.public_header_files = "Classes/**/*.h"
  spec.preserve_paths = "README.md"
end
