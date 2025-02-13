#
# Author:: Marc Paradise (<marc@chef.io>)
# Copyright:: Copyright (c) Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative "exceptions"

class Chef
  class SecretFetcher

    SECRET_FETCHERS = %i{example aws_secrets_manager azure_key_vault hashi_vault akeyless_vault}.freeze

    # Returns a configured and validated instance
    # of a [Chef::SecretFetcher::Base]  for the given
    # service and configuration.
    #
    # @param service [Symbol] the identifier for the service that will support this request. Must be in
    #                         SECRET_FETCHERS
    # @param config [Hash] configuration that the secrets service requires
    # @param run_context [Chef::RunContext] the run context this is being invoked from
    def self.for_service(service, config, run_context)
      fetcher = case service
                when :example
                  require_relative "secret_fetcher/example"
                  Chef::SecretFetcher::Example.new(config, run_context)
                when :aws_secrets_manager
                  require_relative "secret_fetcher/aws_secrets_manager"
                  Chef::SecretFetcher::AWSSecretsManager.new(config, run_context)
                when :azure_key_vault
                  require_relative "secret_fetcher/azure_key_vault"
                  Chef::SecretFetcher::AzureKeyVault.new(config, run_context)
                when :hashi_vault
                  require_relative "secret_fetcher/hashi_vault"
                  Chef::SecretFetcher::HashiVault.new(config, run_context)
                when :akeyless_vault
                  require_relative "secret_fetcher/akeyless_vault"
                  Chef::SecretFetcher::AKeylessVault.new(config, run_context)
                when nil, ""
                  raise Chef::Exceptions::Secret::MissingFetcher.new(SECRET_FETCHERS)
                else
                  raise Chef::Exceptions::Secret::InvalidFetcherService.new("Unsupported secret service: '#{service}'", SECRET_FETCHERS)
                end
      fetcher.validate!
      fetcher
    end
  end
end

