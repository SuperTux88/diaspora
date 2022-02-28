# frozen_string_literal: true

module MentioningSpecHelpers
  def notifications_about_mentioning(user, object)
    table = object.class.table_name

    if object.is_a?(StatusMessage)
      klass = Notifications::MentionedInPost
    elsif object.is_a?(Comment)
      klass = Notifications::MentionedInComment
    end

    klass
      .where(recipient_id: user.id)
      .joins("LEFT OUTER JOIN mentions ON notifications.target_id = mentions.id AND "\
             "notifications.target_type = 'Mention'")
      .joins("LEFT OUTER JOIN #{table} ON mentions_container_id = #{table}.id AND "\
             "mentions_container_type = '#{object.class.base_class}'").where(table.to_sym => {id: object.id})
  end

  def mention_container_path(object)
    object.is_a?(Post) ? post_path(object) : post_path(object.parent, anchor: object.guid)
  end

  def mentioning_mail_notification(user, object)
    ActionMailer::Base.deliveries.select {|delivery|
      delivery.to.include?(user.email) &&
        delivery.subject.include?(I18n.t("notifier.mentioned.subject", name: "")) &&
        delivery.body.parts[0].body.include?(mention_container_path(object))
    }
  end

  def also_commented_mail_notification(user, post)
    ActionMailer::Base.deliveries.select {|delivery|
      delivery.to.include?(user.email) &&
        delivery.subject.include?(I18n.t("notifier.also_commented.limited_subject")) &&
        delivery.body.parts[0].body.include?(post_path(post))
    }
  end

  def stream_for(user)
    stream = Stream::Multi.new(user)
    stream.posts
  end

  def mention_stream_for(user)
    stream = Stream::Mention.new(user)
    stream.posts
  end

  def receive_each(entity, recipients)
    inlined_jobs do
      recipients.each do |recipient|
        DiasporaFederation.callbacks.trigger(:receive_entity, entity, entity.author, recipient.id)
      end
    end
  end

  def find_private_message(guid)
    StatusMessage.find_by(guid: guid).tap do |status_msg|
      expect(status_msg).not_to be_nil
      expect(status_msg.public?).to be false
    end
  end

  def receive_comment_via_federation(text, parent)
    entity = build_relayable_federation_entity(
      :comment,
      parent_guid: parent.guid,
      author:      remote_raphael.diaspora_handle,
      parent:      Diaspora::Federation::Entities.related_entity(parent),
      text:        text
    )

    receive_each(entity, [parent.author.owner])

    Comment.find_by(guid: entity.guid)
  end
end

describe "mentioning", type: :request do
  include MentioningSpecHelpers

  RSpec::Matchers.define :be_mentioned_in do |object|
    include Rails.application.routes.url_helpers

    def user_notified?(user, object)
      notifications_about_mentioning(user, object).any? && mentioning_mail_notification(user, object).any?
    end

    match do |user|
      object.message.markdownified.include?(person_path(id: user.person.guid)) && user_notified?(user, object)
    end

    match_when_negated do |user|
      !user_notified?(user, object)
    end
  end

  RSpec::Matchers.define :be_in_streams_of do |user|
    match do |status_message|
      stream_for(user).map(&:id).include?(status_message.id) &&
        mention_stream_for(user).map(&:id).include?(status_message.id)
    end

    match_when_negated do |status_message|
      !stream_for(user).map(&:id).include?(status_message.id) &&
        !mention_stream_for(user).map(&:id).include?(status_message.id)
    end
  end

  let(:user1) { FactoryBot.create(:user_with_aspect) }
  let(:user2) { FactoryBot.create(:user_with_aspect, friends: [user1, user3]) }
  let(:user3) { FactoryBot.create(:user_with_aspect) }

  context "in comments" do
    let(:author) { FactoryBot.create(:user_with_aspect) }

    shared_context "commenter is author" do
      let(:commenter) { author }
    end

    shared_context "commenter is author's friend" do
      let(:commenter) { FactoryBot.create(:user_with_aspect, friends: [author]) }
    end

    shared_context "commenter is not author's friend" do
      let(:commenter) { FactoryBot.create(:user) }
    end

    shared_context "mentioned user is author" do
      let(:mentioned_user) { author }
    end

    shared_context "mentioned user is author's friend" do
      let(:mentioned_user) { FactoryBot.create(:user_with_aspect, friends: [author]) }
    end

    shared_context "mentioned user is not author's friend" do
      let(:mentioned_user) { FactoryBot.create(:user) }
    end

    context "with public post" do
      let(:status_msg) { FactoryBot.create(:status_message, author: author.person, public: true) }

      [
        ["commenter is author's friend", "mentioned user is not author's friend"],
        ["commenter is author's friend", "mentioned user is author"],
        ["commenter is not author's friend", "mentioned user is author's friend"],
        ["commenter is not author's friend", "mentioned user is not author's friend"],
        ["commenter is author", "mentioned user is author's friend"],
        ["commenter is author", "mentioned user is not author's friend"]
      ].each do |commenters_context, mentioned_context|
        context "when #{commenters_context} and #{mentioned_context}" do
          include_context commenters_context
          include_context mentioned_context

          let(:comment) {
            inlined_jobs do
              commenter.comment!(status_msg, text_mentioning(mentioned_user))
            end
          }

          subject { mentioned_user }
          it { is_expected.to be_mentioned_in(comment) }
        end
      end
    end

    context "with private post" do
      [
        ["commenter is author's friend", "mentioned user is author's friend"],
        ["commenter is author", "mentioned user is author's friend"],
        ["commenter is author's friend", "mentioned user is author"]
      ].each do |commenters_context, mentioned_context|
        context "when #{commenters_context} and #{mentioned_context}" do
          include_context commenters_context
          include_context mentioned_context

          let(:parent) { FactoryBot.create(:status_message_in_aspect, author: author.person) }
          let(:comment) {
            inlined_jobs do
              commenter.comment!(parent, text_mentioning(mentioned_user))
            end
          }

          before do
            mentioned_user.like!(parent)
          end

          subject { mentioned_user }
          it { is_expected.to be_mentioned_in(comment) }
        end
      end

      context "commenter can't mention a non-participant" do
        let(:status_msg) { FactoryBot.create(:status_message_in_aspect, author: author.person) }

        [
          ["commenter is author's friend", "mentioned user is not author's friend"],
          ["commenter is not author's friend", "mentioned user is author's friend"],
          ["commenter is not author's friend", "mentioned user is not author's friend"],
          ["commenter is author", "mentioned user is author's friend"],
          ["commenter is author", "mentioned user is not author's friend"]
        ].each do |commenters_context, mentioned_context|
          context "when #{commenters_context} and #{mentioned_context}" do
            include_context commenters_context
            include_context mentioned_context

            let(:comment) {
              inlined_jobs do
                commenter.comment!(status_msg, text_mentioning(mentioned_user))
              end
            }

            subject { mentioned_user }
            it { is_expected.not_to be_mentioned_in(comment) }
          end
        end
      end

      it "only creates one notification for the mentioned person, when mentioned person commented twice before" do
        parent = FactoryBot.create(:status_message_in_aspect, author: author.person)
        mentioned_user = FactoryBot.create(:user_with_aspect, friends: [author])
        mentioned_user.comment!(parent, "test comment 1")
        mentioned_user.comment!(parent, "test comment 2")
        comment = inlined_jobs do
          author.comment!(parent, text_mentioning(mentioned_user))
        end

        expect(notifications_about_mentioning(mentioned_user, comment).count).to eq(1)
      end
    end
  end
end
