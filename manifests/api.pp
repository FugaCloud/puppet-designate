# == Class designate::api
#
# Configure designate API service
#
# == Parameters
#
# [*package_ensure*]
#  (optional) The state of the package
#  Defaults to 'present'
#
# [*api_package_name*]
#  (optional) Name of the package containing api resources
#  Defaults to $::designate::paramas::api_package_name
#
# [*enabled*]
#   (optional) Whether to enable services.
#   Defaults to true
#
# [*service_ensure*]
#  (optional) Whether the designate api service will be running.
#  Defaults to 'running'
#
# [*auth_strategy*]
#  (optional) Authentication strategy to use, can be either "noauth" or
#  "keystone".
#  Defaults to $::os_service_default
#
# [*enable_api_v1*]
#  (optional) Enable Designate API Version 1 (deprecated).
#  Defaults to $::os_service_default
#
# [*enable_api_v2*]
#  (optional) Enable Designate API Version 2.
#  Defaults to $::os_service_default
#
# [*enable_api_admin*]
#  (optional) Enable Designate Admin API.
#  Defaults to $::os_service_default
#
# [*api_base_uri*]
#  Set the base URI of the Designate API service.
#
# [*listen*]
#  (optional) API host:port pairs to listen on.
#  Defaults to $::os_service_default
#
# [*workers*]
#  (optional) Number of api worker processes to spawn.
#  Defaults to $::os_service_default
#
# [*threads*]
#  (optional) Number of api greenthreads to spawn.
#  Defaults to $::os_service_default
#
# [*enable_host_header*]
#  (optional) Enable host request headers.
#  Defaults to $::os_service_default
#
# [*max_header_line*]
#  (optional) Maximum line size of message headers to be accepted.
#  Defaults to $::os_service_default
#
# DEPRECATED PARAMETERS
#
# [*api_host*]
#  (optional) Address to bind the API server
#  Defaults to undef
#
# [*api_port*]
#  (optional) Port the bind the API server to
#  Defaults to undef
#
class designate::api (
  $package_ensure     = present,
  $api_package_name   = $::designate::params::api_package_name,
  $enabled            = true,
  $service_ensure     = 'running',
  $auth_strategy      = $::os_service_default,
  $enable_api_v1      = $::os_service_default,
  $enable_api_v2      = $::os_service_default,
  $enable_api_admin   = $::os_service_default,
  $api_base_uri       = $::os_service_default,
  $listen             = $::os_service_default,
  $workers            = $::os_service_default,
  $threads            = $::os_service_default,
  $enable_host_header = $::os_service_default,
  $max_header_line    = $::os_service_default,
  # DEPRECATED PARAMETERS
  $api_host           = undef,
  $api_port           = undef,
) inherits designate {

  include ::designate::deps

  if $api_host and $api_port {
    warning('api_host and api_port parameters have been deprecated, please use listen instead.')
    $listen_real = "${api_host}:${api_port}"
  } else {
    $listen_real = $listen
  }

  if !is_service_default($enable_api_v1) {
    warning('Version 1 of API is deprecated.')
  }

  # API Service
  designate_config {
    'service:api/listen'                    : value => $listen_real;
    'service:api/auth_strategy'             : value => $auth_strategy;
    'service:api/enable_api_v1'             : value => $enable_api_v1;
    'service:api/enable_api_v2'             : value => $enable_api_v2;
    'service:api/enable_api_admin'          : value => $enable_api_admin;
    'service:api/api_base_uri'              : value => $api_base_uri;
    'service:api/workers'                   : value => $workers;
    'service:api/threads'                   : value => $threads;
    'service:api/enable_host_header'        : value => $enable_host_header;
    'service:api/max_header_line'           : value => $max_header_line;
  }

  if $auth_strategy == 'keystone' {
    include ::designate::keystone::authtoken
  }

  designate::generic_service { 'api':
    enabled        => $enabled,
    manage_service => $service_ensure,
    ensure_package => $package_ensure,
    package_name   => $api_package_name,
    service_name   => $::designate::params::api_service_name,
  }
}
