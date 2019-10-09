// This procedure.dsl was generated automatically
// === procedure_autogen starts ===
procedure 'Sample REST Procedure', description: 'This procedure demonstrates a simple REST call', {

    step 'Sample REST Procedure', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/SampleRESTProcedure/steps/SampleRESTProcedure.pl").text
        shell = 'ec-perl'

        postProcessor = '''$[/myProject/perl/postpLoader]'''
    }
// === procedure_autogen ends, checksum: 6b25e6c85072311567285a8efbd9ab57 ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}