# frozen_string_literal: true

namespace :railswatch do
  desc 'Prune old railswatch records based on configured retention'
  task prune: :environment do
    results = Railswatch.prune!
    puts results.map { |type, count| "#{type}: #{count}" }.join("\n")
  end
end
