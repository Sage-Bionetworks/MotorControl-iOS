#!/bin/sh
set -ex
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then     # on pull requests
    echo "Build on PR"
    FASTLANE_EXPLICIT_OPEN_SIMULATOR=2 bundle exec fastlane test scheme:"MCTSampleApp"
elif [[ -z "$TRAVIS_TAG" && "$TRAVIS_BRANCH" == "master" ]]; then  # non-tag commits to master branch
    echo "Build on merge to master"
    FASTLANE_EXPLICIT_OPEN_SIMULATOR=2 bundle exec fastlane test scheme:"MCTSampleApp"
    # bundle exec fastlane keychains
    # bundle exec fastlane certificates
    # bundle exec fastlane ci_archive scheme:"MCTSampleApp" export_method:"app-store" project:"MCTSampleApp/MCTSampleApp.xcodeproj"
elif [[ -z "$TRAVIS_TAG" && "$TRAVIS_BRANCH" =~ ^stable-.* ]]; then # non-tag commits to stable branches
    echo "Build on stable branch"
    FASTLANE_EXPLICIT_OPEN_SIMULATOR=2 bundle exec fastlane test scheme:"MCTSampleApp"
    bundle exec fastlane bump_all
    # bundle exec fastlane keychains
    # bundle exec fastlane certificates
    # bundle exec fastlane beta scheme:"MCTSampleApp" export_method:"app-store" project:"MCTSampleApp/MCTSampleApp.xcodeproj"
fi
exit $?
