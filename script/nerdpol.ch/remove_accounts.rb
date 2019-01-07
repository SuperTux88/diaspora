accounts = <<LIST.lines.map(&:chomp)
foo@bar.com
foo@bar2.com
LIST

ENV['RAILS_ENV'] ||= "production"
require_relative '../../config/environment'

Person.where(diaspora_handle: accounts).each do |person|
  puts "Removing #{person.diaspora_handle}"

  Comment.where(author_id: person.id).each do |comment|
    if comment.parent.author.local?
      comment.parent.author.owner.retract(comment)
    else
      comment.destroy
    end
  end

  AccountDeletion.create!(person: person) unless AccountDeletion.where(person: person).exists?
end
