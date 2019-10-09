import com.electriccloud.flowpdf.Context
import com.electriccloud.flowpdf.FlowPlugin
import com.electriccloud.flowpdf.StepParameters
import com.electriccloud.flowpdf.StepResult
import com.electriccloud.flowpdf.*
import com.electriccloud.flowpdf.client.*
import com.electriccloud.flowpdf.components.CLI
import com.electriccloud.flowpdf.components.Component
import com.electriccloud.flowpdf.components.ComponentManager
import groovy.json.JsonSlurper


/**
* {{pluginClassName}}
*/
class QAGroovyTestRail extends FlowPlugin {

    @Override
    Map<String, Object> pluginInfo() {
        log.setLogLevel(2)
        log.setLogToProperty('/myJobStep/ec_debug_log')

        return [
                pluginName     : '@PLUGIN_KEY@',
                pluginVersion  : '@PLUGIN_VERSION@',
                configFields   : ['config'],
                configLocations: ['ec_plugin_cfgs']
        ]
    }

// === step template ===
    /**
    * {{stepMethodName}} - {{step.procedure.name}}/{{step.name}}
    * Add your code into this method and it will be called when the step runs
    {% for p in step.procedure.parameters %}
    * @param {{p.name}} (required: {{p.required}})
    {% endfor %}
    */
    def createTestCase(StepParameters parameters, StepResult sr) {
        log.info("{{stepMethodName}} was invoked with StepParameters", parameters.toString())

        Context context = getContext()
        log.info("CONTEXT: " + context.getRunContext())       
        // def parameters = context.getStepParameters()
        def sectionId = parameters.getParameter('sectionId')
        def body = parameters.getParameter('json')

        REST rest = context.newRESTClient()
        HTTPRequest request = rest.newRequest(
                method: 'POST',
                path: '/index.php',
                query: ["/api/v2/add_case/${sectionId}": ''],
                contentType: 'JSON',
                content: body
                // headers : ['content-type' : 'application/json']
        )
        request.setHeader('content-type', 'application/json')
        // log.info("request ${request.uri()}")
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
        sr.setJobStepSummary("Test case ${json.id.toString()} was created")

        sr.setOutputParameter('caseJSON', json.toString())
        sr.setOutputParameter('caseId', json.id.toString())

        sr.setOutcomeProperty('caseJSON', json.toString())
        sr.setOutcomeProperty('caseId', json.id.toString())

        sr.setReportUrl("test case link:", "https://ecflow.testrail.net/index.php?/cases/view/${json.id.toString()}")
        sr.apply()
        log.info("step {{step.name}} has been finished")
    }
// === step template ends ===
// === step ends ===


// === step template ===
    /**
    * {{stepMethodName}} - {{step.procedure.name}}/{{step.name}}
    * Add your code into this method and it will be called when the step runs
    {% for p in step.procedure.parameters %}
    * @param {{p.name}} (required: {{p.required}})
    {% endfor %}
    */
    def createTestCaseCLI(StepParameters parameters, StepResult sr) {
        log.info("{{stepMethodName}} was invoked with StepParameters", parameters.toString())

        Context context = getContext()
        log.info("CONTEXT: " + context.getRunContext())
        

        def configValues = context.getConfigValues()
        def endpoint = configValues.getRequiredParameter('endpoint')
        def cred = configValues.getParameter('basic_credential')
        def userName
        def password
        if (cred){
            userName = cred.getUserName()
            password = cred.getSecretValue()
        }
        
        // def parameters = context.getStepParameters()
        def sectionId = parameters.getParameter('sectionId')
        def body = parameters.getParameter('json')

        def cm = new ComponentManager()
        def cli = cm.loadComponent('CLI', [workingDirectory: System.getenv("COMMANDER_WORKSPACE")])
        def command = cli.newCommand('curl')
        command.addArguments("-k")
        command.addArguments("-H")
        command.addArguments("Content-Type: application/json")
        command.addArguments("-u")
        command.addArguments("${userName}:${password}")
        command.addArguments("-d")
        command.addArguments("${body}")
        command.addArguments("${endpoint}/index.php?/api/v2/add_case/${sectionId}")
        def result = cli.runCommand(command)
        log.info("STDOUT: ${result.stdOut}")
        log.info("STDERR: ${result.stdErr}")

        def json 
        try {
            json = new JsonSlurper().parseText(result.stdOut)
            log.info("-------> json: $json")
            if (json["error"]){
                sr.setJobStepOutcome("error")
                throw new Exception("${json['error']}")
            }
        }
        catch(Exception e) {
            sr.setJobStepSummary("Job failed ${e}")
            return
        }

        // Setting job step summary to the config name
        sr.setJobStepSummary("Test case ${json.id.toString()} was created")

        sr.setOutputParameter('caseJSON', json.toString())
        sr.setOutputParameter('caseId', json.id.toString())

        sr.setOutcomeProperty('caseJSON', json.toString())
        sr.setOutcomeProperty('caseId', json.id.toString())

        sr.setReportUrl("test case link:", "https://ecflow.testrail.net/index.php?/cases/view/${json.id.toString()}")
        sr.apply()
        log.info("step {{step.name}} has been finished")
    }
// === step template ends ===
// === step ends ===



// === step template ===
    /**
    * {{stepMethodName}} - {{step.procedure.name}}/{{step.name}}
    * Add your code into this method and it will be called when the step runs
    {% for p in step.procedure.parameters %}
    * @param {{p.name}} (required: {{p.required}})
    {% endfor %}
    */
    def getTestCase(StepParameters parameters, StepResult sr) {
        log.info("{{stepMethodName}} was invoked with StepParameters", parameters.toString())

        Context context = getContext()
        log.info("CONTEXT: " + context.getRunContext())
        
        // def parameters = context.getStepParameters()
        def caseId = parameters.getParameter('caseId')
        REST rest = context.newRESTClient()
        HTTPRequest request = rest.newRequest(
                method: 'GET',
                path: '/index.php',
                query: ["/api/v2/get_case/${caseId}": ''],
                contentType: 'JSON',
                // headers : ['content-type' : 'application/json']
        )

        request.setHeader('content-type', 'application/json')

        def json
        try {
            json = rest.doRequest(request)
            log.info("-------> json: $json")
        }
        catch(Exception e) {
            sr.setJobStepSummary("Job failed")
            sr.setJobStepOutcome("error")
            return
        }

        // Setting job step summary to the config name
        sr.setJobStepSummary("Test case ${json.id.toString()} info was saved into property")

        sr.setOutputParameter('caseJSON', json.toString())
        sr.setOutputParameter('caseId', json.id.toString())

        sr.setOutcomeProperty('caseJSON', json.toString())
        sr.setOutcomeProperty('caseId', json.id.toString())

        sr.setReportUrl("test case link:", "https://ecflow.testrail.net/index.php?/cases/view/${json.id.toString()}")
        sr.apply()
        log.info("step {{step.name}} has been finished")
    }
// === step template ends ===
// === step ends ===


// === step template ===
    /**
    * {{stepMethodName}} - {{step.procedure.name}}/{{step.name}}
    * Add your code into this method and it will be called when the step runs
    {% for p in step.procedure.parameters %}
    * @param {{p.name}} (required: {{p.required}})
    {% endfor %}
    */
    def getTestCaseCLI(StepParameters parameters, StepResult sr) {
        log.info("{{stepMethodName}} was invoked with StepParameters", parameters.toString())

        Context context = getContext()
        log.info("CONTEXT: " + context.getRunContext())
        

        def configValues = context.getConfigValues()
        def endpoint = configValues.getRequiredParameter('endpoint')
        def cred = configValues.getParameter('basic_credential')
        def userName
        def password
        if (cred){
            userName = cred.getUserName()
            password = cred.getSecretValue()
        }
        
        // def parameters = context.getStepParameters()
        def caseId = parameters.getParameter('caseId')

        def cm = new ComponentManager()
        def cli = cm.loadComponent('CLI', [workingDirectory: System.getenv("COMMANDER_WORKSPACE")])
        def command = cli.newCommand('curl')
        command.addArguments("-k")
        command.addArguments("-H")
        command.addArguments("Content-Type: application/json")
        command.addArguments("-u")
        command.addArguments("${userName}:${password}")
        command.addArguments("${endpoint}/index.php?/api/v2/get_case/${caseId}")
        def result = cli.runCommand(command)
        log.info("STDOUT: ${result.stdOut}")
        log.info("STDERR: ${result.stdErr}")

        def json 
        try {
            json = new JsonSlurper().parseText(result.stdOut)
            log.info("-------> json: $json")
            if (json["error"]){
                sr.setJobStepOutcome("error")
                throw new Exception("${json['error']}")
            }
        }
        catch(Exception e) {
            sr.setJobStepSummary("Job failed ${e}")
            return
        }
        // Setting job step summary to the config name
        sr.setJobStepSummary("Test case ${json.id.toString()} info was saved into property")

        sr.setOutputParameter('caseJSON', json.toString())
        sr.setOutputParameter('caseId', json.id.toString())

        sr.setOutcomeProperty('caseJSON', json.toString())
        sr.setOutcomeProperty('caseId', json.id.toString())

        sr.setReportUrl("test case link:", "https://ecflow.testrail.net/index.php?/cases/view/${json.id.toString()}")
        sr.apply()
        log.info("step {{step.name}} has been finished")
    }



    // === step template ===
    /**
    * {{stepMethodName}} - {{step.procedure.name}}/{{step.name}}
    * Add your code into this method and it will be called when the step runs
    {% for p in step.procedure.parameters %}
    * @param {{p.name}} (required: {{p.required}})
    {% endfor %}
    */
    def updateTestCase(StepParameters parameters, StepResult sr) {
        log.info("{{stepMethodName}} was invoked with StepParameters", parameters.toString())

        Context context = getContext()
        log.info("CONTEXT: " + context.getRunContext())       
        // def parameters = context.getStepParameters()
        def caseId = parameters.getParameter('caseId')
        def body = parameters.getParameter('json')

        REST rest = context.newRESTClient()
        HTTPRequest request = rest.newRequest(
                method: 'POST',
                path: '/index.php',
                query: ["/api/v2/update_case/${caseId}": ''],
                contentType: 'JSON',
                content: body
                // headers : ['content-type' : 'application/json']
        )

        request.setHeader('content-type', 'application/json')

        def json
        try {
            json = rest.doRequest(request)
            log.info("-------> json: $json")
        }
        catch(Exception e) {
            sr.setJobStepSummary("Job failed")
            sr.setJobStepOutcome("error")
            return
        }

        // Setting job step summary to the config name
        sr.setJobStepSummary("Test case ${json.id.toString()} was updated")

        sr.setOutputParameter('caseJSON', json.toString())
        sr.setOutputParameter('caseId', json.id.toString())

        sr.setOutcomeProperty('caseJSON', json.toString())
        sr.setOutcomeProperty('caseId', json.id.toString())

        sr.setReportUrl("test case link:", "https://ecflow.testrail.net/index.php?/cases/view/${json.id.toString()}")
        sr.apply()
        log.info("step {{step.name}} has been finished")
    }
// === step template ends ===
// === step ends ===


// === step template ===
    /**
    * {{stepMethodName}} - {{step.procedure.name}}/{{step.name}}
    * Add your code into this method and it will be called when the step runs
    {% for p in step.procedure.parameters %}
    * @param {{p.name}} (required: {{p.required}})
    {% endfor %}
    */
    def updateTestCaseCLI(StepParameters parameters, StepResult sr) {
        log.info("{{stepMethodName}} was invoked with StepParameters", parameters.toString())

        Context context = getContext()
        log.info("CONTEXT: " + context.getRunContext())
        

        def configValues = context.getConfigValues()
        def endpoint = configValues.getRequiredParameter('endpoint')
        def cred = configValues.getParameter('basic_credential')
        def userName
        def password
        if (cred){
            userName = cred.getUserName()
            password = cred.getSecretValue()
        }
        
        // def parameters = context.getStepParameters()
        def caseId = parameters.getParameter('caseId')
        def body = parameters.getParameter('json')

        def cm = new ComponentManager()
        def cli = cm.loadComponent('CLI', [workingDirectory: System.getenv("COMMANDER_WORKSPACE")])
        def command = cli.newCommand('curl')
        command.addArguments("-k")
        command.addArguments("-H")
        command.addArguments("Content-Type: application/json")
        command.addArguments("-u")
        command.addArguments("${userName}:${password}")
        command.addArguments("-d")
        command.addArguments("${body}")
        command.addArguments("${endpoint}/index.php?/api/v2/update_case/${caseId}")
        def result = cli.runCommand(command)
        log.info("STDOUT: ${result.stdOut}")
        log.info("STDERR: ${result.stdErr}")

        def json 
        try {
            json = new JsonSlurper().parseText(result.stdOut)
            log.info("-------> json: $json")
            if (json["error"]){
                sr.setJobStepOutcome("error")
                throw new Exception("${json['error']}")
            }
        }
        catch(Exception e) {
            sr.setJobStepSummary("Job failed ${e}")
            return
        }

        // Setting job step summary to the config name
        sr.setJobStepSummary("Test case ${json.id.toString()} was updated")

        sr.setOutputParameter('caseJSON', json.toString())
        sr.setOutputParameter('caseId', json.id.toString())

        sr.setOutcomeProperty('caseJSON', json.toString())
        sr.setOutcomeProperty('caseId', json.id.toString())

        sr.setReportUrl("test case link:", "https://ecflow.testrail.net/index.php?/cases/view/${json.id.toString()}")
        sr.apply()
        log.info("step {{step.name}} has been finished")
    }
// === step template ends ===
// === step ends ===


}
