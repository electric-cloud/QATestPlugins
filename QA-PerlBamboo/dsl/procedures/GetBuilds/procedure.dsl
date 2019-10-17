// This procedure.dsl was generated automatically
// DO NOT EDIT THIS BLOCK === procedure_autogen starts ===
procedure 'Get Builds', description: 'This procedure demonstrates a simple REST call', {

    step 'Get Builds', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/GetBuilds/steps/GetBuilds.pl").text
        // TODO altered shell
        shell = 'ec-perl'

        postProcessor = '''$[/myProject/perl/postpLoader]'''
    }
// DO NOT EDIT THIS BLOCK === procedure_autogen ends, checksum: 86b726f483336d4819712fe3df6f6333 ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}