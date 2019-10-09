package FlowPlugin::TestRailRest;
use FlowPDF::Log;
use JSON;
use strict;
use warnings;
use base qw/FlowPDF/;

# Feel free to use new libraries here, e.g. use File::Temp;

# Service function that is being used to set some metadata for a plugin.
sub pluginInfo {
    return {
        pluginName    => '@PLUGIN_KEY@',
        pluginVersion => '@PLUGIN_VERSION@',
        configFields  => ['config'],
        configLocations => ['ec_plugin_cfgs']
    };
}


# This method is used to access auto-generated REST client.
sub getTestRailRestRESTClient {
    my ($self) = @_;

    my $context = $self->getContext();
    my $config = $context->getRuntimeParameters();
    require FlowPlugin::TestRailRestRESTClient;
    my $client = FlowPlugin::TestRailRestRESTClient->createFromConfig($config);
    return $client;
}

# Auto-generated method for the procedure Get Test Case/Get Test Case
# Add your code into this method and it will be called when step runs
# Parameter: config
# Parameter: caseId

sub getTestCase {
    my ($pluginObject) = @_;

    my $context = $pluginObject->getContext();
    my $params = $context->getStepParameters();

    my $TestRailRestRESTClient = $pluginObject->getTestRailRestRESTClient;

    # Setting default parameters
    $params->{resultFormat} ||= 'json';
    $params->{resultPropertySheet} ||= '/myJob/caseId';

    my $caseId = $params->{caseId};

    logInfo("requesting info");
    my %params = (
        caseId => $params->getParameter('caseId')->getValue,
    );
    my $response = $TestRailRestRESTClient->getTestCase(%params);
    logInfo("Got response from the server: ", $response);

    my $stepResult = $context->newStepResult;

    print "Created stepResult\n";
    $stepResult->setOutputParameter('caseId', $response->{id});
    $stepResult->setOutputParameter('caseJSON', encode_json $response);
    logInfo("Test Case information was saved to properties.");

    $stepResult->setJobStepOutcome('success');
    $stepResult->setJobStepSummary('Case found: #' . $response->{id});
    $stepResult->setJobSummary("Info about Test Case: #$caseId has been saved to property(ies)");

    print "Set stepResult\n";

    $stepResult->apply();
}

# Auto-generated method for the procedure Create Test Case/Create Test Case
# Add your code into this method and it will be called when step runs
# Parameter: config
# Parameter: json
# Parameter: sectionId

sub createTestCase {
    my ($pluginObject) = @_;

    my $context = $pluginObject->getContext();
    my $params = $context->getStepParameters();

    my $TestRailRestRESTClient = $pluginObject->getTestRailRestRESTClient;

    use Data::Dumper;
    print Dumper $params;
    my $payload = decode_json $params->getParameter('json')->getValue; 
    my %params = (
        sectionId => $params->getParameter('sectionId')->getValue,
        json => $payload,
    );
    my $response = $TestRailRestRESTClient->createTest(%params);
    return unless defined $response;

    logInfo("Got response from the server: ", $response);

    my $stepResult = $context->newStepResult;

    print "Created stepResult\n";

    $stepResult->setOutputParameter('caseId', $response->{id});
    $stepResult->setOutputParameter('caseJSON', encode_json $response);
    logInfo("Plan(s) information was saved to properties.");

    $stepResult->setJobStepOutcome('success');
    $stepResult->setJobStepSummary("Test Case: #$response->{id} created under section: #$params->{sectionId}");
    $stepResult->setJobSummary("Info about Test Case: #$response->{id} has been saved to property(ies)");

    print "Set stepResult\n";

    $stepResult->apply();
}

# Auto-generated method for the procedure Update Test Case/Update Test Case
# Add your code into this method and it will be called when step runs
# Parameter: config
# Parameter: caseId
# Parameter: json

sub updateTestCase {
    my ($pluginObject) = @_;

    my $context = $pluginObject->getContext();
    my $params = $context->getStepParameters();

    my $TestRailRestRESTClient = $pluginObject->getTestRailRestRESTClient;
    my $payload = decode_json $params->getParameter('json')->getValue; 
    my %params = (
        caseId => $params->getParameter('caseId')->getValue,
        json => $payload,
    );
    my $response = $TestRailRestRESTClient->updateTest(%params);
    return unless defined $response;
    logInfo("Got response from the server: ", $response);

    my $stepResult = $context->newStepResult;

    print "Created stepResult\n";
    $stepResult->setOutputParameter('caseId', $response->{id});
    $stepResult->setOutputParameter('caseJSON', encode_json $response);
    logInfo("Test Case: #'$response->{id}' updated");

    $stepResult->setJobStepOutcome('success');
    $stepResult->setJobStepSummary("Test Case: #$response->{id} created under section: #$params->{sectionId}");
    $stepResult->setJobSummary("Info about Test Case: #$response->{id} has been saved to property(ies)");

    print "Set stepResult\n";

    $stepResult->apply();
}

## === step ends ===
# Please do not remove the marker above, it is used to place new procedures into this file.


1;