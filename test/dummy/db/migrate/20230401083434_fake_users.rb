# frozen_string_literal: true

class FakeUsers < ActiveRecord::Migration[6.1]
  def change
    User.delete_all
    puts 'populating 50 users ...'
    50.times do |_i|
      User.create(first_name: "John #{rand(10_000)}", age: rand(100))
    end
  end
end
