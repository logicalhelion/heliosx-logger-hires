package HeliosX::Logger::HiRes::LogEntry;

use 5.008;
use strict;
use warnings;
use base 'Data::ObjectDriver::BaseObject';

our $VERSION = '0.01_0000';

__PACKAGE__->install_properties({
	columns => [
		'logid',
		'log_time',
		'host',
		'pid',
		'jobid',
		'jobtypeid',
		'service',
		'priority',
		'message',		
	],
	datasource  => 'helios_log_entry_hires_tb',
	primary_key => 'logid',
});

1;
__END__