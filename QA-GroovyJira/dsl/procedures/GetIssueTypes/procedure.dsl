// This procedure.dsl was generated automatically
// DO NOT EDIT THIS BLOCK === procedure_autogen starts ===
procedure 'Get Issue Types', description: 'Get issues types', {

    step 'Get Issue Types', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/GetIssueTypes/steps/GetIssueTypes.groovy").text
        shell = 'ec-groovy -cp "$[/server/settings/pluginsDirectory]/QA-GroovyJira-1.0.0.0/agent/deps/lib/flowpdf-groovy-lib-1.0.0-SNAPSHOT.jar:$[/server/settings/pluginsDirectory]/QA-GroovyJira-1.0.0.0/agent/deps/lib/oauth.jar"'
       
    }
// DO NOT EDIT THIS BLOCK === procedure_autogen ends, checksum: fca8698814fb2fdfd7cc22fd1c4f6cb9 ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}