// This procedure.dsl was generated automatically
// === procedure_autogen starts ===
procedure 'ValidateCRDParams', description: '', {

    step 'validateCRDParams', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/ValidateCRDParams/steps/validateCRDParams.pl").text
        shell = 'ec-perl'

        postProcessor = '''$[/myProject/perl/postpLoader]'''
    }
// === procedure_autogen ends, checksum: f34eebcaf31513a5a1d5feb225a2644f ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}