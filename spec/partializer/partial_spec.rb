require 'spec_helper'

describe Partializer::Partial do
  subject { clazz.new 'main', 'lower'}

  let(:clazz) { Partializer::Partial }

  describe '#initialize' do
    its(:view_path) { should == 'main/lower'}
  end
  
  describe '#path=' do
    before :all do
      subject.path = 'go'
    end

    its(:view_path) { should == 'go/lower'}
  end
end
