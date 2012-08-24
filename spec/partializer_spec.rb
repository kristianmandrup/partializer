require 'spec_helper'

describe Partializer do
  subject { properties }

  its(:show) { should be_a Partializers::Properties::Show }

  let(:properties) { Partializers::Properties.new }

  describe 'show' do
    subject { properties.show }

    specify do
      subject.side.partials.should include(:basic_info)
    end

    specify do
      subject.main.partials.should include(:upper, :lower)
    end

    specify do
      subject.main.upper.partials.should include(:gallery)
      subject.main.upper.name.should == 'main.upper'
    end

    specify do
      subject.main.lower.partials.should include(:lower)
      subject.main.lower.name.should == 'main.lower'
    end

    specify do
      subject.my_main.lower.partials.should include(:description)
    end

    specify do
      subject.my_main.lower.communication.partials.should include(:profile)
      subject.my_main.lower.communication.name.should == 'my_main.lower.communication'
    end
  end
end
