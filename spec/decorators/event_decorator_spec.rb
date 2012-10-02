require 'spec_helper'

describe EventDecorator, '#invitees_with_current_user_first' do
  it 'creates an array of invitees, with the current user first' do
    event = build_stubbed(:event_with_invitees)
    unsorted_invitees = event.invitees
    current_user = unsorted_invitees.second
    EventDecorator.any_instance.stubs(current_user: current_user)

    sorted_invitees = EventDecorator.new(event).invitees_with_current_user_first

    sorted_invitees.first.should == current_user
    sorted_invitees.should_not == unsorted_invitees
    sorted_invitees.select { |user| user == current_user }.length.should == 1
  end

  it 'includes the event creator' do
    event = create(:event_with_invitees)
    event_creator = event.owner

    sorted_invitees = EventDecorator.new(event).invitees_with_current_user_first

    sorted_invitees.should include(event_creator)
  end
end

describe EventDecorator, '#invitees_who_have_not_voted_count' do
  it 'returns the number of invitees who have not voted' do
    event = create(:event)
    EventDecorator.any_instance.stubs(current_user: event.owner)
    decorated_event = EventDecorator.new(event)
    invitees = create_list(:invitation_with_user, 2, event: event).
      map(&:invitee)
    suggestion = create(:suggestion, event: event)
    vote = create(:vote, voter: invitees.last, suggestion: suggestion)

    invitees_count = decorated_event.other_invitees_who_have_not_voted_count

    invitees_count.should == 1
  end
end


describe EventDecorator, '#invitations_excluding_current_user' do
  it 'returns all invitations excluding the invitation for the current user' do
    event = create(:event)
    decorated_event = EventDecorator.new(event)
    owner_invitation = event.invitations.first
    owner = owner_invitation.invitee
    EventDecorator.any_instance.stubs(current_user: owner)
    new_invitation = create(:invitation_with_user, event: event)

    invitations = decorated_event.invitations_excluding_current_user

    invitations.should include new_invitation
    invitations.should_not include owner_invitation
  end
end

describe EventDecorator, '#first_invitee_for_invitation' do
  it 'returns a space if no invitees' do
    event = build_stubbed(:event)

    string = EventDecorator.new(event).first_invitee_for_invitation

    string.should == ' '
  end

  it 'returns the first invitee with a name' do
    event = create(:event_with_invitees)
    guest = event.invitees.first
    guest.name = nil
    user = event.invitees.second

    string = EventDecorator.new(event).first_invitee_for_invitation

    string.should == ", #{user.name}, "
  end

  it 'returns the first invitee if one exists' do
    event = create(:event_with_invitees)
    first_invitee = event.invitees.first

    string = EventDecorator.new(event).first_invitee_for_invitation

    string.should == ", #{first_invitee.name}, "
  end
end

describe EventDecorator, '#role' do
  it 'returns :owner if the user is the owner of the event' do
    user = build_stubbed(:user)
    event = build_stubbed(:event)
    decorated_event = EventDecorator.new(event)
    Event.any_instance.stubs(user_owner?: true)

    role = decorated_event.role(user)

    role.should == :owner
  end

  it 'returns :guest if the user is not the owner of the event' do
    user = build_stubbed(:user)
    event = build_stubbed(:event)
    decorated_event = EventDecorator.new(event)
    Event.any_instance.stubs(user_owner?: false)

    role = decorated_event.role(user)

    role.should == :invitee
  end
end
