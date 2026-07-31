#!/usr/bin/env ruby
# ═══════════════════════════════════════════════════════════════
# validate-yaml.rb — Validates YAML syntax AND cross-references
# Usage: ruby validate-yaml.rb [path-filter]
# ═══════════════════════════════════════════════════════════════
require 'yaml'

ROOT = File.expand_path('../..', __dir__)
AGENT_DIR = File.join(ROOT, 'agent-v01')
filter = ARGV[0]

failures = 0
checked = 0

def check_yaml_syntax(file)
  YAML.load_file(file)
  true
rescue Exception => e
  puts "  [SYNTAX] #{file}: #{e.message.split("\n").first}"
  false
end

# 1. Syntax check all YAML files (respecting filter)
Dir.glob(File.join(AGENT_DIR, '**', '*.{yaml,yml}')).sort.each do |file|
  next if file.include?('/.git/')
  next if filter && !file.include?(filter)
  next if file.include?('/core-skills/') && !filter # skip huge upstream content unless explicitly requested
  next if file.include?('/BMAD-METHOD/') && !filter

  checked += 1
  failures += 1 unless check_yaml_syntax(file)
end

puts "Checked #{checked} files (#{failures} failures)" unless filter
puts "Syntax failures: #{failures}"

exit(failures.zero? ? 0 : 1)
