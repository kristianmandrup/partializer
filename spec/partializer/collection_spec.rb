require 'spec_helper'

describe Partializer::Collection do
  include Partializer::Resolver

  let(:clazz) { Partializer::Collection }

  describe '#initialize' do
    subject { clazz.new 'hash', hash.keys, hash }

    let(:args) { [{upper: :gallery}, :lower] }

    let(:hash) do
      args.flatten.inject({}) do |res, arg|
        key = arg.kind_of?(Hash) ? arg.keys.first : arg
        res[key.to_sym] = resolve(arg)
        res
      end
    end

    specify do
      subject.name.should == 'hash'
    end

    specify do
      subject.partials.should be_a Partializer::Partials
    end

    specify do
      subject.partials.list.should include(:upper)
    end

    specify do
      subject.upper.partials.list.should include(:gallery)
    end
  end
end