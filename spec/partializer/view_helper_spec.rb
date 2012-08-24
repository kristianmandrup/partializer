require 'spec_helper'

describe Partializer::ViewHelper do
  include Partializer::ViewHelper

  let(:main_partializer) { partialize('properties#show', 'main') }
  let(:my_main_partializer) { partialize('properties#show', 'my_main') }

  describe '#initialize' do
    subject { main_partializer }

    its(:name) { should == 'main'}
    its(:path) { should == 'properties/show/main' }

    specify do
      subject.partials.should include(:upper, :lower)
    end

    # see view_helper.rb: res += "#{partial.view_path}:"
    specify do
      # puts render_partials(subject)
      render_partials(subject).should match /main\/upper/
    end
  end

  describe 'nested partializing' do
    subject { partialize my_main_partializer, 'lower'}

    its(:name) { should == 'my_main.lower'}
    its(:path) { should == 'properties/show/my_main/lower' }    
  end
end