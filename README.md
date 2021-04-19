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

add the following in your `device/<vendor>/<model>/device.mk` (or any other device mk file):

~~~
# Enable extendrom
$(call inherit-product-if-exists, vendor/extendrom/config/common.mk)
~~~

add the following section to your `device/<vendor>/<model>/vendorsetup.sh` :

~~~
########### extendrom section ###########
$PWD/vendor/extendrom/get_prebuilts.sh

export ENABLE_EXTENDROM=true
export EXTENDROM_PACKAGES="AdAway noEOSappstore Omega F-Droid additional_repos.xml AuroraStore"
~~~

one note about the F-Droid privileged extension which allows to just use F-Droid without allowing "unknown sources":

you can use: `EXTENDROM_PACKAGES="F-DroidPrivilegedExtension_pb"` which will use the prebuilt apk from F-Droid or you can use the recommended way and build it:

for the recommended way add this to your `.repo/local_manifest/extendrom.xml`:

~~~
<!-- F-Droid -->
<remote name="fdroid" fetch="https://gitlab.com/fdroid/" />
<project path="packages/apps/F-DroidPrivilegedExtension" name="privileged-extension.git" remote="fdroid" revision="master" />
~~~

sync this repo with `repo sync -j4 packages/apps/F-DroidPrivilegedExtension`

and add `EXTENDROM_PACKAGES="F-DroidPrivilegedExtension"` (so without `_pb`) to your `device/<vendor>/<model>/vendorsetup.sh`.

## Adding the F-Droid key to your system for verifying signatures

extendrom will verify signatures (mainly used for F-Droid packages) fully automatically but it needs the GPG public key added to your system first:

* either by searching: `gpg --keyserver pgp.mit.edu --search-keys f-droid.org`
* or by specifying the key directly: `gpg --keyserver pgp.mit.edu --recv-key 7A029E54DD5DCE7A`

you can of course use [another keyserver](https://en.wikipedia.org/wiki/Key_server_(cryptographic)#Keyserver_examples) if pgp.mit.edu fails for you

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
