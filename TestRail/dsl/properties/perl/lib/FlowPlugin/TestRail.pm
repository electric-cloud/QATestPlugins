package FlowPlugin::TestRail;
use strict;
use warnings;
use base qw/FlowPDF/;
use Data::Dumper;



# Feel free to use new libraries here, e.g. use File::Temp;
use FlowPDF::Log;
use FlowPDF::ComponentManager;
use FlowPDF::Helpers qw/bailOut/;
use FlowPlugin::REST;

use JSON;
# use JSON qw/decode_json/;
# use JSON qw/encode_json/;

# Service function that is being used to set some metadata for a plugin.
sub pluginInfo {
    return {
        pluginName      => '@PLUGIN_KEY@',
        pluginVersion   => '@PLUGIN_VERSION@',
        configFields    => [ 'config' ],
        configLocations => [ 'ec_plugin_cfgs' ]
    };
}

sub init {
    my ($self, $params) = @_;

    my FlowPDF::Context $context = $self->getContext();

    my $rest = FlowPlugin::REST->new($context, {
        APIBase     => '/index.php?/api/v2/',
        contentType => 'application/json',
        errorHook   => {
            default => sub {
                return $self->defaultErrorHandler(@_)
            }
        }
    });
    # Test Rail requires Content-Type header to be present even if no content was provided
    $rest->{headers}{'Content-Type'} = 'application/json';

    $self->{restClient} = $rest;
}

sub config {return shift->{_config}};

#@returns FlowPlugin::REST
sub client {return shift->{restClient}};

=head2 getTestCase

Documentation for getTestCase

=cut
# Auto-generated method for the procedure Get Test Case
# Add your code into this method and it will be called when step runs
sub getTestCase {
    my ($pluginObject) = @_;

    my $context = $pluginObject->newContext();
    print "Current context is: ", $context->getRunContext(), "\n";
    # my $params = $context->getStepParameters();
    # print Dumper $params;
    my FlowPDF $self = shift;
    my $params = shift;
    # print Dumper $params;
    my FlowPDF::StepResult $stepResult = shift;
    $self->init($params);
    logInfo("Init complete");

    # Setting default parameters
    $params->{resultFormat} ||= 'json';
    $params->{resultPropertySheet} ||= '/myJob/caseId';

    my $caseId = $params->{caseId};

    logInfo("requesting info");
    my $response = $self->client->get("get_case/$caseId", undef, undef, {
        errorHook => {
            400 => sub {
                $stepResult->setJobStepOutcome('error');
                $stepResult->setJobSummary("Case '$caseId' was not found");
                $stepResult->setJobStepSummary("Case '$caseId' was not found");
                return;
            }
        }
    });

    return unless defined $response;
    logInfo("Found Test Case: '$response->{id}'");

    # my $infoToSave = $response;

    # # Save to a properties
    # $self->saveResultProperties(
    #     $stepResult,
    #     $params->{resultFormat},
    #     $params->{resultPropertySheet},
    #     $infoToSave
    # );

    # Saving outcome properties and parameters
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

=head2 getTestCase

Documentation for createTestCase

=cut

# Auto-generated method for the procedure Create Test Case/Create Test Case
# Add your code into this method and it will be called when step runs
sub createTestCase {
    my ($pluginObject) = @_;

    my $context = $pluginObject->newContext();
    print "Current context is: ", $context->getRunContext(), "\n";
    # my $params = $context->getStepParameters();
    # print Dumper $params;
    my FlowPDF $self = shift;
    my $params = shift;
    # print Dumper $params;
    my FlowPDF::StepResult $stepResult = shift;
    $self->init($params);

    # Setting default parameters
    $params->{resultFormat} ||= 'json';
    my $payload = decode_json $params->{json};
    # if (!exists $payload->{Test}){
    #
    # }
    my $createTestCase = $self->client->post("add_case/$params->{sectionId}", undef, $payload);

    return unless defined $createTestCase;
    logInfo("Test Case: #'$createTestCase->{id}' created under section: #$params->{sectionId}");

    print "Created stepResult\n";

    $stepResult->setOutputParameter('caseId', $createTestCase->{id});
    $stepResult->setOutputParameter('caseJSON', encode_json $createTestCase);
    logInfo("Plan(s) information was saved to properties.");

    $stepResult->setJobStepOutcome('success');
    $stepResult->setJobStepSummary("Test Case: #$createTestCase->{id} created under section: #$params->{sectionId}");
    $stepResult->setJobSummary("Info about Test Case: #$createTestCase->{id} has been saved to property(ies)");

    print "Set stepResult\n";

    $stepResult->apply();
}

=head2 getTestCase

Documentation for updateTestCase

=cut

# Auto-generated method for the procedure Update Test Case/Update Test Case
# Add your code into this method and it will be called when step runs
sub updateTestCase {
    my ($pluginObject) = @_;

    my $context = $pluginObject->newContext();
    print "Current context is: ", $context->getRunContext(), "\n";
    # my $params = $context->getStepParameters();
    # print Dumper $params;
    my FlowPDF $self = shift;
    my $params = shift;
    # print Dumper $params;
    my FlowPDF::StepResult $stepResult = shift;
    $self->init($params);

    # Setting default parameters
    $params->{resultFormat} ||= 'json';
    my $payload = decode_json $params->{json};
    # if (!exists $payload->{Test}){
    #
    # }
    my $updateTestCase = $self->client->post("update_case/$params->{caseId}", undef, $payload);
    return unless defined $updateTestCase;
    logInfo("Created case: '$updateTestCase->{id}'");

    print "Created stepResult\n";
    $stepResult->setOutputParameter('caseId', $updateTestCase->{id});
    $stepResult->setOutputParameter('caseJSON', encode_json $updateTestCase);
    logInfo("Test Case: #'$updateTestCase->{id}' updated");

    $stepResult->setJobStepOutcome('success');
    $stepResult->setJobStepSummary("Test Case: #$updateTestCase->{id} updated");
    $stepResult->setJobSummary("Info about Test Case: #$updateTestCase->{id} has been saved to property(ies)");

    print "Set stepResult\n";

    $stepResult->apply();
}

sub defaultErrorHandler {
    my FlowPDF $self = shift;
    my ($response, $decoded) = @_;

    logDebug(Dumper \@_);

    if (!$decoded || !$decoded->{message}) {
        $decoded->{message} = 'No specific error message was returned. Check logs for details';
        logError($response->decoded_content || 'No content returned');
    }

    my FlowPDF::StepResult $stepResult = $self->getContext()->newStepResult();
    $stepResult->setJobStepOutcome('error');
    $stepResult->setJobStepSummary($decoded->{message});
    $stepResult->setJobSummary("Error happened while performing the operation: '$decoded->{message}'");
    $stepResult->apply();

    return;
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
    $command->addArguments("-H");
    $command->addArguments("Content-Type: application/json");
    $command->addArguments("-u");
    $command->addArguments("$username:$password");
    $command->addArguments("$endpoint/index.php?/api/v2/get_case/$caseID");

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
    $command->addArguments("-d");
    $command->addArguments("$json");
    $command->addArguments("-H");
    $command->addArguments("Content-Type: application/json");
    $command->addArguments("-u");
    $command->addArguments("$username:$password");
    $command->addArguments("$endpoint/index.php?/api/v2/add_case/$sectionId");

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
    $command->addArguments("-d");
    $command->addArguments("$json");
    $command->addArguments("-H");
    $command->addArguments("Content-Type: application/json");
    $command->addArguments("-u");
    $command->addArguments("$username:$password");
    $command->addArguments("$endpoint/index.php?/api/v2/update_case/$caseId");

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