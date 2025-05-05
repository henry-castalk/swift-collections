#!/bin/bash
set -eu

function usage() {
  echo "$0 [-u] version"
  echo
  echo "OPTIONS:"
  echo "  -u: Additionally upload the podspec"
}

upload=false
while getopts ":u" opt; do
  case $opt in
    u)
      upload=true
      ;;
    \?)
      usage
      exit 1
      ;;
  esac
done
shift "$((OPTIND-1))"

if [[ $# -eq 0 ]]; then
  echo "Must provide target version"
  exit 1
fi

version=$1
module_name=$2
podspec_name="${module_name}"

here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
tmpdir=$(mktemp -d /tmp/.build_podspecsXXXXXX)
echo "Building podspec in $tmpdir"

cat > "${tmpdir}/${podspec_name}.podspec" <<- EOF
Pod::Spec.new do |s|
  s.name = '$podspec_name'
  s.version = '$version'
  s.license = { :type => 'Apache 2.0', :file => 'LICENSE.txt' }
  s.summary = 'A ${module_name} API for Swift.'
  s.homepage = 'https://github.com/apple/swift-collections'
  s.author = 'Apple Inc.'
  s.source = { :git => 'https://github.com/apple/swift-collections.git', :tag => s.version.to_s }
  s.module_name = '${module_name}'

  s.swift_version = '5.9'
  s.cocoapods_version = '>= 1.10.0'

  s.ios.deployment_target = '12.0'

  s.source_files = 'Sources/${module_name}/**/*.swift'
end
EOF

if $upload; then
  echo "Uploading ${tmpdir}/${podspec_name}.podspec"
  pod trunk push "${tmpdir}/${podspec_name}.podspec"
else
  echo "Linting ${tmpdir}/${podspec_name}.podspec"
  pod spec lint "${tmpdir}/${podspec_name}.podspec" --verbose --allow-warnings
  cp "${tmpdir}/${podspec_name}.podspec" "./${podspec_name}.podspec"
fi
