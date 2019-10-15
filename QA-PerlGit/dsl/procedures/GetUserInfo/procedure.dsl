// This procedure.dsl was generated automatically
// DO NOT EDIT THIS BLOCK === procedure_autogen starts ===
procedure 'Get User Info', description: 'Get User Info', {

    step 'Get User Info', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/GetUserInfo/steps/GetUserInfo.pl").text
        // TODO altered shell
        shell = 'ec-perl'

        postProcessor = '''$[/myProject/perl/postpLoader]'''
    }
// DO NOT EDIT THIS BLOCK === procedure_autogen ends, checksum: ad5fbe4a7ea0e36a65d95ecdcaa6628a ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}