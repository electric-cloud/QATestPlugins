## DO NOT EDIT THIS BLOCK === rest client imports starts ===
package FlowPlugin::QAPerlTestRailRESTClient;
use strict;
use warnings;
use LWP::UserAgent;
use JSON;
use Data::Dumper;
use FlowPDF::Client::REST;
use FlowPDF::Log;
## DO NOT EDIT THIS BLOCK === rest client imports ends, checksum: 63de35011b9703e8beb3af8c5d312da4 ===
# Place for the custom user imports, e.g. use File::Spec
## DO NOT EDIT THIS BLOCK === rest client starts ===
=head1

FlowPlugin::QAPerlTestRailRESTClient->new('http://endpoint', {
    auth => {basicAuth => {userName => 'admin', password => 'changeme'}}
})

=cut

# Generated
use constant {
    BEARER_PREFIX => 'Bearer',
    USER_AGENT => 'QA plugin',
    OAUTH1_SIGNATURE_METHOD =>  'RSA-SHA1' ,
    CONTENT_TYPE => 'application/json'
};

=pod

Use this method to create a new FlowPlugin::QAPerlTestRailRESTClient, e.g.

    my $client = FlowPlugin::QAPerlTestRailRESTClient->new($endpoint,
        basicAuth => {userName => 'user', password => 'password'}
    );

    my $client = FlowPlugin::QAPerlTestRailRESTClient->new($endpoint,
        bearerAuth => {token => 'token'}
    )

    my $client = FlowPlugin::QAPerlTestRailRESTClient->new($endpoint,
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
    elsif ($configParams->{authScheme} && $configParams->{authScheme} eq 'anonymous') {
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
    my ($self, $method, $uri, $query, $payload, $headers, $params) = @_;

    my $request = $self->createRequest($method, $uri, $query, $payload, $headers);
    logDebug("Request before augment", $request);
    # generic augment
    $request = $self->augmentRequest($request, $params);
    logDebug("Request after augment", $request);
    my $response = $self->rest->doRequest($request);
    logDebug("Response", $response);
    my $retval = $self->processResponse($response, $params);
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

=pod

Returns the name of the caller method.
Intended to be used in the user-defined methods.

=cut

sub method {
    return shift->{method};
}

=pod

Returns the original parameters passed to the caller method.
Intended to be used in the user-defined methods.

=cut

sub methodParameters {
    return shift->{methodParameters};
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
            $p->{auth} = {
                type => 'oauth',
                oauth_version => '1.0',
                oauth_signature_method => OAUTH1_SIGNATURE_METHOD,
                request_method => $requestMethod,
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
    my $url;
    if ($uri) {
        $url = URI->new($endpoint . "/$uri");
    }
    else {
        $url = URI->new($endpoint);
    }

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

sub getProjects {
    my ($self, %params) = @_;

    $self->{method} = 'getProjects';
    $self->{methodParameters} = \%params;

    my $uri = "/api/v2/get_projects";
    logDebug "URI Template: $uri";
    $uri = renderOneLineTemplate($uri, %params);
    logDebug "Rendered URI: $uri";

    my $query = {

    };

    logDebug "Query", $query;

    # TODO handle credentials
    # TODO Handle empty parameters
    my $payload = {

    };
    logDebug($payload);

    $payload = $self->cleanEmptyFields($payload);

    my $headers = {
    };

    $headers->{'Content-Type'} = 'application/json';

    # Creating a request object
    my $response = $self->makeRequest('GET', $uri, $query, $payload, $headers, \%params);
    return $response;
}

# Generated code for the endpoint

# Do not change this code

# caseId: in path

sub getTestCase {
    my ($self, %params) = @_;

    $self->{method} = 'getTestCase';
    $self->{methodParameters} = \%params;

    my $uri = "/get_case/{{caseId}}";
    logDebug "URI Template: $uri";
    $uri = renderOneLineTemplate($uri, %params);
    logDebug "Rendered URI: $uri";

    my $query = {

    };

    logDebug "Query", $query;

    # TODO handle credentials
    # TODO Handle empty parameters
    my $payload = {

    };
    logDebug($payload);

    $payload = $self->cleanEmptyFields($payload);

    my $headers = {
    };

    $headers->{'Content-Type'} = 'application/json';

    # Creating a request object
    my $response = $self->makeRequest('GET', $uri, $query, $payload, $headers, \%params);
    return $response;
}

# Generated code for the endpoint

# Do not change this code

# title: in body

# template_id: in body

# type_id: in body

# priority_id: in body

# estimate: in body

# refs: in body

# content: in body

# expected: in body

# sectionId: in path

sub createTest {
    my ($self, %params) = @_;

    $self->{method} = 'createTest';
    $self->{methodParameters} = \%params;

    my $uri = "/add_case/{{sectionId}}";
    logDebug "URI Template: $uri";
    $uri = renderOneLineTemplate($uri, %params);
    logDebug "Rendered URI: $uri";

    my $query = {

    };

    logDebug "Query", $query;

    # TODO handle credentials
    # TODO Handle empty parameters
    my $payload = {

        'title' => $params{ title },

        'template_id' => $params{ template_id },

        'type_id' => $params{ type_id },

        'priority_id' => $params{ priority_id },

        'estimate' => $params{ estimate },

        'refs' => $params{ refs },

        'content' => $params{ content },

        'expected' => $params{ expected },

    };
    logDebug($payload);

    $payload = $self->cleanEmptyFields($payload);

    my $headers = {
    };

    $headers->{'Content-Type'} = 'application/json';

    # Creating a request object
    my $response = $self->makeRequest('POST', $uri, $query, $payload, $headers, \%params);
    return $response;
}

# Generated code for the endpoint

# Do not change this code

# title: in body

# template_id: in body

# type_id: in body

# priority_id: in body

# estimate: in body

# refs: in body

# content: in body

# expected: in body

# caseId: in path

sub updateTest {
    my ($self, %params) = @_;

    $self->{method} = 'updateTest';
    $self->{methodParameters} = \%params;

    my $uri = "/update_case/{{caseId}}";
    logDebug "URI Template: $uri";
    $uri = renderOneLineTemplate($uri, %params);
    logDebug "Rendered URI: $uri";

    my $query = {

    };

    logDebug "Query", $query;

    # TODO handle credentials
    # TODO Handle empty parameters
    my $payload = {

        'title' => $params{ title },

        'template_id' => $params{ template_id },

        'type_id' => $params{ type_id },

        'priority_id' => $params{ priority_id },

        'estimate' => $params{ estimate },

        'refs' => $params{ refs },

        'content' => $params{ content },

        'expected' => $params{ expected },

    };
    logDebug($payload);

    $payload = $self->cleanEmptyFields($payload);

    my $headers = {
    };

    $headers->{'Content-Type'} = 'application/json';

    # Creating a request object
    my $response = $self->makeRequest('POST', $uri, $query, $payload, $headers, \%params);
    return $response;
}
## DO NOT EDIT THIS BLOCK === rest client ends, checksum: 50046bb4dff2ff828a6c683a7e727262 ===
=pod

Use this method to change HTTP::Request object before the request, e.g.

    $r->header('Authorization', $myCustomAuthHeader);

If you are using custom authorization, it can be placed in here. Call $self->method to find out the wrapper
method name.

    $r HTTP::Request object to augment
    $params Original parameters passed to the wrapper method.

The returned HTTP::Request object will be sent to the API server.

Examples:

    if ($self->method eq 'uploadFile') {
        return $self->_handleUploadLogic($params);
    }

    my $method = $self->method;
    my $augmentMethod = $method . 'Augment';
    if ($self->can($augmentMethod)) {
        return $self->$augmentMethod($r, $params);
    }

=cut

sub augmentRequest {
    my ($self, $r, $params) = @_;
    # empty, for user to fill
    return $r;
}

=pod

Use this method to override default payload encoding.
By default the payload is encoded as JSON.

=cut

sub encodePayload {
    my ($self, $payload) = @_;
    my $params = $self->methodParameters();
    if ($self->method() eq 'createTest' || $self->method() eq 'updateTest') {
        my %content = ('content' => $params->{'content'}, 'expected' => $params->{'expected'});
        my $content_ref = \%content;
        my @some_array = ();
        push(@some_array, $content_ref);
        $payload->{'custom_steps_separated'} = [@some_array];
    }

    return encode_json($payload);
}

=pod

Use this method to change process response logic.

$response HTTP::Response object.

If this method returns a value, this value will be returned from the caller method.

Examples:

    unless ($response->is_success) {
        my $json = decode_json($response->content);
        my $errorMessage = $json->{errorMessage};
        die "Response failed: $errorMessage";
    }

    unless($response->is_success) {
        if ($self->{retries} < $retries) {
            $self->{retries} ++;
            my $p = $self->methodParameters;
            my $method = $self->method;
            return $self->$method($p);
        }
        else {
            die "Response failed and retries count has been exceeded";
        }
    }

=cut

sub processResponse {
    my ($self, $response) = @_;

    return undef;
}

=pod

Use this method to override default response decoding logic.
By default the response is decoded as JSON.

$response HTTP::Response object.

The method should return deserialized response.

=cut

sub parseResponse {
    my ($self, $response) = @_;

    if ($response->content) {
        return decode_json($response->content);
    }
}

1;