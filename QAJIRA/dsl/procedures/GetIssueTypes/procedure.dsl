// This procedure.dsl was generated automatically
// === procedure_autogen starts ===
procedure 'Get Issue Types', description: 'Get issues types', {

    step 'Get Issue Types', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/GetIssueTypes/steps/GetIssueTypes.pl").text
        shell = 'ec-perl'

        postProcessor = '''$[/myProject/perl/postpLoader]'''
    }
// === procedure_autogen ends, checksum: fca8698814fb2fdfd7cc22fd1c4f6cb9 ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}