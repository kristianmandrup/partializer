require 'spec_helper'

class Resolve
  include Partializer::Resolver
end

describe Partializer::Resolver do
  subject { Resolve.new }

  describe '#resolve_sym' do
    specify do
      subject.resolve_sym(:gallery).partials.should include(:gallery)
    end

    specify do
      expect { subject.resolve_sym(:gallery).gallery }.to raise_error
    end
  end

  describe '#resolve_hash' do
    let(:hash) do
      {:com => :gallery}
    end

    specify do
      subject.resolve_hash(hash).partials.should include(:com)
    end

    specify do
      subject.resolve_hash(hash).com.partials.should include(:gallery) 
    end
  end    

  # describe '#resolve' do
  #   describe 'hash' do
  #     let(:hash) do
  #       {:com => :gallery}
  #     end

  #     specify do
  #       subject.resolve(hash).partials.should include(:com)
  #     end

  #     specify do
  #       subject.resolve(hash).com.partials.should include(:gallery)
  #     end
  #   end    

  #   describe 'symbol' do
  #     specify do
  #       subject.resolve(:gallery).partials.should include(:gallery)
  #     end

  #     specify do
  #       expect { subject.resolve(:gallery).gallery }.to raise_error
  #     end
  #   end    
  # end
end
