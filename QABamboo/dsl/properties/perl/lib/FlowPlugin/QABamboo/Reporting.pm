package FlowPlugin::QABamboo::Reporting;
use Data::Dumper;
use base qw/FlowPDF::Component::EF::Reporting/;
use FlowPDF::Log;
use strict;
use warnings;

# todo more sample boilerplate
sub compareMetadata {
    my ($self, $metadata1, $metadata2) = @_;
    my $value1 = $metadata1->getValue();
    my $value2 = $metadata2->getValue();

    my $pluginObject = $self->getPluginObject();

    return $pluginObject->compareISODateTimes($value1->{startTime}, $value2->{startTime});
}

sub initialGetRecords {
    my $self = shift;
    my $pluginObject = shift;
    my ($limit) = @_;

    my $params = $pluginObject->getContext()->getRuntimeParameters();
    my $records = $pluginObject->getBuildRuns($params->{projectKey}, $params->{planKey}, {
        maxResults => ($limit || 10)
    });

    return $records;
}

sub _buildRunBuildURL {
    my ($params) = @_;
    my $drilldownURL = $params->{baseDrilldownUrl};
    $drilldownURL ||= $params->{endpoint};

    my $buildSourceKey = $params->{projectKey} . ($params->{planKey} ? ('-' . $params->{planKey}) : '');

    $drilldownURL =~ s|/+$||;
    return $drilldownURL . '/browse/' . $buildSourceKey;
}


sub getRecordsAfter {
    my $self = shift;
    my $bamboo = shift;
    my $metadata = shift;

    my $params = $bamboo->getContext()->getRuntimeParameters();

    my $metadataValues = $metadata->getValue();
    logDebug("Got metadata value in getRecordsAfter:", Dumper $metadataValues);

    my $records = $bamboo->getBuildRunsAfter($params->{projectKey}, $params->{planKey}, {
        maxResults => 0,
        afterTime  => $metadataValues->{startTime}
    });

    logDebug("Records after GetRecordsAfter", Dumper $records);

    return $records;
}

sub getLastRecord {
    my $self = shift;
    my $pluginObject = shift;

    my $params = $pluginObject->getContext()->getRuntimeParameters();
    logDebug("Last record runtime params:", Dumper $params);

    my $runs = $pluginObject->getBuildRuns($params->{projectKey}, $params->{planKey}, {
        maxResults => 1
    });

    return $runs->[0];
}

sub buildDataset {
    my $self = shift;
    my $bamboo = shift;
    my ($records) = @_;

    my $dataset = $self->newDataset([ 'build' ]);
    my $context = $bamboo->getContext();
    my $params = $context->getRuntimeParameters();

    my %buildStateMapping = (
        'Successful' => 'SUCCESS',
        'Failed'     => 'FAILURE',
        'Unknown'    => 'NOT_BUILT',
    );


    # Adding from the end of the list
    for my $row ( reverse @$records ) {
        my %payload = (
            source              => 'Bamboo',
            pluginName          => '@PLUGIN_NAME@',
            projectName         => $context->retrieveCurrentProjectName(),
            releaseName         => $params->{releaseName} || '',
            # This probably should be <projectName>-<planName>
            releaseUri          => ($params->{projectKey} . ($params->{planKey} ? '-' . $params->{planKey} : '')),
            releaseProjectName  => $params->{releaseProjectName} || '',
            pluginConfiguration => $params->{config},
            baseDrilldownUrl    => ($params->{baseDrilldownUrl} || $params->{endpoint}) . '/browse/',
            buildNumber         => $row->{buildNumber},
            timestamp           => $row->{buildStartedTime},
            endTime             => $row->{buildCompletedTime},
            startTime           => $row->{buildStartedTime},
            buildStatus         => $buildStateMapping{$row->{buildState} || 'Unknown'},
            launchedBy          => 'N/A',
            jobName             => $row->{key},
            duration            => $row->{buildDuration},
            tags                => $row->{labels} || '',
            sourceUrl           => $row->{url},
        );

        for (keys %payload) {
            if (!defined $payload{$_}) {
                logWarning("Payload parameter '$_' don't have a value and will not be sent.");
                delete $payload{$_};
            }
        }

        my $data = $dataset->newData({
            reportObjectType => 'build',
            values           => \%payload
        });

        if ($params->{retrieveTestResults}) {
            logInfo("Test results retrieval is enabled");
            if ($row->{totalTestsCount}) {
                logInfo("Got testreport for build number $row->{buildNumber}, creating new dependent data");
                my $dependentData = $data->createNewDependentData('quality');

                my %testsPayload = (
                    category           => $params->{testCategory} || 'unit-test',
                    projectName        => $payload{projectName},
                    releaseName        => $payload{releaseName},
                    releaseProjectName => $payload{releaseProjectName},
                    timestamp          => $payload{startTime},
                    skippedTests       => $row->{skippedTestCount} || 0,
                    successfulTests    => $row->{successfulTestCount} || 0,
                    failedTests        => $row->{failedTestCount} || 0,
                    totalTests         => $row->{totalTestsCount},
                );

                $dependentData->addValue( $_ => $testsPayload{$_} ) for (keys %testsPayload);
            }
            else {
                logInfo("No test results in the build result.")
            }
        }
    }
    return $dataset;
}



1;