package FlowPlugin::QAPerlBamboo;
use JSON;
use strict;
use warnings;
use base qw/FlowPDF/;
use FlowPDF::Log;

# Feel free to use new libraries here, e.g. use File::Temp;

# Service function that is being used to set some metadata for a plugin.
sub pluginInfo {
    return {
        pluginName          => '@PLUGIN_KEY@',
        pluginVersion       => '@PLUGIN_VERSION@',
        configFields        => ['config'],
        configLocations     => ['ec_plugin_cfgs'],
        defaultConfigValues => {}
    };
}

# Auto-generated method for the procedure Sample REST Procedure/Sample REST Procedure
# Add your code into this method and it will be called when step runs
# Parameter: config
# Parameter: username

sub sampleRESTProcedure {
    my ($pluginObject) = @_;

    my $context = $pluginObject->getContext();
    my $params = $context->getRuntimeParameters();

    my $QAPerlBambooRESTClient = $pluginObject->getQAPerlBambooRESTClient;
    # If you have changed your parameters in the procedure declaration, add/remove them here
    my %restParams = (
        'username' => $params->{'username'},
    );
    my $response = $QAPerlBambooRESTClient->getUser(%restParams);
    logInfo("Got response from the server: ", $response);

    my $stepResult = $context->newStepResult;

    $stepResult->apply();
}

# This method is used to access auto-generated REST client.
sub getQAPerlBambooRESTClient {
    my ($self) = @_;

    my $context = $self->getContext();
    my $config = $context->getRuntimeParameters();
    require FlowPlugin::QAPerlBambooRESTClient;
    my $client = FlowPlugin::QAPerlBambooRESTClient->createFromConfig($config);
    return $client;
}
# Auto-generated method for the procedure Get Builds/Get Builds
# Add your code into this method and it will be called when step runs
# Parameter: config
# Parameter: requestKey
# Parameter: expand
# Parameter: max-results
# Parameter: start-index

sub getBuilds {
    my ($pluginObject) = @_;

    my $context = $pluginObject->getContext();
    my $params = $context->getRuntimeParameters();

    my $QAPerlBambooRESTClient = $pluginObject->getQAPerlBambooRESTClient;
    # If you have changed your parameters in the procedure declaration, add/remove them here
    my %restParams = (
        'requestKey' => $params->{'requestKey'},
        'expand' => $params->{'expand'},
        'max-results' => $params->{'max-results'},
        'start-index' => $params->{'start-index'},
    );
    my $response = $QAPerlBambooRESTClient->getBuildResults(%restParams);
    logInfo("Got response from the server: ", $response);

    my $stepResult = $context->newStepResult;

    $stepResult->apply();
}

# Procedure parameters:
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
    # $self->init($params);

    if ($params->{debugLevel}) {
        FlowPDF::Log::setLogLevel(FlowPDF::Log::DEBUG);
    }

    my $requestKey = $params->{projectKey} . ($params->{planKey} ? '-' . $params->{planKey} : '');

    my $reporting = FlowPDF::ComponentManager->loadComponent('FlowPlugin::QAPerlBamboo::Reporting', {
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
    # $self->init($params);

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

    my $QAPerlBambooRESTClient = $self->getQAPerlBambooRESTClient;
    # Adding plan key if given
    my $requestKey = $projectKey . ($planKey ? '-' . $planKey : '');
    # my $requestPath = '/result/' . $requestKey;

    # Will load this count of results at once
    my $requestPackSize = 25;

    my %requestParams = (
        'requestKey'  => $requestKey.'.json',
        expand        => 'results.result.labels',
        'max-results' => $requestPackSize,
        'start-index' => 0
    );

    my $reachedGivenTime = 0;
    my $haveMoreResults = 1;

    while (!$reachedGivenTime && $haveMoreResults) {
        # my $buildResults = $self->client->get($requestPath, \%requestParams);

        my $buildResults = $QAPerlBambooRESTClient->getBuildsResults(%requestParams);

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
    my $QAPerlBambooRESTClient = $self->getQAPerlBambooRESTClient;

    # Adding plan key if given
    my $requestKey = $projectKey . ($planKey ? '-' . $planKey : '');
    # my $requestPath = '/result/' . $requestKey;

    my $limit = 0;
    if (defined $parameters->{maxResults}) {
        $limit = $parameters->{maxResults};
    }

    my %requestParams = (
        'requestKey'  => $requestKey.'.json',
        expand        => 'results.result',
        'max-results' => $limit,
    );

    my $buildResults = $QAPerlBambooRESTClient->getBuildsResults(%requestParams);

    # my $buildResults = $self->client->get($requestPath, { expand => 'results.result', 'max-results' => $limit });
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