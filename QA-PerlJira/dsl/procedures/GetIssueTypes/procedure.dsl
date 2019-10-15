// This procedure.dsl was generated automatically
// DO NOT EDIT THIS BLOCK === procedure_autogen starts ===
procedure 'Get Issue Types', description: 'Get issues types', {

    step 'Get Issue Types', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/GetIssueTypes/steps/GetIssueTypes.pl").text
        // TODO altered shell
        shell = 'ec-perl'

        postProcessor = '''$[/myProject/perl/postpLoader]'''
    }
// DO NOT EDIT THIS BLOCK === procedure_autogen ends, checksum: 58405be23134086a5a417c30b7a46437 ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}