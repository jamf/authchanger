#  authchanger

A small utility to manage the authorizationdb. Most commonly used for updating the settings to allow for NoMADLoginAD or NoMADLoginOkta

## Options

* -version : prints current version of this tool
* -print : prints out the current auth mechs
* -AD : sets the auth mechs for NoMADLoginAD
* -Okta : sets the auth mechs for NoMADLoginOkta
* -reset : resets the auth mechs to standard
* -preLogin : mechs to be added before the loginwindow UI
* -preAuth : mechs to be added after loginwindow UI but before system authentication
* -postAuth : mechs to be added after system authentication
* -debug : processes inputs but then prints to standard out instead of changing mechanisms

## Pull from Defaults - WIP

authchanger should use UserDefaults to look up settings and apply as appropriate. As a CLI app we'll have to init with suite, which might actually work really well as you'll then be able to override from the CLI as necessary.

Current thinking is "menu.nomad.login.mechanisms" as the default domains.

