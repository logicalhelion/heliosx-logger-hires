package HeliosX::Logger::HiRes;

use 5.008;
use strict;
use warnings;
use parent 'Helios::Logger';
use constant MAX_RETRIES    => 3;
use constant RETRY_INTERVAL => 5;
use Time::HiRes 'time';

use Helios::LogEntry::Levels ':all';
use Helios::Error::LoggingError;
use HeliosX::Logger::HiRes::LogEntry;

our $VERSION = '0.10_0000';

=head1 NAME

HeliosX::Logger::HiRes - enhanced, high-resolution logging for Helios applications

=head1 SYNOPSIS

 # in a helios.ini file:
 [MyService]
 loggers=HeliosX::Logger::HiRes
 internal_logger=off

 --OR--
 
 # using helios_config_set
 helios_config_set -s MyService -H="*" -p loggers -v HeliosX::Logger::HiRes
 helios_config_set -s MyService -H="*" -p internal_logger -v off 

 # then, use heliosx_logger_hires_search to search the log
 heliosx_logger_hires_search --service=MyService


=head1 DESCRIPTION

HeliosX::Logger::HiRes is a Helios::Logger logging class that provides logging
with high-resolution timestamp precision with a more normalized database
structure.  It also provides L<heliosx_logger_hires_search>, a command to
view and search for log messages at the command line.

=head1 CONFIGURATION

#[] missing


=head1 IMPLEMENTED METHODS

=head2 init()

HeliosX::Logger::HiRes->init() is empty.

=cut

sub init { }

=head2 logMsg($job, $priority, $message)

#[] description

=cut

sub logMsg {
    my $self = shift;
    my ($job, $priority, $message) = @_;

    my $success = 0;
    my $retries = 0;
    my $err;

    my $jobid = defined($job) ? $job->getJobid() : undef;
    my $jobtypeid = defined($job) ? $job->getJobtypeid() : undef;
    
    do {
        eval {

            my $drvr = $self->getDriver();
            my $obj = HeliosX::Logger::HiRes::LogEntry->new(
                log_time  => sprintf("%.6f", time()),
                host      => $self->getHostname(),
                pid       => $$,
                jobid     => $jobid,
                jobtypeid => $jobtypeid,
                service   => $self->getService(),
                priority  => defined($priority) ? $priority : LOG_INFO,
                message   => $message,
            );
            $drvr->insert($obj);
            1;
        };
        if ($@) {
            $err = $@;
            $retries++;
            sleep RETRY_INTERVAL;
        } else {
            # no exception? then declare success and move on
            $success = 1;
        }
    } until ($success || ($retries > MAX_RETRIES));
    
    unless ($success) {
        Helios::Error::LoggingError->throw(__PACKAGE__."->logMsg() ERROR: $err");
    }
    
    return 1;    
}

1;
__END__


=head1 AUTHOR

Andrew Johnson, E<lt>lajandy at cpan dot orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Logical Helion, LLC.

This library is free software; you can redistribute it and/or modify it under 
the terms of the Artistic License 2.0.  See the included LICENSE file for 
details.

=head1 WARRANTY

This software comes with no warranty of any kind.

=cut


