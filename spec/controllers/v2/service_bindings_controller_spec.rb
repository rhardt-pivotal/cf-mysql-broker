require 'spec_helper'

describe V2::ServiceBindingsController do
  let(:db_settings) { Rails.configuration.database_configuration[Rails.env] }
  let(:admin_user) { db_settings.fetch('username') }
  let(:admin_password) { db_settings.fetch('password') }
  let(:database_host) { db_settings.fetch('host') }
  let(:database_port) { db_settings.fetch('port') }

  let(:instance_guid) { 'instance-1' }
  let(:instance) { ServiceInstance.new(guid: instance_guid, db_name: database) }
  let(:database) { ServiceInstanceManager.database_name_from_service_instance_guid(instance_guid) }

  before do
    authenticate
    instance.save

    allow(Database).to receive(:exists?).with(database).and_return(true)
    allow(Settings).to receive(:allow_table_locks).and_return(true)
  end

  after { instance.destroy }

  describe '#update' do
    let(:binding_id) { '123' }
    let(:generated_dbname) { ServiceInstanceManager.database_name_from_service_instance_guid(instance_guid) }

    let(:generated_username) { ServiceBinding.new(id: binding_id).username }
    let(:generated_password) { 'generatedpw' }

    let(:make_request) { put :update, params: {id: binding_id, service_instance_id: instance_guid }}

    before { allow(SecureRandom).to receive(:base64).and_return(generated_password, 'notthepassword') }
    after { ServiceBinding.new(id: binding_id, service_instance: instance).destroy }

    it_behaves_like 'a controller action that requires basic auth'

    it_behaves_like 'a controller action that does not log its request and response headers and body'

    context 'when the service instance exists' do
      it 'grants permission to access the given database' do
        expect(ServiceBinding.exists?(id: binding_id, service_instance_guid: instance_guid)).to eq(false)

        make_request

        expect(ServiceBinding.exists?(id: binding_id, service_instance_guid: instance_guid)).to eq(true)
      end

      it 'returns a 201' do
        make_request

        expect(response.status).to eq(201)
      end

      it 'responds with generated credentials' do
        make_request

        binding = JSON.parse(response.body)
        expect(binding['credentials']).to eq(
          'hostname' => database_host,
          'name' => generated_dbname,
          'username' => generated_username,
          'password' => generated_password,
          'port' => database_port,
          'jdbcUrl' => "jdbc:mysql://#{database_host}:#{database_port}/#{generated_dbname}?user=#{generated_username}&password=#{generated_password}",
          'uri' => "mysql://#{generated_username}:#{generated_password}@#{database_host}:#{database_port}/#{generated_dbname}?reconnect=true",
        )
      end

      context 'when the read-only parameter is set to the boolean value true' do
        let(:make_request) { put :update, params: {id: binding_id, service_instance_id: instance_guid, parameters: {'read-only' => true} } }
        before { allow(ServiceBinding).to receive(:new).and_call_original }

        it 'creates a binding with read_only: true' do
          make_request

          expect(ServiceBinding).to have_received(:new).with(id: binding_id, service_instance: instance_of(ServiceInstance), read_only: true)
        end
      end

      context 'when the read-only parameter is not set' do
        let(:make_request) { put :update, params: {id: binding_id, service_instance_id: instance_guid }}
        before { allow(ServiceBinding).to receive(:new).and_call_original }

        it 'creates a binding with default read_only: false' do
          make_request

          expect(ServiceBinding).to have_received(:new).with(id: binding_id, service_instance: instance_of(ServiceInstance), read_only: false)
        end
      end

      # context 'when the read-only parameter has a non-boolean value' do
      #   let(:make_request) { put :update, id: binding_id, service_instance_id: instance_guid, parameters: {'read-only' => 'true'} }
      #
      #   it 'does not create a binding' do
      #     make_request
      #     expect(ServiceBinding.exists?(id: binding_id, service_instance_guid: instance_guid)).to eq(false)
      #   end
      #
      #   it 'returns a 400 and an error message' do
      #     make_request
      #
      #     expect(response.status).to eq(400)
      #     expect(JSON.parse(response.body)).to eq({
      #       "error" => "Error creating service binding",
      #       "description" => "Invalid arbitrary parameter syntax. Please check the documentation for supported arbitrary parameters.",
      #     })
      #   end
      # end

      context 'when an invalid parameter is provided' do
        let(:make_request) { put :update, params: {id: binding_id, service_instance_id: instance_guid, parameters: {'unexpected-parameter' => true} }}

        it 'does not create a binding' do
          make_request
          expect(ServiceBinding.exists?(id: binding_id, service_instance_guid: instance_guid)).to eq(false)
        end

        it 'returns a 400 and an error message' do
          make_request

          expect(response.status).to eq(400)
          expect(JSON.parse(response.body)).to eq({
            "error" => "Error creating service binding",
            "description" => "Invalid arbitrary parameter syntax. Please check the documentation for supported arbitrary parameters.",
          })
        end
      end
    end

    context 'when the service instance does not exist' do
      let(:make_request) { put :update, params: {id: binding_id, service_instance_id: 'non-existent-guid' }}

      it 'returns a 404' do
        make_request

        expect(response.status).to eq(404)
      end
    end
  end

  describe '#destroy' do
    let(:binding_id) { 'BINDING-1' }
    let(:binding) { ServiceBinding.new(id: binding_id, service_instance: instance) }
    let(:username) { binding.username }

    let(:make_request) { delete :destroy, params: {service_instance_id: instance.id, id: binding.id }}

    it_behaves_like 'a controller action that requires basic auth'

    context 'when the binding exists' do
      before { binding.save }
      after { binding.destroy }

      it_behaves_like 'a controller action that does not log its request and response headers and body'

      it 'destroys the binding' do
        expect(ServiceBinding.exists?(id: binding.id, service_instance_guid: instance.guid)).to eq(true)

        make_request

        expect(ServiceBinding.exists?(id: binding.id, service_instance_guid: instance.guid)).to eq(false)
      end

      it 'returns a 200' do
        make_request

        expect(response.status).to eq(200)
        expect(response.body).to eq('{}')
      end
    end

    context 'when the binding does not exist' do
      it_behaves_like 'a controller action that does not log its request and response headers and body'

      it 'returns a 410' do
        make_request

        expect(response.status).to eq(410)
      end
    end
  end
end
