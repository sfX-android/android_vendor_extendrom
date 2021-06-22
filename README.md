# android_vendor_extendrom

modifying / extending without touching the regular Android sources

this project is a merge of vendor/e-mod and vendor/fdroid which are both superseeded by this one.

## setup

create `.repo/local_manifest/extendrom.xml` and add:

~~~
<!-- extendrom -->
<remote name="sfX" fetch="https://github.com/sfX-Android/" />
<project path="vendor/extendrom" name="android_vendor_extendrom" remote="sfX" revision="main" />
~~~

sync this repo with `repo sync -j4 vendor/extendrom`

## activate and configure

You have 2 options to do that, choose the one you like more ;)

### option 1: use an Android makefile

add the following in your `device/<vendor>/<model>/device.mk` (or any other device mk file):

~~~
# Enable extendrom
ENABLE_EXTENDROM := true
EXTENDROM_PACKAGES := "noEOSappstore F-Droid F-DroidPrivilegedExtension additional_repos.xml AuroraStore"
$(call inherit-product-if-exists, vendor/extendrom/config/common.mk)
~~~

add the following section to your `device/<vendor>/<model>/vendorsetup.sh`:

~~~
########### extendrom section ###########
$PWD/vendor/extendrom/get_prebuilts.sh
~~~

### option 2: use the vendorsetup.sh

add the following in your `device/<vendor>/<model>/device.mk` (or any other device mk file):

~~~
# Enable extendrom
$(call inherit-product-if-exists, vendor/extendrom/config/common.mk)
~~~

add the following section to your `device/<vendor>/<model>/vendorsetup.sh`:

~~~
########### extendrom section ###########
$PWD/vendor/extendrom/get_prebuilts.sh
export ENABLE_EXTENDROM=true
export EXTENDROM_PACKAGES="noEOSappstore F-Droid F-DroidPrivilegedExtension additional_repos.xml AuroraStore"
~~~

### F-Droid notes

one note about the *F-Droid privileged extension* which allows to use F-Droid without enabling allowing "unknown sources":

you can use: `EXTENDROM_PACKAGES="F-DroidPrivilegedExtension_pb"` which will use the prebuilt apk from F-Droid or you can use the recommended way and build it instead:

for the recommended way (build with the ROM) add this to your `.repo/local_manifest/extendrom.xml`:

~~~
<!-- F-Droid -->
<remote name="fdroid" fetch="https://gitlab.com/fdroid/" />
<project path="packages/apps/F-DroidPrivilegedExtension" name="privileged-extension.git" remote="fdroid" revision="master" />
~~~

sync this repo with `repo sync -j4 packages/apps/F-DroidPrivilegedExtension`

and add `EXTENDROM_PACKAGES="F-DroidPrivilegedExtension"` (so without `_pb`) to your `device/<vendor>/<model>/device.mk` or `device/<vendor>/<model>/vendorsetup.sh`.

### microG GmsCore notes

[MicroG GmsCore](https://github.com/microg/GmsCore/wiki) is a free software reimplementation of Google's Play Services. /e/ OS ROMs, both official and unofficial, include a version of GmsCore which does not include the Exposure Notifications framework. This framework is used by Covid tracing apps in many countries and without it these apps will either not work at all, or will not implement the exposure tracking functionailty. Users of these /e/ OS ROMs need to install an update - only available in /e/'s Apps appstore - to enable the EN framework and allow the apps which use it to function correctly.

Including the  `MicrogGmsCore` EXTENDROM package replaces /e/'s version of GmsCore (which does not include the EN framework) with the most recent (as of 19th June 2021) stable  version from the MicroG download page <https://microg.org/download.html> (which **does** include the EN Framework). Custom ROMs built with ths package, will therefore have a version of GmsCore which allows Covid tracking apps to work 'out of the box'.

Including the `additional_repos.xml` package as well as the `MicrogGmsCore` package will enable the microG F-Droid repo, allowing F-Droid to detect and manage future updates to GmsCore and the other components of MicroG.

## Adding public GPG keys for verifying signatures

extendrom will verify signatures (if available) fully automatically but it needs the GPG public key added to your system first.<br/>
extendrom comes already with a list of gpg keys which get auto-imported when using it but sometimes you might need to extend that list.

For this you need to know the key id first which you can usually find beneath the package you want to add.<br/>
Another option is to find it by searching: `gpg --keyserver pgp.mit.edu --search-keys f-droid.org` <br/>
Of course there are [other keyservers](https://en.wikipedia.org/wiki/Key_server_(cryptographic)#Keyserver_examples) if pgp.mit.edu fails for you.

Once you got the id just add it to the variable `GPG_KEYS` in `vendor/extendrom/get_prebuilts.sh` (separate by a space from the others).

More information and the current F-Droid fingerprint can be verified [here](https://f-droid.org/docs/Release_Channels_and_Signing_Keys/?title=Release_Channels_and_Signing_Keys)

## extending packages

its very easy to add more prebuilt packages to the list:

open: `vendor/extendrom/repo/packages.txt` and add any additional prebuilt you like here. The format is described in the header of that file.

## removing packages (which are built-in)

even removing a package is possible, e.g. if you do not like the `Apps` package within /e/ OS you can specify `EXTENDROM_PACKAGES="noEOSappstore"` in your `device/<vendor>/<model>/vendorsetup.sh` and it will be removed.

if you want to remove something else: open `vendor/extendrom/extra/Android.mk` and 

* copy/paste the `noEOSappstore` block
* change the `LOCAL_MODULE` name to whatever you like (e.g. `noWHATEVER`)
* `LOCAL_OVERRIDES_PACKAGES` must match the LOCAL_MODULE name of what you want to remove 
* add the `LOCAL_MODULE` name you specified in you `device/<vendor>/<model>/vendorsetup.sh` (e.g. `EXTENDROM_PACKAGES="noWHATEVER"`)

Keep in mind that removing ROM apps like that it might can lead to a non-bootable system if there are dependencies you forgot to take care of.

## building / changes in behavior

whenever you change something in `device/<vendor>/<model>/vendorsetup.sh` you HAVE TO use: `source build/envsetup.sh && <lunch or brunch>` to apply these changes.

best practice is to use that before building always.

I always build like this:

~~~
source build/envsetup.sh
lunch lineage_j5y17lte-userdebug
mka otapackage (or mka eos when buildin /e/)
~~~

instead of lunch `brunch <device>` will do as well ofc.
