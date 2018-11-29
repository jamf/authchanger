#  authchanger

Authchanger is a utility to help you manage the authorization database used by macOS to determine how the login process progresses.


## Options

* -Version        : prints the version number
* -Help | -h      : prints this help statement
* -Reset          : resets the login screen to the factory settings
* -Okta           : sets up NoMAD Login+Okta
* -AD             : sets up NoMAD LoginAD
* -Azure          : sets up NoMAD Login Azure
* -Ping           : sets up NoMAD Ping
* -Demobilize     : sets up NoMAD LoginAD to only demobilze accounts
* -Notify         : adds the DEP Notify addition to the corresponding -AD, -Azure, -Okta, or -Setup argument
* -Print          : prints the current list of authorization mechanisms
* -Debug          : does a dry run of the changes and prints out what would have happened

### Experimental options for working with Admin authorization:

* -SysPrefs       : enables Azure authentication for the Network Preference Pane
* -SysPrefsReset  : removes Azure authentication for the Network Preference Pane

### Experimental options for working with sudo authorization:

* -AddDefaultJCRight : adds the mechanism to be used with the sudosaml binary

In addition to setting basic setups, you can also specify custom rules to be put in.

* -preLogin       : mechs to be used before the actual UI is shown
* -preAuth        : mechs to be used between the login UI and actual authentication
* -postAuth       : mechs to be used after system authentication


## Pull from Defaults - WIP

authchanger should use UserDefaults to look up settings and apply as appropriate. As a CLI app we'll have to init with suite, which might actually work really well as you'll then be able to override from the CLI as necessary.

Current thinking is "menu.nomad.login.mechanisms" as the default domains.

