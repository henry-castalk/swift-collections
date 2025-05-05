#!/usr/bin/env python3
import argparse
import os
import shutil
import subprocess
import tempfile

def generate_podspec(path, module_name, version, dependencies):
    content = f"""\
Pod::Spec.new do |s|
  s.name = '{module_name}'
  s.version = '{version}'
  s.license = {{ :type => 'Apache 2.0', :file => 'LICENSE.txt' }}
  s.summary = 'A {module_name} API for Swift.'
  s.homepage = 'https://github.com/apple/swift-collections'
  s.author = 'Apple Inc.'
  s.source = {{ :git => 'https://github.com/apple/swift-collections.git', :tag => s.version.to_s }}
  s.module_name = '{module_name}'

  s.swift_version = '5.9'
  s.cocoapods_version = '>= 1.10.0'

  s.ios.deployment_target = '12.0'

  s.source_files = 'Sources/{module_name}/**/*.swift'
"""

    for dep in dependencies:
        content += f"  s.dependency '{dep}'\n"

    content += "end\n"

    print("-" * 40)
    print(content)
    print("-" * 40)
    with open(path, "w") as f:
        f.write(content)

def main():
    parser = argparse.ArgumentParser(description="Generate and lint a podspec.")
    parser.add_argument("version", help="Target version")
    parser.add_argument("module_name", help="Module name")
    parser.add_argument("dependencies", nargs="*", help="Optional dependencies (internal or external)")
    args = parser.parse_args()

    version = args.version
    module_name = args.module_name
    dependencies = args.dependencies

    tmpdir = tempfile.mkdtemp(prefix=".build_podspecs", dir="/tmp")
    print(f"📦 Building podspec in {tmpdir}")

    podspec_filename = f"{module_name}.podspec"
    podspec_path = os.path.join(tmpdir, podspec_filename)

    generate_podspec(podspec_path, module_name, version, dependencies)

    print(f"🔍 Linting {podspec_path}")
    subprocess.run([
        "pod", 
        "spec", 
        "lint", 
        podspec_path, 
        "--verbose", 
        "--allow-warnings"
        ], check=True)

    destination_path = os.path.join(os.getcwd(), podspec_filename)
    shutil.copy(podspec_path, destination_path)
    print(f"✅ Copied to {destination_path}")

if __name__ == "__main__":
    main()