package FlowPlugin::QAPerlJira;
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

# Auto-generated method for the procedure Get Issue Types/Get Issue Types
# Add your code into this method and it will be called when step runs
# Parameter: config

sub getIssueTypes {
    my ($pluginObject) = @_;

    my $context = $pluginObject->getContext();
    my $params = $context->getRuntimeParameters();

    my $QAPerlJiraRESTClient = $pluginObject->getQAPerlJiraRESTClient;
    # If you have changed your parameters in the procedure declaration, add/remove them here
    my %restParams = (
    );
    my $response = $QAPerlJiraRESTClient->getIssueTypes(%restParams);
    logInfo("Got response from the server: ", $response);

    my $stepResult = $context->newStepResult;

    $stepResult->apply();
}

# This method is used to access auto-generated REST client.
sub getQAPerlJiraRESTClient {
    my ($self) = @_;

    my $context = $self->getContext();
    my $config = $context->getRuntimeParameters();
    require FlowPlugin::QAPerlJiraRESTClient;
    my $client = FlowPlugin::QAPerlJiraRESTClient->createFromConfig($config);
    return $client;
}
## === step ends ===
# Please do not remove the marker above, it is used to place new procedures into this file.


1;