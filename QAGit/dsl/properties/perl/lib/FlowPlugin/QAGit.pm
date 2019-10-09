package FlowPlugin::QAGit;
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

# Auto-generated method for the procedure Get User Info/Get User Info
# Add your code into this method and it will be called when step runs
# Parameter: config

sub getUserInfo {
    my ($pluginObject) = @_;

    my $context = $pluginObject->getContext();
    my $params = $context->getRuntimeParameters();

    my $QAGitRESTClient = $pluginObject->getQAGitRESTClient;
    # If you have changed your parameters in the procedure declaration, add/remove them here
    my %restParams = (
    );
    my $response = $QAGitRESTClient->getGitUserInfo(%restParams);
    logInfo("Got response from the server: ", $response);

    my $stepResult = $context->newStepResult;

    $stepResult->apply();
}

# This method is used to access auto-generated REST client.
sub getQAGitRESTClient {
    my ($self) = @_;

    my $context = $self->getContext();
    my $config = $context->getRuntimeParameters();
    require FlowPlugin::QAGitRESTClient;
    my $client = FlowPlugin::QAGitRESTClient->createFromConfig($config);
    return $client;
}
## === step ends ===
# Please do not remove the marker above, it is used to place new procedures into this file.


1;