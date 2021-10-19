require 'rails_helper'

module Stitches
  describe Error do
    describe '#initialize' do
      context 'required params are set' do
        it 'does not raise error' do
          expect do
            described_class.new(code: anything, message: anything)
          end.to_not raise_error
        end
      end

      context 'code is missing' do
        it 'raises a descriptive error' do
          expect do
            described_class.new(message: 'foo')
          end.to raise_error(
                    described_class::MissingParameter,
                    'Stitches::Error must be initialized with :code')
        end
      end

      context 'message is missing' do
        it 'raises a descriptive error' do
          expect do
            described_class.new(code: 123)
          end.to raise_error(
                    described_class::MissingParameter,
                    'Stitches::Error must be initialized with :message')
        end
      end

      context 'both are missing' do
        it 'raises an error about code' do
          expect do
            described_class.new(message: 'foo')
          end.to raise_error(
                  described_class::MissingParameter,
                  'Stitches::Error must be initialized with :code')
        end
      end
    end
  end
end
