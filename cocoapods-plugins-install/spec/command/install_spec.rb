require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Install do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ install }).should.be.instance_of Command::Install
      end
    end
  end
end

