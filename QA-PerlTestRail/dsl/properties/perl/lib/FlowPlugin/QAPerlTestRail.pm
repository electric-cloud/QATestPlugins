package FlowPlugin::QAPerlTestRail;
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

# Auto-generated method for the procedure Get Test Case/Get Test Case
# Add your code into this method and it will be called when step runs
# Parameter: config
# Parameter: caseId

sub getTestCase {
    my ($pluginObject) = @_;

    my $context = $pluginObject->getContext();
    my $params = $context->getRuntimeParameters();

    my $QAPerlTestRailRESTClient = $pluginObject->getQAPerlTestRailRESTClient;

    # Setting default parameters
    $params->{resultFormat} ||= 'json';
    $params->{resultPropertySheet} ||= '/myJob/caseId';

    my $caseId = $params->{'caseId'};

    # If you have changed your parameters in the procedure declaration, add/remove them here
    my %restParams = (
        'caseId' => $params->{'caseId'},
    );
    my $response = $QAPerlTestRailRESTClient->getTestCase(%restParams);
    logInfo("Got response from the server: ", $response);

    my $stepResult = $context->newStepResult;

    logInfo("Created stepResult");
    $stepResult->setOutputParameter('caseJSON', encode_json($response));
    $stepResult->setOutputParameter('caseId', $response->{id});
    logInfo("Test Case information was saved to properties.");

    $stepResult->setJobStepOutcome('success');
    $stepResult->setJobStepSummary('Case found: #' . $response->{id});
    $stepResult->setJobSummary("Info about Test Case: #$caseId has been saved to property(ies)");

    logInfo("Set stepResult");

    $stepResult->apply();
}

# This method is used to access auto-generated REST client.
sub getQAPerlTestRailRESTClient {
    my ($self) = @_;

    my $context = $self->getContext();
    my $config = $context->getRuntimeParameters();
    require FlowPlugin::QAPerlTestRailRESTClient;
    my $client = FlowPlugin::QAPerlTestRailRESTClient->createFromConfig($config);
    return $client;
}
# Auto-generated method for the procedure Create Test Case/Create Test Case
# Add your code into this method and it will be called when step runs
# Parameter: config
# Parameter: title
# Parameter: template_id
# Parameter: type_id
# Parameter: priority_id
# Parameter: estimate
# Parameter: refs
# Parameter: content
# Parameter: expected
# Parameter: sectionId

sub createTestCase {
    my ($pluginObject) = @_;
   
    my $context = $pluginObject->getContext();
    my $params = $context->getRuntimeParameters();
    my $caseId = $params->{'caseId'};

    my $QAPerlTestRailRESTClient = $pluginObject->getQAPerlTestRailRESTClient;

    # If you have changed your parameters in the procedure declaration, add/remove them here
    my %restParams = (
        'title' => $params->{'title'},
        'template_id' => $params->{'template_id'},
        'type_id' => $params->{'type_id'},
        'priority_id' => $params->{'priority_id'},
        'estimate' => $params->{'estimate'},
        'refs' => $params->{'refs'},
        'content' => $params->{'content'},
        'expected' => $params->{'expected'},
        'sectionId' => $params->{'sectionId'},
    );
    my $response = $QAPerlTestRailRESTClient->createTest(%restParams);
    return unless defined $response;
    logInfo("Got response from the server: ", $response);

    my $stepResult = $context->newStepResult;
    $stepResult->setOutputParameter('caseJSON', encode_json($response));
    $stepResult->setOutputParameter('caseId', $response->{id});

    logInfo("Test Case information was saved to properties.");

    $stepResult->setJobStepOutcome('success');
    $stepResult->setJobStepSummary("Test Case: #'$response->{id}' created under section: #'$params->{sectionId}'");
    $stepResult->setJobSummary("Info about Test Case: #$caseId has been saved to property(ies)");

    logInfo("Set stepResult");

    $stepResult->apply();
}


# Auto-generated method for the procedure Update Test Case/Update Test Case
# Add your code into this method and it will be called when step runs
# Parameter: config
# Parameter: title
# Parameter: template_id
# Parameter: type_id
# Parameter: priority_id
# Parameter: estimate
# Parameter: refs
# Parameter: content
# Parameter: expected
# Parameter: caseId

sub updateTestCase {
    my ($pluginObject) = @_;

    my $context = $pluginObject->getContext();
    my $params = $context->getRuntimeParameters();

    my $QAPerlTestRailRESTClient = $pluginObject->getQAPerlTestRailRESTClient;

    # If you have changed your parameters in the procedure declaration, add/remove them here
    my %restParams = (
        'title' => $params->{'title'},
        'template_id' => $params->{'template_id'},
        'type_id' => $params->{'type_id'},
        'priority_id' => $params->{'priority_id'},
        'estimate' => $params->{'estimate'},
        'refs' => $params->{'refs'},
        'content' => $params->{'content'},
        'expected' => $params->{'expected'},
        'caseId' => $params->{'caseId'},
    );
    my $response = $QAPerlTestRailRESTClient->updateTest(%restParams);
    logInfo("Got response from the server: ", $response);

    my $stepResult = $context->newStepResult;
    $stepResult->setOutputParameter('caseJSON', encode_json($response));
    $stepResult->setOutputParameter('caseId', $response->{id});
    logInfo("Test Case: #'$response->{id}' updated");

    $stepResult->setJobStepOutcome('success');
    $stepResult->setJobStepSummary("Test Case: #$response->{id} updated under section: #$params->{sectionId}");
    $stepResult->setJobSummary("Info about Test Case: #$response->{id} has been saved to property(ies)");

    logInfo("Set stepResult");

    $stepResult->apply();
}

# Auto-generated method for the procedure Get Test Case CLI/Get Test Case CLI
# Add your code into this method and it will be called when step runs
sub getTestCaseCLI {
    my ($self) = @_;

    my $context = $self->newContext();
    print "Current context is: ", $context->getRunContext(), "\n";
    my $params = $context->getStepParameters();

    my $configValues = $context->getConfigValues();
    my $cred = $configValues->getParameter('basic_credential');
    my ($username, $password);
    print "Creds: '$cred'";
    if ($cred) {
        $username = $cred->getUserName();
        $password = $cred->getSecretValue();
    }
    my $caseID =  $params->getParameter('caseId')->getValue();
    my $endpoint = $configValues->getRequiredParameter('endpoint')->getValue();
    my $cli = FlowPDF::ComponentManager->loadComponent('FlowPDF::Component::CLI', {
        workingDirectory => $ENV{COMMANDER_WORKSPACE}
    });
    my $command = $cli->newCommand('curl');
    $command->addArguments("-k");
    $command->addArguments("-H");
    $command->addArguments("Content-Type: application/json");
    $command->addArguments("-u");
    $command->addArguments("$username:$password");
    $command->addArguments("$endpoint/get_case/$caseID");

    my $res = $cli->runCommand($command);
    print "STDOUT: " . $res->getStdout();
    print "STDERR: " . $res->getStderr();

    my $resultJSON = $res->getStdout();

    my $stepResult = $context->newStepResult();
    $stepResult->setOutputParameter('caseId', $caseID);
    $stepResult->setOutputParameter('caseJSON', $resultJSON );
    $stepResult->setJobStepSummary("Get test case: $caseID");
    $stepResult->apply();
}
# Auto-generated method for the procedure Create Test Case CLI/Create Test Case CLI
# Add your code into this method and it will be called when step runs
sub createTestCaseCLI {
    my ($self) = @_;

    my $context = $self->newContext();
    print "Current context is: ", $context->getRunContext(), "\n";
    my $params = $context->getStepParameters();

    my $configValues = $context->getConfigValues();
    my $cred = $configValues->getParameter('basic_credential');
    my ($username, $password);
    print "Creds: '$cred'";
    if ($cred) {
        $username = $cred->getUserName();
        $password = $cred->getSecretValue();
    }

    my $json = $params->getParameter('json')->getValue();
    my $sectionId = $params->getParameter('sectionId')->getValue();
    my $endpoint = $configValues->getRequiredParameter('endpoint')->getValue();
    my $cli = FlowPDF::ComponentManager->loadComponent('FlowPDF::Component::CLI', {
        workingDirectory => $ENV{COMMANDER_WORKSPACE}
    });
    my $command = $cli->newCommand('curl');
    $command->addArguments("-k");
    $command->addArguments("-d");
    $command->addArguments("$json");
    $command->addArguments("-H");
    $command->addArguments("Content-Type: application/json");
    $command->addArguments("-u");
    $command->addArguments("$username:$password");
    $command->addArguments("$endpoint/add_case/$sectionId");

    my $res = $cli->runCommand($command);
    print "STDOUT: " . $res->getStdout();
    print "STDERR: " . $res->getStderr();

    my $resultJSON = $res->getStdout();
    my $decodeJSON = decode_json $resultJSON;
    my $caseId = $decodeJSON->{id};

    my $stepResult = $context->newStepResult();
    $stepResult->setOutputParameter('caseId', $caseId);
    $stepResult->setOutputParameter('caseJSON', $resultJSON );
    $stepResult->setJobStepSummary("Create test case: $caseId" );
    $stepResult->apply();
}
# Auto-generated method for the procedure Update Test Case CLI/Update Test Case CLI
# Add your code into this method and it will be called when step runs
sub updateTestCaseCLI {
    my ($self) = @_;

    my $context = $self->newContext();
    print "Current context is: ", $context->getRunContext(), "\n";
    my $params = $context->getStepParameters();

    my $configValues = $context->getConfigValues();
    my $cred = $configValues->getParameter('basic_credential');
    my ($username, $password);
    print "Creds: '$cred'";
    if ($cred) {
        $username = $cred->getUserName();
        $password = $cred->getSecretValue();
    }

    my $json = $params->getParameter('json')->getValue();
    my $caseId = $params->getParameter('caseId')->getValue();
    my $endpoint = $configValues->getRequiredParameter('endpoint')->getValue();
    my $cli = FlowPDF::ComponentManager->loadComponent('FlowPDF::Component::CLI', {
        workingDirectory => $ENV{COMMANDER_WORKSPACE}
    });
    my $command = $cli->newCommand('curl');
    $command->addArguments("-k");
    $command->addArguments("-d");
    $command->addArguments("$json");
    $command->addArguments("-H");
    $command->addArguments("Content-Type: application/json");
    $command->addArguments("-u");
    $command->addArguments("$username:$password");
    $command->addArguments("$endpoint/update_case/$caseId");

    my $res = $cli->runCommand($command);
    print "STDOUT: " . $res->getStdout();
    print "STDERR: " . $res->getStderr();

    my $resultJSON = $res->getStdout();
    my $decodeJSON = decode_json $resultJSON;
    # my $caseId = $decodeJSON->{id};

    my $stepResult = $context->newStepResult();
    $stepResult->setOutputParameter('caseId', $caseId);
    $stepResult->setOutputParameter('caseJSON', $resultJSON );
    $stepResult->setJobStepSummary("update test case: $caseId" );
    $stepResult->apply();
}
## === step ends ===
# Please do not remove the marker above, it is used to place new procedures into this file.


1;