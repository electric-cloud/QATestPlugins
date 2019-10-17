// This procedure.dsl was generated automatically
// DO NOT EDIT THIS BLOCK === procedure_autogen starts ===
procedure 'Sample REST Procedure', description: 'This procedure demonstrates a simple REST call', {

    step 'Sample REST Procedure', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/SampleRESTProcedure/steps/SampleRESTProcedure.pl").text
        // TODO altered shell
        shell = 'ec-perl'

        postProcessor = '''$[/myProject/perl/postpLoader]'''
    }
// DO NOT EDIT THIS BLOCK === procedure_autogen ends, checksum: 63b337137aae16f3e2353036e1579e8f ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}