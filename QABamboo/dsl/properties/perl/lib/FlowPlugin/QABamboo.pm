package FlowPlugin::QABamboo;
use FlowPlugin::REST;
use FlowPDF::Constants qw/AUTH_SCHEME_VALUE_FOR_BASIC_AUTH/;
use JSON;
use strict;
use warnings;
use base qw/FlowPDF/;
use FlowPDF::Log;
use Data::Dumper;
# Feel free to use new libraries here, e.g. use File::Temp;

# Service function that is being used to set some metadata for a plugin.
sub pluginInfo {
    return {
        pluginName          => '@PLUGIN_KEY@',
        pluginVersion       => '@PLUGIN_VERSION@',
        configFields        => ['config'],
        configLocations     => ['ec_plugin_cfgs'],
        defaultConfigValues => {
            authScheme => AUTH_SCHEME_VALUE_FOR_BASIC_AUTH
        }
    };
}

# Auto-generated method for the procedure Sample REST Procedure/Sample REST Procedure
# Add your code into this method and it will be called when step runs
# Parameter: config
# Parameter: username

sub client {return shift->{restClient}};

sub init {
    my ($self, $params) = @_;

    my $context = $self->getContext();

    # Check if should redirect logs
    my $propLocation = '/plugins/@PLUGIN_KEY@/project/ec_debug_logToProperty';
    eval {
        my $debugToPropertyXpath = $context->getEc->getProperty($propLocation);
        my $debugToProperty = $debugToPropertyXpath->findvalue('//value')->string_value();;
        if (defined $debugToProperty && $debugToProperty ne '') {
            FlowPDF::Log::setLogToProperty($debugToProperty);
            FlowPDF::Log::FW::setLogToProperty($debugToProperty);
        }
    };

    # Show framework logs when debug level is set to "Trace"
    if ($params->{debugLevel} >= FlowPDF::Log::TRACE) {
        FlowPDF::Log::FW::setLogLevel(FlowPDF::Log::TRACE);
    }

    $self->{restClient} = FlowPlugin::REST->new($context, {
        APIBase     => '/rest/api/latest/',
        contentType => 'json',
        errorHook   => {
            default => sub {
                return $self->defaultErrorHandler(@_)
            }
        }
    });
}



sub defaultErrorHandler {
    my FlowPDF $self = shift;
    my ($response, $decoded) = @_;

    logDebug(Dumper \@_);

    if (!$decoded || !$decoded->{message}) {
        $decoded->{message} = 'No specific error message was returned. Check logs for details';
        logError($response->decoded_content || 'No content returned');
    }

    my $stepResult = $self->getContext()->newStepResult();
    $stepResult->setJobStepOutcome('error');
    $stepResult->setJobStepSummary($decoded->{message});
    $stepResult->setJobSummary("Error happened while performing the operation: '$decoded->{message}'");
    $stepResult->apply();

    return;
}

sub sampleRESTProcedure {
    my ($pluginObject) = @_;

    my $context = $pluginObject->getContext();
    my $params = $context->getStepParameters();

    my $QABambooRESTClient = $pluginObject->getQABambooRESTClient;
    # If you have changed your parameters in the procedure declaration, add/remove them here
    my %restParams = (
        username => $params->getParameter('username')->getValue,
    );
    my $response = $QABambooRESTClient->getUser(%restParams);
    logInfo("Got response from the server: ", $response);

    my $stepResult = $context->newStepResult;

    $stepResult->apply();
}

# This method is used to access auto-generated REST client.
sub getQABambooRESTClient {
    my ($self) = @_;

    my $context = $self->getContext();
    my $config = $context->getRuntimeParameters();
    require FlowPlugin::QABambooRESTClient;
    my $client = FlowPlugin::QABambooRESTClient->createFromConfig($config);
    return $client;
}
# Procedure parameters:
# config
# config
# projectKey
# planKey
# retrieveTestResults
# testCategory
# initialRecordsCount
# previewMode
# transformScript
# debug
# releaseName
# releaseProjectName

sub collectReportingData {
    my $self = shift;
    my $params = shift;
    $self->init($params);

    if ($params->{debugLevel}) {
        FlowPDF::Log::setLogLevel(FlowPDF::Log::DEBUG);
    }

    my $requestKey = $params->{projectKey} . ($params->{planKey} ? '-' . $params->{planKey} : '');

    my $reporting = FlowPDF::ComponentManager->loadComponent('FlowPlugin::QABamboo::Reporting', {
        reportObjectTypes   => [ 'build' ],
        initialRecordsCount => $params->{initialRecordsCount},
        metadataUniqueKey   => $requestKey,
        payloadKeys         => [ 'startTime' ]
    }, $self);

    $reporting->CollectReportingData();
}


sub validateCRDParams {
    my $self = shift;
    my $params = shift;
    my $stepResult = shift;
    $self->init($params);

    my @required = qw/config projectKey/;
    for my $param (@required) {
        bailOut("Parameter $params is mandatory") unless $params->{$param};
    }

    $stepResult->setJobSummary('success');
    $stepResult->setJobStepOutcome('Parameters check passed');

    exit 0;
}

## === step ends ===
# Please do not remove the marker above, it is used to place new procedures into this file.


sub getBuildRunsAfter {
    my ($self, $projectKey, $planKey, $parameters) = @_;
    my $afterTime = $parameters->{afterTime};

    my @results = ();

    # Adding plan key if given
    my $requestKey = $projectKey . ($planKey ? '-' . $planKey : '');
    my $requestPath = '/result/' . $requestKey;

    # Will load this count of results at once
    my $requestPackSize = 25;

    my %requestParams = (
        expand        => 'results.result.labels',
        'max-results' => $requestPackSize,
        'start-index' => 0
    );

    my $reachedGivenTime = 0;
    my $haveMoreResults = 1;

    while (!$reachedGivenTime && $haveMoreResults) {
        my $buildResults = $self->client->get($requestPath, \%requestParams);
        return unless defined $buildResults;

        # If returned less results that we requested, than there are no more updates to request
        $haveMoreResults = $buildResults->{results}{size} >= $requestPackSize;

        for my $buildResult (@{$buildResults->{results}{result}}) {
            my $parsed = _planBuildResultToShortInfo($buildResult, [ 'labels' ]);

            if ($self->compareISODateTimes($afterTime, $parsed->{buildStartedTime}) >= 0) {
                $reachedGivenTime = 1;
                last;
            }

            push @results, $parsed;
        }

        # Request next pack
        $requestParams{'start-index'} += $requestPackSize;
    }

    return \@results;
}

sub getBuildRuns {
    my ($self, $projectKey, $planKey, $parameters) = @_;

    # Adding plan key if given
    my $requestKey = $projectKey . ($planKey ? '-' . $planKey : '');
    my $requestPath = '/result/' . $requestKey;

    my $limit = 0;
    if (defined $parameters->{maxResults}) {
        $limit = $parameters->{maxResults};
    }

    my $buildResults = $self->client->get($requestPath, { expand => 'results.result', 'max-results' => $limit });
    return unless defined $buildResults;

    my @result = map {_planBuildResultToShortInfo($_)} @{$buildResults->{results}{result}};

    return \@result;
}


sub compareISODateTimes {
    my ($self, $date1, $date2) = @_;

    $date1 =~ s/[^0-9]//g;
    $date2 =~ s/[^0-9]//g;

    logDebug("Comparing: $date1 > $date2 = ", $date1 <=> $date2);

    return $date1 <=> $date2;
}

sub _planBuildResultToShortInfo {
    my ($buildInfo, $expanded) = @_;

    my @oneToOne = qw/
        key
        buildNumber
        buildState
        finished
        successful
        lifeCycleState

        planName
        projectName

        vcsRevisionKey

        buildTestSummary
        successfulTestCount
        failedTestCount
        skippedTestCount
        quarantinedTestCount

        buildStartedTime
        buildCompletedTime
        buildDuration
        buildDurationInSeconds
        buildReason
    /;

    my %result = (
        url     => $buildInfo->{link}{href},
        planKey => $buildInfo->{plan}{key},
    );

    if ($buildInfo->{buildTestSummary} && $buildInfo->{buildTestSummary} ne 'No tests found') {
        push(@oneToOne,
            qw/buildTestSummary
                successfulTestCount
                failedTestCount
                quarantinedTestCount
                skippedTestCount/
        );

        $result{totalTestsCount} = ($buildInfo->{successfulTestCount} || 0)
            + ($buildInfo->{failedTestCount} || 0)
            + ($buildInfo->{quarantinedTestCount} || 0)
            + ($buildInfo->{skippedTestCount} || 0)
    }

    if (defined $expanded && ref $expanded eq 'ARRAY') {
        for my $section (@$expanded) {
            if ($section eq 'labels' && $buildInfo->{labels}{size} > 0) {
                $result{labels} = join(', ', map {$_->{name}} @{$buildInfo->{labels}});
            }
            elsif ($section eq 'artifacts' && $buildInfo->{artifacts}{size}) {
                my @artifacts = @{$buildInfo->{artifacts}{artifact}};

                # Less nested properties
                $_->{link} = $_->{link}{href} for @artifacts;

                $result{artifacts} = \@artifacts;
            }
        }
    }

    $result{$_} = $buildInfo->{$_} for (@oneToOne);

    return \%result;
}

1;