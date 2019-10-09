## === rest client imports starts ===
package FlowPlugin::TestRailRestRESTClient;
use strict;
use warnings;
use LWP::UserAgent;
use JSON;
use Data::Dumper;
use FlowPDF::Client::REST;
use FlowPDF::Log;
## === rest client imports ends, checksum: 28ba73bcffc3263f33b086d52b312670 ===
# Place for the custom user imports, e.g. use File::Spec
## === rest client starts ===
=head1

FlowPlugin::TestRailRestRESTClient->new('http://endpoint', {
    auth => {basicAuth => {userName => 'admin', password => 'changeme'}}
})

=cut

# Generated
use constant {
    BEARER_PREFIX => 'Bearer',
    USER_AGENT => 'TestRailRestRESTClient REST Client',
    OAUTH1_SIGNATURE_METHOD =>  'RSA-SHA1' ,
    CONTENT_TYPE => 'application/json'
};

=pod

Use this method to create a new FlowPlugin::TestRailRestRESTClient, e.g.

    my $client = FlowPlugin::TestRailRestRESTClient->new($endpoint,
        basicAuth => {userName => 'user', password => 'password'}
    );

    my $client = FlowPlugin::TestRailRestRESTClient->new($endpoint,
        bearerAuth => {token => 'token'}
    )

    my $client = FlowPlugin::TestRailRestRESTClient->new($endpoint,
        bearerAuth => {token => 'token'},
        proxy => {url => 'proxy url', username => 'proxy user', password => 'password'}
    )

=cut

sub new {
    my ($class, $endpoint, %params) = @_;

    my $self = { %params };
    $self->{endpoint} = $endpoint;
    if ($self->{basicAuth}) {
        logDebug("Basic Auth Scheme");
        unless($self->{basicAuth}->{userName}) {
            die "No username was provided for the Basic auth";
        }
        unless($self->{basicAuth}->{password}) {
            die "No password was provided for the Basic auth";
        }
    }
    elsif ($self->{bearerAuth}) {
        logDebug("Bearer Auth Scheme");
        unless($self->{bearerAuth}->{token}) {
            die 'No token was provided for the Bearer auth';
        }
    }
    elsif ($self->{oauth1}) {
        logDebug("OAuth 1.0 Auth Scheme");
        unless($self->{oauth1}->{token}) {
            die 'No token is provided for OAuth1 scheme';
        }
        unless($self->{oauth1}->{consumerKey}) {
            die 'No consumerKey is provided for Oauth1 scheme';
        }
        unless ($self->{oauth1}->{privateKey}) {
            die 'No privateKey is provided for oauth1 scheme';
        }
    }
    if ($self->{proxy}) {
        my $url = $self->{proxy}->{url};
        unless($url) {
            die "No URL was provided for the proxy configuration";
        }
        if ($self->{proxy}->{username} && !$self->{proxy}->{password}) {
            die "Username and password should be provided for the proxy auth";
        }
    }

    return bless $self, $class;
}

# This is the simplified form to create the REST client object directly from the plugin configuration
sub createFromConfig {
    my ($class, $configParams) = @_;

    my $endpoint = $configParams->{endpoint};

    my %construction_params = ();
    if  ($configParams->{httpProxyUrl}) {
        $construction_params{proxy} = {
            url => $configParams->{httpProxyUrl},
            username => $configParams->{proxy_user},
            password => $configParams->{proxy_password},
        }
    }
    unless($endpoint) {
        die "No endpoint parameter is provided";
    }
    if ($configParams->{basic_user} && $configParams->{basic_password}) {
        $construction_params{basicAuth} = {
            userName => $configParams->{basic_user},
            password => $configParams->{basic_password}
        };
        return $class->new($endpoint, %construction_params);
    }
    elsif ($configParams->{bearer_password}) {
        $construction_params{bearerAuth} = {
            token => $configParams->{bearer_password},
        };
        return $class->new($endpoint, %construction_params);
    }
    elsif ($configParams->{authScheme} eq 'anonymous') {
        return $class->new($endpoint, %construction_params);
    }
    elsif ($configParams->{oauth1_user}) {
        $construction_params{oauth1} = {
            privateKey => $configParams->{oauth1_password},
            token => $configParams->{oauth1_user},
            consumerKey => $configParams->{oauth1ConsumerKey},
        };
        return $class->new($endpoint, %construction_params);
    }
    return $class->new($endpoint, %$configParams, %construction_params);
}

sub makeRequest {
    my ($self, $method, $uri, $query, $payload, $headers) = @_;

    my $request = $self->createRequest($method, $uri, $query, $payload, $headers);
    # generic augment
    $request = $self->augmentRequest($request);
    my $response = $self->rest->doRequest($request);
    my $retval = $self->processResponse($response);
    if ($retval) {
        return $retval;
    }
    if ($response->is_success) {
        my $parsed = $self->parseResponse($response);
        return $parsed;
    }
    else {
        die "Request for $uri failed: " . $response->status_line;
    }
}

sub method {
    return shift->{method};
}

sub rest {
    my ($self, %params) = @_;

    my $requestMethod = $params{requestMethod} || 'POST';
    unless ($self->{rest}->{$requestMethod}) {
        my $p = {
        };
        $p->{ua} = LWP::UserAgent->new(agent => USER_AGENT);

          # agent                   "libwww-perl/#.###"
          # from                    undef
          # conn_cache              undef
          # cookie_jar              undef
          # default_headers         HTTP::Headers->new
          # local_address           undef
          # ssl_opts                { verify_hostname => 1 }
          # max_size                undef
          # max_redirect            7
          # parse_head              1
          # protocols_allowed       undef
          # protocols_forbidden     undef
          # requests_redirectable   ['GET', 'HEAD']
          # timeout                 180

        if ($self->{proxy}) {
            $p->{proxy} = $self->{proxy};
        }
        if ($self->{oauth1}) {
            my $oauth = $self->{oauth1};
            $p->{oauth} = {
                oauth_version => '1.0',
                oauth_signature_method => OAUTH1_SIGNATURE_METHOD,
                request_method => $requestMethod,
                request_token_path => 'plugins/servlet/oauth/request-token',
                base_url => $self->{endpoint},
                # todo validate
                private_key => $oauth->{privateKey},
                oauth_token => $oauth->{token},
                oauth_consumer_key => $oauth->{consumerKey},
            };
        }
        $self->{rest} = FlowPDF::Client::REST->new($p);
    }
    return $self->{rest};
}

sub createRequest {
    my ($self, $method, $uri, $query, $payload, $headers) = @_;

    $uri =~ s{^/+}{};
    my $endpoint = $self->{endpoint};
    $endpoint =~ s{/+$}{};

    my $rest = $self->rest(requestMethod => $method);
    my $url = URI->new($endpoint . "/$uri");

    if ($query) {
        $url->query_form($url->query_form, %$query);
    }

    if ($self->{oauth1}) {
        require FlowPDF::ComponentManager;
        my $oauth = FlowPDF::ComponentManager->getComponent('FlowPDF::Component::OAuth');
        my $requestParams = $oauth->augment_params_with_oauth($method, $url, $query);
        $url = $rest->augmentUrlWithParams($url, $requestParams);
    }
    my $request = $rest->newRequest($method => $url);

    # auth
    if ($self->{basicAuth}) {
        my $auth = $self->{basicAuth};
        my $username = $auth->{userName};
        my $password = $auth->{password};
        $request->authorization_basic($username, $password);
        logDebug("Added basic auth");
    }
    if ($self->{bearerAuth}) {
        my $auth = $self->{bearerAuth};
        my $token = $auth->{token};
        my $prefix = BEARER_PREFIX;
        $request->header("Authorization", "$prefix $token");
        logDebug("Added bearer auth");
    }

    if ($method eq 'POST' || $method eq 'PUT') {
        $request->header('Content-Type' => CONTENT_TYPE);
    }

    if ($headers) {
        for my $headerName (keys %$headers) {
            $request->header($headerName => $headers->{$headerName});
        }
    }

    if ($payload) {
        logDebug("Payload:", $payload);
        my $encoded = $self->encodePayload($payload);
        $request->content($encoded);
    }

    # proxy should be handled somewhere in the rest
    logDebug("Request: ", $request);

    my $augmentMethod = $self->method . 'AugmentRequest';
    if ($self->can($augmentMethod)) {
        $request = $self->$augmentMethod($request);
    }

    return $request;
}

sub cleanEmptyFields {
    my ($self, $payload) = @_;

    for my $key (keys %$payload) {
        unless ($payload->{$key}) {
            delete $payload->{$key};
        }
        if (ref $payload->{$key} eq 'HASH') {
            $payload->{$key} = $self->cleanEmptyFields($payload->{$key});
        }
    }
    return $payload;
}

sub populateFields {
    my ($self, $object, $params) = @_;

    my $render = sub {
        my ($string) = @_;

        no warnings;
        $string =~ s/(\{\{(\w+)\}\})/$params->{$2}/;
        return $string;
    };

    for my $key (keys %$object) {
        my $value = $object->{$key};
        if (ref $value) {
            if (ref $value eq 'HASH') {
                $object->{$key} = $self->populateFields($value, $params);
            }
            elsif (ref $value eq 'ARRAY') {
                for my $row (@$value) {
                    $row = $self->populateFields($row, $params);
                    # todo fix ref
                }
            }
        }
        else {
            $object->{$key} = $render->($value);
        }
    }
    return $object;
}

sub renderOneLineTemplate {
    my ($template, %params) = @_;

    for my $key (keys %params) {
        $template =~ s/\{\{$key\}\}/$params{$key}/g;
    }
    return $template;
}

# Generated code for the endpoint

# Do not change this code

# caseId: in path

sub getTestCase {
    my ($self, %params) = @_;

    my $override = $self->can("getTestCaseOverride");
    if ($override) {
        return $self->$override(%params);
    }

    my $uri = "/get_case/{{caseId}}";
    $uri = renderOneLineTemplate($uri, %params);
    my $query = {

    };

    # TODO handle credentials
    my $payload = {

    };
    logDebug($payload);

    $self->{method} = 'getTestCase';

    my $headers = {
    };

    $headers->{'Content-Type'} = 'application/json';

    # Creating a request object
    my $response = $self->makeRequest('GET', $uri, $query, $payload, $headers);
    return $response;
}

# Generated code for the endpoint

# Do not change this code

# json: in body

# sectionId: in path

sub createTest {
    my ($self, %params) = @_;

    my $override = $self->can("createTestOverride");
    if ($override) {
        return $self->$override(%params);
    }

    my $uri = "/add_case/{{sectionId}}";
    $uri = renderOneLineTemplate($uri, %params);
    my $query = {

    };

    # TODO handle credentials
    # my $payload = {

    #     'json' => $params{ json },

    # };
    # logDebug($payload);
    my $payload = $params{ json };

    $self->{method} = 'createTest';

    my $headers = {
    };

    $headers->{'Content-Type'} = 'application/json';

    # Creating a request object
    my $response = $self->makeRequest('POST', $uri, $query, $payload, $headers);
    return $response;
}

# Generated code for the endpoint

# Do not change this code

# caseId: in path

# json: in body

sub updateTest {
    my ($self, %params) = @_;

    my $override = $self->can("updateTestOverride");
    if ($override) {
        return $self->$override(%params);
    }

    my $uri = "/update_case/{{caseId}}";
    $uri = renderOneLineTemplate($uri, %params);
    my $query = {

    };

    # TODO handle credentials
    # my $payload = {

    #     'json' => $params{ json },

    # };
    my $payload = $params{ json };

    logDebug($payload);

    $self->{method} = 'updateTest';

    my $headers = {
    };

    $headers->{'Content-Type'} = 'application/json';

    # Creating a request object
    my $response = $self->makeRequest('POST', $uri, $query, $payload, $headers);
    return $response;
}
## === rest client ends, checksum: 2b7e863da1df8873ce2b3189a8ffa186 ===
=pod

Use ths method to change HTTP::Request object before the request, e.g.

    $r->header('Authorization', $myCustomAuthHeader);

If you are using custom authorization, it can be placed in here.

=cut

sub augmentRequest {
    my ($self, $r) = @_;
    # empty, for user to fill
    return $r;
}

=pod

Use this method to override default payload encoding.
By default the payload is encoded as JSON.

=cut

sub encodePayload {
    my ($self, $payload) = @_;

    return encode_json($payload);
}

=pod

Use this method to change process response logic.

=cut

sub processResponse {
    my ($self, $response) = @_;

    return undef;
}

=pod

Use this method to override default response decoding logic.
By default the response is decoded as JSON.

=cut

sub parseResponse {
    my ($self, $response) = @_;

    if ($response->content) {
        return decode_json($response->content);
    }
}

1;