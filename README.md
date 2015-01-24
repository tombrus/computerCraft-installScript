# computerCraft-installScript
a bash install script to install ComputerCraft on a linux box (only tested ubuntu).

### why
I had a hard time finding out how to install a server for ComputerCraft. I made this script, maybe others find it handy...

### description
This bash script will install a ComputerCraft server on a linux box. You only need this script. The script will download the necessary jars and install them in a sub dir. After this script has run (about a minute) you will have your ComputerCraft server up and running.

### what it installs
The following software is installed:
- [minecraft](https://mcversions.net) *1.7.10*
- [minecraft forge](http://files.minecraftforge.net) *10.13.2.1230*
- [ComputerCraft](http://www.computercraft.info) *1.65*

### prerequisites
A version of *java* needs to be pre-installed.

### what you must do on the client
- install minecraft *1.7.10* on your client machine
- start minecraft, enter the world and quit
- download the *minecraft forge* installer *10.13.2.1230* from [here](http://files.minecraftforge.net)
- run the installer and install forge in your usual minecraft folder
- it will add the forge version to your possible versions
- start minecraft, make a new profile
- open the profile editor and select the forge version a the version to run
- start it up, enter the world and quit
- look in your profile dir, there should be a *mods* folder now
- download ComputerCraft from [here](http://www.computercraft.info)
- drop the downloaded jar into the *mods* folder
- start minecraft, add a new server setting the host and port to where your server is running

That should do it!
