// This procedure.dsl was generated automatically
// DO NOT EDIT THIS BLOCK === procedure_autogen starts ===
procedure 'Get User Info', description: 'Get User Info', {

    step 'Get User Info', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/GetUserInfo/steps/GetUserInfo.groovy").text
        shell = 'ec-groovy -cp "$[/server/settings/pluginsDirectory]/QA-GroovyJira-1.0.0.0/agent/deps/lib/flowpdf-groovy-lib-1.0.0-SNAPSHOT.jar"'
    }
// DO NOT EDIT THIS BLOCK === procedure_autogen ends, checksum: d049207be8660d132d56b2999fd40518 ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}