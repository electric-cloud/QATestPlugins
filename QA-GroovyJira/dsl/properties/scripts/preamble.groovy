import com.electriccloud.flowpdf.Context
import com.electriccloud.flowpdf.FlowPlugin
import com.electriccloud.flowpdf.StepParameters
import com.electriccloud.flowpdf.StepResult
import com.electriccloud.flowpdf.*
import com.electriccloud.flowpdf.client.*


/**
* {{pluginClassName}}
*/
class QAGroovyJira extends FlowPlugin {

    @Override
    Map<String, Object> pluginInfo() {
        log.setLogLevel(2)
        log.setLogToProperty('/myJobStep/ec_debug_log')

        return [
                pluginName     : '@PLUGIN_KEY@',
                pluginVersion  : '@PLUGIN_VERSION@',
                configFields   : ['config'],
                configLocations: ['ec_plugin_cfgs'],
                pluginValues: [
                    oauth: [
                            request_method        : 'POST',
                            oauth_signature_method: 'RSA-SHA1',
                            oauth_version         : '1.0',
                            request_token_path    : 'plugins/servlet/oauth/request-token',
                            authorize_token_path  : 'plugins/servlet/oauth/authorize',
                            access_token_path     : 'plugins/servlet/oauth/access-token',
                    ]
                ]
        ]
    }

    def getIssueTypes(StepParameters parameters, StepResult sr) {
        log.info("{{stepMethodName}} was invoked with StepParameters", parameters.toString())

        Context context = getContext()
        log.info("CONTEXT: " + context.getRunContext())       

        REST rest = context.newRESTClient()
        HTTPRequest request = rest.newRequest(
                method: 'GET',
                path: '/rest/api/latest/issuetype',
                contentType: 'JSON',
        )
        def json
        try {
            json = rest.doRequest(request)
            log.info("-------> json: $json")
        }
        catch(Exception e) {
            log.info("-------> error: $e")
            log.info("-------> json: $json")
            sr.setJobStepSummary("Job failed")
            sr.setJobStepOutcome("error")
            return
        }

        // Setting job step summary to the config name
        sr.setJobStepSummary("request has beed completed")
        sr.apply()
        log.info("step {{step.name}} has been finished")
    }


}