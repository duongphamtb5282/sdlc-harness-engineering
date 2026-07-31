#!/usr/bin/env ruby
# ═══════════════════════════════════════════════════════════════
# generate-skill-profiles.rb — Generate per-agent skill profiles
# (Tier 3) from SKILL-ROUTER.yaml (Tier 2).
# Usage: ruby agent-v01/scripts/generate-skill-profiles.rb
# ═══════════════════════════════════════════════════════════════
require 'yaml'

ROOT = File.expand_path('../..', __dir__)
ROUTER = File.join(ROOT, 'agent-v01', 'SKILL-ROUTER.yaml')
PROFILES_DIR = File.join(ROOT, 'agent-v01', 'skills', 'profiles')

abort "ERROR: #{ROUTER} not found" unless File.exist?(ROUTER)

data = YAML.load_file(ROUTER)
require 'fileutils'; FileUtils.mkdir_p(PROFILES_DIR) unless Dir.exist?(PROFILES_DIR)

data['router'].each do |persona, phases|
  core = []
  additional = []
  conditional = {}

  phases.each do |phase, sections|
    core.concat(Array(sections['core']))
    additional.concat(Array(sections['additional']))
    conditional.merge!(sections['conditional']) if sections['conditional']
    conditional['stacks'] = sections['stacks'].keys if sections['stacks']
    additional.concat(Array(sections['security'])) if sections['security']
  end

  core = core.uniq.sort
  additional = additional.uniq.sort
  total = (core + additional).uniq.size

  profile = {
    'persona' => persona,
    'phases' => phases.keys,
    'core_skills' => core,
    'additional_skills' => additional,
    'conditional_skills' => conditional,
    'total_skills' => total,
    'load_strategy' => 'lazy — load SKILL.md only when task matches',
  }

  out = File.join(PROFILES_DIR, "#{persona}.yaml")
  File.write(out, profile.to_yaml)
  puts "  OK #{persona}: #{total} skills -> #{out}"
end

puts "\nProfiles generated in agent-v01/skills/profiles/"
